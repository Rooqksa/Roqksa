# Roqksa production foundation

This repository currently contains a Flutter prototype. Demo authentication, local chat, room UI, wallet and gift screens are not production services. Do not represent them as live features until the integrations below are configured and tested.

## Backend services

- Firebase Authentication: email/password, verification, password reset and account lifecycle.
- Cloud Firestore: user profiles, friendship/follow relationships, conversations, messages, room metadata, status metadata and moderation reports.
- Cloud Storage: user media and short clips. Private conversation media must be served only after membership authorization.
- Cloud Functions or a trusted server: role changes, moderation, notification fan-out, status cleanup, economy ledger and RTC token issuance.
- Push notifications: FCM plus APNs configuration for iOS.
- Live audio: RTC provider (for example Agora) with short-lived server-issued tokens. Never embed an RTC secret in the Flutter app.

## Required setup by project owner

1. Create a Firebase project and register Android and iOS bundle identifiers.
2. Enable Authentication providers and configure authorized domains.
3. Run FlutterFire configuration and add generated platform config files locally; do not commit private service-account credentials.
4. Deploy and test `firestore.rules` and `storage.rules` in the Firebase Emulator Suite before production.
5. Configure Cloud Functions secrets for RTC and notification credentials.
6. Configure APNs only when the Apple Developer account and iOS signing are ready.

## Data model conventions

- `users/{uid}`: public profile fields only; never store passwords or sensitive identity documents.
- `conversations/{id}`: `memberIds` array and summary fields. Messages live under `messages/{messageId}`.
- `statuses/{id}`: `ownerId`, media metadata, `createdAt`, and server timestamp `expiresAt`; enforce expiry in queries and scheduled cleanup.
- `rooms/{id}`: room metadata and host identifier. RTC credentials are never stored in readable room documents.
- `reports/{id}`: reporter, target, reason and timestamps; access restricted to trusted moderation tooling.

## Privacy and screenshot notices

For disappearing clips, store a delivery/view state and use platform screenshot signals where the OS exposes them. iOS and Android do not provide a universal guarantee that every screenshot, screen recording, external camera capture or modified-device capture can be detected. UI copy must describe notifications as best-effort, not guaranteed. Do not claim end-to-end encryption unless it is implemented and independently reviewed.

## Economy and gifts

Wallet balances must not be edited directly by clients. Use an append-only server-authoritative ledger, idempotency keys, transaction validation, fraud controls and store-policy review before enabling purchases or redeemable value.

## Release acceptance

A feature is complete only after tests demonstrate it across two independent accounts/devices, authorization rules reject unauthorized access, CI passes, and platform builds succeed. The current CI workflow checks Flutter analysis/tests and builds web/Android; iOS signing and an actual iOS build still require a macOS runner and Apple signing configuration.
