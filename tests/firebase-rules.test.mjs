import { readFileSync } from 'node:fs';
import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  Timestamp,
  updateDoc,
  where,
} from 'firebase/firestore';
import { getBytes, ref, uploadBytes } from 'firebase/storage';

const projectId = 'demo-roqksa';
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync('firestore.rules', 'utf8'),
    },
    storage: {
      host: '127.0.0.1',
      port: 9199,
      rules: readFileSync('storage.rules', 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

test('users can create only their own profile with the allowed fields', async () => {
  const db = testEnv.authenticatedContext('alice').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/alice'), {
    uid: 'alice',
    displayName: 'Alice',
    bio: 'Hello',
  }));
  await assertFails(setDoc(doc(db, 'users/bob'), {
    uid: 'bob',
    displayName: 'Bob',
  }));
  await assertFails(setDoc(doc(db, 'users/alice'), {
    uid: 'alice',
    displayName: 'Alice',
    password: 'must-not-be-stored',
  }));

  await assertFails(getDoc(doc(db, 'users/bob')));
  const publicProfile = {
    uid: 'alice',
    displayName: 'Alice',
    photoUrl: null,
    bio: 'Hello',
    giftsCount: 0,
    postsCount: 0,
  };
  await assertSucceeds(setDoc(doc(db, 'publicProfiles/alice'), publicProfile));
  const bob = testEnv.authenticatedContext('bob').firestore();
  await assertSucceeds(getDoc(doc(bob, 'publicProfiles/alice')));
  await assertFails(getDoc(doc(bob, 'users/alice')));
  await assertFails(setDoc(doc(db, 'publicProfiles/bob'), {
    ...publicProfile,
    uid: 'bob',
  }));
  await assertFails(updateDoc(doc(db, 'publicProfiles/alice'), {
    giftsCount: 500,
  }));
});

test('conversation data and messages are limited to members', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  const mallory = testEnv.authenticatedContext('mallory').firestore();

  await assertSucceeds(setDoc(doc(alice, 'conversations/chat-1'), {
    memberIds: ['alice', 'bob'],
    createdAt: Timestamp.now(),
  }));
  await assertSucceeds(setDoc(doc(alice, 'conversations/chat-1/messages/msg-1'), {
    senderId: 'alice',
    text: 'مرحبا',
    createdAt: Timestamp.now(),
  }));
  await assertFails(getDoc(doc(mallory, 'conversations/chat-1')));
  await assertFails(getDoc(doc(mallory, 'conversations/chat-1/messages/msg-1')));
  await assertFails(setDoc(doc(mallory, 'conversations/chat-1/messages/msg-2'), {
    senderId: 'mallory',
    text: 'غير مصرح',
    createdAt: Timestamp.now(),
  }));
  await assertFails(setDoc(doc(bob, 'conversations/chat-1/messages/msg-3'), {
    senderId: 'alice',
    text: 'تزوير المرسل',
    createdAt: Timestamp.now(),
  }));
});

test('status visibility supports public, accepted friends, and selected viewers', async () => {
  const future = Timestamp.fromDate(new Date(Date.now() + 60 * 60 * 1000));
  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  const carol = testEnv.authenticatedContext('carol').firestore();
  const mallory = testEnv.authenticatedContext('mallory').firestore();

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'friendships/alice/friends/bob'), { status: 'accepted' });
    await setDoc(doc(db, 'friendships/bob/friends/alice'), { status: 'accepted' });
  });

  await assertSucceeds(setDoc(doc(alice, 'statuses/public-1'), {
    ownerId: 'alice',
    text: 'للجميع',
    visibility: 'public',
    allowedUserIds: [],
    expiresAt: future,
  }));
  await assertSucceeds(getDoc(doc(bob, 'statuses/public-1')));

  await assertSucceeds(setDoc(doc(alice, 'statuses/friends-1'), {
    ownerId: 'alice',
    text: 'للأصدقاء',
    visibility: 'friends',
    allowedUserIds: [],
    expiresAt: future,
  }));
  await assertSucceeds(getDoc(doc(bob, 'statuses/friends-1')));
  await assertFails(getDoc(doc(carol, 'statuses/friends-1')));

  await assertSucceeds(setDoc(doc(alice, 'statuses/selected-1'), {
    ownerId: 'alice',
    text: 'لأشخاص محددين',
    visibility: 'selected',
    allowedUserIds: ['carol'],
    expiresAt: future,
  }));
  await assertSucceeds(getDoc(doc(carol, 'statuses/selected-1')));
  await assertFails(getDoc(doc(bob, 'statuses/selected-1')));
  await assertFails(getDoc(doc(mallory, 'statuses/selected-1')));

  await assertFails(setDoc(doc(alice, 'statuses/invalid-selected'), {
    ownerId: 'alice',
    visibility: 'selected',
    allowedUserIds: [],
    expiresAt: future,
  }));
  await assertFails(setDoc(doc(bob, 'statuses/impersonated'), {
    ownerId: 'alice',
    visibility: 'public',
    allowedUserIds: [],
    expiresAt: future,
  }));
  await assertFails(setDoc(doc(bob, 'friendships/bob/friends/mallory'), {
    status: 'accepted',
  }));
});

