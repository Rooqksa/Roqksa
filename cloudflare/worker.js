import { RtcTokenBuilder, RtcRole } from "agora-token";
const PROJECT_ID = "roqksa", TOKEN_TTL = 3600;
const JWKS_URL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
let cachedKeys, keysExpireAt = 0;
const reply = (data, status, origin) => new Response(JSON.stringify(data), { status, headers: {
  "content-type":"application/json; charset=utf-8","cache-control":"no-store",
  "access-control-allow-origin":origin,"access-control-allow-methods":"POST, OPTIONS",
  "access-control-allow-headers":"authorization, content-type","vary":"Origin"
}});
function decode64(s) { const x=atob(s.replace(/-/g,"+").replace(/_/g,"/")+"=".repeat((4-s.length%4)%4)); return Uint8Array.from(x,c=>c.charCodeAt(0)); }
function part(s) { return JSON.parse(new TextDecoder().decode(decode64(s))); }
async function keys() {
  if(cachedKeys && Date.now()<keysExpireAt) return cachedKeys;
  const r=await fetch(JWKS_URL,{cf:{cacheTtl:3600,cacheEverything:true}});
  if(!r.ok) throw new Error("تعذر التحقق من تسجيل الدخول حالياً.");
  cachedKeys=(await r.json()).keys||[]; keysExpireAt=Date.now()+3000000; return cachedKeys;
}
async function verify(token) {
  const p=token.split("."); if(p.length!==3) throw new Error("رمز تسجيل الدخول غير صالح.");
  const h=part(p[0]), c=part(p[1]), now=Math.floor(Date.now()/1000);
  if(h.alg!=="RS256"||!h.kid||c.aud!==PROJECT_ID||
    c.iss!=="https://securetoken.google.com/"+PROJECT_ID||
    typeof c.sub!=="string"||!c.sub||!Number.isFinite(c.exp)||c.exp<=now||
    !Number.isFinite(c.iat)||c.iat>now+60||(c.nbf&&c.nbf>now))
    throw new Error("انتهت صلاحية تسجيل الدخول أو أن الحساب غير صالح.");
  let k=(await keys()).find(v=>v.kid===h.kid);
  if(!k){cachedKeys=null;keysExpireAt=0;k=(await keys()).find(v=>v.kid===h.kid);}
  if(!k) throw new Error("تعذر التحقق من توقيع تسجيل الدخول.");
  const pub=await crypto.subtle.importKey("jwk",k,{name:"RSASSA-PKCS1-v1_5",hash:"SHA-256"},false,["verify"]);
  const ok=await crypto.subtle.verify("RSASSA-PKCS1-v1_5",pub,decode64(p[2]),new TextEncoder().encode(p[0]+"."+p[1]));
  if(!ok) throw new Error("تعذر التحقق من هوية المستخدم.");
  return c;
}
async function uidFor(uid) { const h=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(uid)); return (new DataView(h).getUint32(0,false)&0x7fffffff)||1; }
export default { async fetch(request,env) {
  const origin=request.headers.get("Origin")||"*";
  if(request.method==="OPTIONS") return new Response(null,{status:204,headers:{
    "access-control-allow-origin":origin,"access-control-allow-methods":"POST, OPTIONS",
    "access-control-allow-headers":"authorization, content-type","access-control-max-age":"86400","vary":"Origin"}});
  if(request.method!=="POST") return reply({error:"استخدم POST فقط."},405,origin);
  try {
    const m=(request.headers.get("Authorization")||"").match(/^Bearer\s+(.+)$/i);
    if(!m) return reply({error:"يجب تسجيل الدخول أولاً."},401,origin);
    const user=await verify(m[1]), body=await request.json(), channel=body?.channelName;
    if(typeof channel!=="string"||!channel.length||new TextEncoder().encode(channel).length>64||
      !/^[A-Za-z0-9 _!#$%&()+,:;=?@^{}|~.-]+$/.test(channel))
      return reply({error:"اسم الغرفة غير صالح."},400,origin);
    if(!env.AGORA_APP_ID||!env.AGORA_APP_CERTIFICATE)
      return reply({error:"إعدادات Agora غير مكتملة في Cloudflare."},500,origin);
    const uid=await uidFor(user.sub);
    const token=RtcTokenBuilder.buildTokenWithUid(env.AGORA_APP_ID,env.AGORA_APP_CERTIFICATE,channel,uid,RtcRole.PUBLISHER,TOKEN_TTL,TOKEN_TTL);
    return reply({appId:env.AGORA_APP_ID,channelName:channel,uid,token,expiresIn:TOKEN_TTL},200,origin);
  } catch(e) {
    console.error("Agora token error:",e?.message||e);
    const message=e?.message||"تعذر إنشاء رمز الغرفة الصوتية.";
    const status=/تسجيل الدخول|رمز|توقيع|هوية المستخدم|الحساب غير صالح|انتهت صلاحية/.test(message)?401:500;
    return reply({error:message},status,origin);
  }
}};
