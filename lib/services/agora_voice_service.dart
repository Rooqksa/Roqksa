import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

/// Agora RTC session. The certificate stays on Cloudflare; only a short-lived
/// token is returned after the Worker verifies the signed-in Firebase user.
class AgoraVoiceService {
  static const String _tokenUrl = 'https://roqksa-agora.j222j2222.workers.dev/';
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
    if (!kIsWeb) {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) throw StateError('لم يتم السماح باستخدام الميكروفون.');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول إلى حسابك أولاً.');
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) throw StateError('تعذر التحقق من تسجيل الدخول.');

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Authorization': 'Bearer $idToken', 'Content-Type': 'application/json'},
      body: jsonEncode({'channelName': channelName}),
    );
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw StateError('استجابة خادم الصوت غير مفهومة. رمز الخطأ: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      throw StateError(data['error']?.toString() ?? 'فشل إصدار رمز الصوت. رمز الخطأ: ${response.statusCode}');
    }

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
      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _joined = true;
          onLocalJoin();
        },
        onUserJoined: (connection, remoteUid, elapsed) => onRemoteUserJoined(remoteUid),
        onUserOffline: (connection, remoteUid, reason) => onRemoteUserLeft(remoteUid),
      ));
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
    try { await engine.leaveChannel(); } finally { await engine.release(); }
  }
}
