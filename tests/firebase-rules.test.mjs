import { readFileSync } from 'node:fs';
import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  Timestamp,
  updateDoc,
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

test('status content is immutable and only its owner can delete it', async () => {
  const alice = testEnv.authenticatedContext('alice').firestore();
  const bob = testEnv.authenticatedContext('bob').firestore();
  await assertSucceeds(setDoc(doc(alice, 'statuses/status-1'), {
    ownerId: 'alice',
    text: 'حالة تجريبية',
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
