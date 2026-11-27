import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles one authenticated Agora voice-channel session.
///
/// The Agora App Certificate is never sent to this client. A short-lived RTC
/// token is requested from the authenticated Firebase callable function.
class AgoraVoiceService {
  RtcEngine? _engine;
  bool _joined = false;

  bool get isJoined => _joined;

  Future<void> join({
    required String channelName,
    required ValueChanged<int> onRemoteUserJoined,
    required ValueChanged<int> onRemoteUserLeft,
    required VoidCallback onLocalJoin,
  }) async {
    if (_joined) return;
    if (channelName.isEmpty || channelName.length > 64) {
      throw ArgumentError.value(channelName, 'channelName', 'Invalid Agora channel name');
    }

    // Microphone permission is required on native devices. The web plugin
    // requests browser permission through the browser media stack.
    if (!kIsWeb) {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        throw StateError('لم يتم السماح باستخدام الميكروفون.');
      }
    }

    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('createAgoraRtcToken');
    final response = await callable.call(<String, Object?>{
      'channelName': channelName,
    });
    final data = Map<String, dynamic>.from(response.data as Map);
    final appId = data['appId'] as String;
    final token = data['token'] as String;
    final uid = (data['uid'] as num).toInt();

    final engine = createAgoraRtcEngine();
    _engine = engine;
    try {
      await engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      await engine.enableAudio();
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            _joined = true;
            onLocalJoin();
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            onRemoteUserJoined(remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            onRemoteUserLeft(remoteUid);
          },
        ),
      );
      await engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (_) {
      await engine.release();
      _engine = null;
      rethrow;
    }
  }

  Future<void> setMicrophoneMuted(bool muted) async {
    final engine = _engine;
    if (engine == null || !_joined) return;
    await engine.muteLocalAudioStream(muted);
  }

  Future<void> setSpeakerEnabled(bool enabled) async {
    final engine = _engine;
    if (engine == null || !_joined) return;
    await engine.setEnableSpeakerphone(enabled);
  }

  Future<void> leave() async {
    final engine = _engine;
    _engine = null;
    _joined = false;
    if (engine == null) return;
    try {
      await engine.leaveChannel();
    } finally {
      await engine.release();
    }
  }
}
