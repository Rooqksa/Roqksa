const crypto = require("node:crypto");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { RtcTokenBuilder, Role } = require("agora-token");

const AGORA_APP_ID = "dc8edeee6c3f4ca8bcfd7a73abf3468b";
const AGORA_APP_CERTIFICATE = defineSecret("AGORA_APP_CERTIFICATE");
const TOKEN_TTL_SECONDS = 60 * 60;

exports.createAgoraRtcToken = onCall(
  {
    region: "us-central1",
    secrets: [AGORA_APP_CERTIFICATE],
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً.");
    }

    const channelName = request.data?.channelName;
    if (
      typeof channelName !== "string" ||
      channelName.length < 1 ||
      Buffer.byteLength(channelName, "utf8") > 64 ||
      !/^[a-zA-Z0-9 !#$%&()+\-:;=?@\[\]^_{}|~,]+$/.test(channelName)
    ) {
      throw new HttpsError("invalid-argument", "اسم القناة غير صالح.");
    }

    const certificate = AGORA_APP_CERTIFICATE.value();
    if (!certificate) {
      throw new HttpsError("failed-precondition", "لم يتم إعداد سر Agora على الخادم.");
    }

    // Stable positive 32-bit UID derived from the authenticated Firebase UID.
    const digest = crypto.createHash("sha256").update(request.auth.uid).digest();
    const uid = (digest.readUInt32BE(0) & 0x7fffffff) || 1;

    try {
      const token = RtcTokenBuilder.buildTokenWithUid(
        AGORA_APP_ID,
        certificate,
        channelName,
        uid,
        Role.PUBLISHER,
        TOKEN_TTL_SECONDS,
        TOKEN_TTL_SECONDS
      );

      return {
        appId: AGORA_APP_ID,
        channelName,
        uid,
        token,
        expiresIn: TOKEN_TTL_SECONDS,
      };
    } catch (error) {
      console.error("Agora RTC token generation failed", error);
      throw new HttpsError("internal", "تعذر إنشاء رمز دخول الغرفة الصوتية.");
    }
  }
);
