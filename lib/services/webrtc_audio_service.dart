import 'package:flutter_webrtc/flutter_webrtc.dart';

/// إدارة موارد الصوت المحلية واتصالات WebRTC في غرف Roqksa.
///
/// هذه الطبقة لا تنفذ signaling أو مصادقة الغرف؛ يجب أن يمر تبادل
/// SDP/ICE عبر قناة موثوقة قبل استخدامها مع أعضاء حقيقيين.
class WebRtcAudioService {
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  bool _muted = false;
  bool _disposed = false;

  MediaStream? get localStream => _localStream;
  bool get isMuted => _muted;
  bool get hasMicrophone => _localStream?.getAudioTracks().isNotEmpty ?? false;

  Future<void> initializeMicrophone() async {
    _ensureActive();
    if (_localStream != null) return;

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });
    _muted = false;
  }

  /// ينشئ اتصال نظير واحداً. تمرر إعدادات ICE من الخادم/البيئة،
  /// ولا تضع بيانات اعتماد TURN ثابتة داخل التطبيق.
  Future<RTCPeerConnection> createPeerConnectionFor(
    String peerId, {
    required Map<String, dynamic> iceServers,
    Function(RTCIceCandidate candidate)? onIceCandidate,
    Function(RTCTrackEvent event)? onRemoteTrack,
    Function(RTCPeerConnectionState state)? onConnectionState,
  }) async {
    _ensureActive();
    if (_peerConnections.containsKey(peerId)) {
      return _peerConnections[peerId]!;
    }
    await initializeMicrophone();

    final peer = await createPeerConnection(iceServers, {
      'sdpSemantics': 'unified-plan',
    });

    final stream = _localStream!;
    for (final track in stream.getAudioTracks()) {
      await peer.addTrack(track, stream);
    }

    peer.onIceCandidate = (candidate) {
      if (candidate.candidate != null) onIceCandidate?.call(candidate);
    };
    peer.onTrack = (event) => onRemoteTrack?.call(event);
    peer.onConnectionState = (state) => onConnectionState?.call(state);

    _peerConnections[peerId] = peer;
    return peer;
  }

  Future<void> setMicrophoneMuted(bool muted) async {
    _ensureActive();
    await initializeMicrophone();
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !muted;
    }
    _muted = muted;
  }

  Future<void> addRemoteIceCandidate(
    String peerId,
    RTCIceCandidate candidate,
  ) async {
    final peer = _peerConnections[peerId];
    if (peer == null) {
      throw StateError('لا يوجد اتصال WebRTC للعضو $peerId');
    }
    await peer.addCandidate(candidate);
  }

  Future<void> closePeer(String peerId) async {
    final peer = _peerConnections.remove(peerId);
    if (peer != null) {
      await peer.close();
      await peer.dispose();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final peers = _peerConnections.values.toList();
    _peerConnections.clear();
    for (final peer in peers) {
      await peer.close();
      await peer.dispose();
    }
    final stream = _localStream;
    _localStream = null;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      await stream.dispose();
    }
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('تم إغلاق خدمة صوت Roqksa');
    }
  }
}