test('status content is immutable and only its owner can delete it', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  await assertSucceeds(setDoc(doc(alice, 'statuses/status-1'), {
    ownerId: 'alice',
    text: 'حالة تجريبية',
    visibility: 'public',
    allowedUserIds: [],
    expiresAt: Timestamp.fromDate(new Date(Date.now() + 60 * 60 * 1000)),
  }));
  await assertFails(updateDoc(doc(alice, 'statuses/status-1'), { text: 'تعديل' }));
  await assertFails(deleteDoc(doc(bob, 'statuses/status-1')));
  await assertSucceeds(deleteDoc(doc(alice, 'statuses/status-1')));
});

test('room host can edit descriptive fields but cannot transfer ownership', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'rooms/room-1'), {
      hostId: 'alice',
      title: 'غرفة',
      description: 'وصف',
      updatedAt: Timestamp.now(),
      participantCount: 1,
    });
  });

  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  await assertSucceeds(updateDoc(doc(alice, 'rooms/room-1'), { title: 'عنوان جديد' }));
  await assertFails(updateDoc(doc(alice, 'rooms/room-1'), { hostId: 'bob' }));
  await assertFails(updateDoc(doc(alice, 'rooms/room-1'), { participantCount: 99 }));
  await assertFails(updateDoc(doc(bob, 'rooms/room-1'), { title: 'اختراق' }));
});

test('voice participants and WebRTC signals are restricted to active room members', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'rooms/voice-1'), { hostId: 'host' });
    for (const uid of ['host', 'alice', 'bob']) {
      await setDoc(doc(db, `rooms/voice-1/participants/${uid}`), {
        uid,
        status: 'active',
      });
    }
    await setDoc(doc(db, 'rooms/voice-1/rtcSignals/signal-for-alice'), {
      senderUid: 'bob',
      targetUid: 'alice',
      signalType: 'offer',
      payload: { sdp: 'test' },
    });
  });

  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  const mallory = testEnv.authenticatedContext('mallory').firestore();

  await assertSucceeds(getDocs(query(
    collection(alice, 'rooms/voice-1/participants'),
    where('status', '==', 'active'),
  )));
  await assertFails(getDocs(collection(mallory, 'rooms/voice-1/participants')));
  await assertSucceeds(getDocs(query(
    collection(alice, 'rooms/voice-1/rtcSignals'),
    where('targetUid', '==', 'alice'),
  )));
  await assertFails(getDocs(collection(alice, 'rooms/voice-1/rtcSignals')));
  await assertSucceeds(getDoc(doc(alice, 'rooms/voice-1/rtcSignals/signal-for-alice')));
  await assertSucceeds(getDoc(doc(bob, 'rooms/voice-1/rtcSignals/signal-for-alice')));
  await assertFails(getDoc(doc(mallory, 'rooms/voice-1/rtcSignals/signal-for-alice')));

  await assertFails(setDoc(doc(alice, 'rooms/voice-1/participants/mallory'), {
    uid: 'mallory',
    status: 'active',
  }));
  await assertFails(setDoc(doc(alice, 'rooms/voice-1/rtcSignals/forged'), {
    senderUid: 'alice',
    targetUid: 'mallory',
    signalType: 'offer',
    payload: { sdp: 'forged' },
  }));
  await assertFails(deleteDoc(doc(bob, 'rooms/voice-1/rtcSignals/signal-for-alice')));
  await assertSucceeds(deleteDoc(doc(alice, 'rooms/voice-1/rtcSignals/signal-for-alice')));
});

test('reports can be submitted by their reporter but are not client-readable', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  await assertSucceeds(setDoc(doc(alice, 'reports/report-1'), {
    reporterId: 'alice',
    targetId: 'bob',
    reason: 'abuse',
  }));
  await assertFails(getDoc(doc(alice, 'reports/report-1')));
});

test('user media is private to its owner and accepts image uploads', async () => {
  const alice = testEnv.authenticatedContext('alice').storage();
  const bob = testEnv.authenticatedContext('bob').storage();
  const objectPath = 'users/alice/avatar.png';
  const bytes = new Uint8Array([137, 80, 78, 71]);

  await assertSucceeds(uploadBytes(ref(alice, objectPath), bytes, {
    contentType: 'image/png',
  }));
  await assertSucceeds(getBytes(ref(alice, objectPath)));
  await assertFails(getBytes(ref(bob, objectPath)));
  await assertFails(uploadBytes(ref(bob, objectPath), bytes, {
    contentType: 'image/png',
  }));
});

test('private conversation media stays blocked until membership authorization exists', async () => {
  const alice = testEnv.authenticatedContext('alice').storage();
  const objectRef = ref(alice, 'private-media/chat-1/clip.mp4');
  await assertFails(uploadBytes(objectRef, new Uint8Array([1, 2, 3]), {
    contentType: 'video/mp4',
  }));
  await assertFails(getBytes(objectRef));
});
