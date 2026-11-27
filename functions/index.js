const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();
const REGION = "us-central1";
const MAX_SIGNAL_BYTES = 64 * 1024;

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً.");
  }
  return request.auth.uid;
}

function requireId(value, fieldName) {
  if (typeof value !== "string" || value.length < 1 || value.length > 128) {
    throw new HttpsError("invalid-argument", `قيمة ${fieldName} غير صالحة.`);
  }
  return value;
}

async function activeParticipant(roomId, uid) {
  const ref = db.doc(`rooms/${roomId}/participants/${uid}`);
  const snap = await ref.get();
  return snap.exists && snap.get("status") === "active";
}

exports.joinVoiceRoom = onCall({ region: REGION }, async (request) => {
  const uid = requireAuth(request);
  const roomId = requireId(request.data?.roomId, "roomId");
  const roomRef = db.doc(`rooms/${roomId}`);
  const roomSnap = await roomRef.get();

  if (!roomSnap.exists) {
    throw new HttpsError("not-found", "الغرفة غير موجودة.");
  }

  const room = roomSnap.data();
  const isHost = room.hostId === uid;
  const isPrivate = room.isPrivate === true || room.visibility === "private";
  if (isPrivate && !isHost) {
    throw new HttpsError("permission-denied", "دخول الغرف الخاصة يحتاج مسار تحقق من رمز القفل.");
  }

  const participantRef = roomRef.collection("participants").doc(uid);
  await participantRef.set({
    uid,
    role: isHost ? "host" : "listener",
    status: "active",
    joinedAt: FieldValue.serverTimestamp(),
    lastSeenAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  return { roomId, uid, role: isHost ? "host" : "listener" };
});

exports.leaveVoiceRoom = onCall({ region: REGION }, async (request) => {
  const uid = requireAuth(request);
  const roomId = requireId(request.data?.roomId, "roomId");
  const participantRef = db.doc(`rooms/${roomId}/participants/${uid}`);
  const snap = await participantRef.get();

  if (!snap.exists || snap.get("status") !== "active") {
    return { roomId, left: true };
  }

  await participantRef.update({
    status: "left",
    leftAt: FieldValue.serverTimestamp(),
  });
  return { roomId, left: true };
});

exports.sendVoiceSignal = onCall({ region: REGION }, async (request) => {
  const senderUid = requireAuth(request);
  const roomId = requireId(request.data?.roomId, "roomId");
  const targetUid = requireId(request.data?.targetUid, "targetUid");
  const signalType = request.data?.signalType;
  const payload = request.data?.payload;

  if (senderUid === targetUid) {
    throw new HttpsError("invalid-argument", "لا يمكن إرسال إشارة إلى الحساب نفسه.");
  }
  if (!["offer", "answer", "candidate"].includes(signalType)) {
    throw new HttpsError("invalid-argument", "نوع إشارة WebRTC غير مدعوم.");
  }
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    throw new HttpsError("invalid-argument", "محتوى الإشارة غير صالح.");
  }
  if (Buffer.byteLength(JSON.stringify(payload), "utf8") > MAX_SIGNAL_BYTES) {
    throw new HttpsError("invalid-argument", "حجم إشارة WebRTC أكبر من الحد المسموح.");
  }

  const roomSnap = await db.doc(`rooms/${roomId}`).get();
  if (!roomSnap.exists) {
    throw new HttpsError("not-found", "الغرفة غير موجودة.");
  }

  const [senderActive, targetActive] = await Promise.all([
    activeParticipant(roomId, senderUid),
    activeParticipant(roomId, targetUid),
  ]);
  if (!senderActive || !targetActive) {
    throw new HttpsError("permission-denied", "يجب أن يكون الطرفان عضوين نشطين في الغرفة.");
  }

  const signalRef = db.collection(`rooms/${roomId}/rtcSignals`).doc();
  await signalRef.create({
    senderUid,
    targetUid,
    signalType,
    payload,
    createdAt: FieldValue.serverTimestamp(),
  });

  return { signalId: signalRef.id };
});
