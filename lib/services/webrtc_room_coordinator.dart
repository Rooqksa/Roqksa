import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'voice_signaling_service.dart';
import 'webrtc_audio_service.dart';

/// ينسق تبادل SDP وICE بين أعضاء الغرفة.
/// هذا النمط mesh تأسيسي ومناسب لاختبارات عدد قليل من المشاركين فقط.
class WebRtcRoomCoordinator {
  WebRtcRoomCoordinator({
    required this.roomId,
    required this.uid,
    required this.iceServers,
    VoiceSignalingService? signaling,
    WebRtcAudioService? audio,
    this.onRemoteTrack,
    this.onError,
  })  : _signaling = signaling ?? VoiceSignalingService(),
        _audio = audio ?? WebRtcAudioService();

  final String roomId;
  final String uid;
  final Map<String, dynamic> iceServers;
  final VoiceSignalingService _signaling;
  final WebRtcAudioService _audio;
  final void Function(String peerUid, RTCTrackEvent event)? onRemoteTrack;
  final void Function(Object error)? onError;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _participantsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _signalsSub;
  final Set<String> _activePeers = {};
  final Set<String> _offeringPeers = {};
  final Set<String> _remoteDescriptionReady = {};
  final Map<String, List<RTCIceCandidate>> _pendingCandidates = {};
  final Set<String> _handledSignals = {};
  bool _started = false;
  bool _disposed = false;

  Future<void> start() async {
    _ensureActive();
    if (_started) return;
    // طلب إذن الميكروفون مبكراً حتى لا تبدأ الغرفة بصمت غير واضح.
    await _audio.initializeMicrophone();
    await _signaling.joinRoom(roomId);
    _started = true;

    _signalsSub = _signaling
        .watchIncomingSignals(roomId: roomId, uid: uid)
        .listen(_onSignals, onError: _reportError);
    _participantsSub = _signaling
        .watchParticipants(roomId)
        .listen(_onParticipants, onError: _reportError);
  }

  void _onParticipants(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final nextPeers = snapshot.docs
        .map((doc) => doc.id)
        .where((peerUid) => peerUid != uid)
        .toSet();

    for (final departedUid in _activePeers.difference(nextPeers)) {
      _activePeers.remove(departedUid);
      _offeringPeers.remove(departedUid);
      _remoteDescriptionReady.remove(departedUid);
      _pendingCandidates.remove(departedUid);
      unawaited(_audio.closePeer(departedUid).catchError(_reportError));
    }

    for (final peerUid in nextPeers.difference(_activePeers)) {
      _activePeers.add(peerUid);
      // اختيار منشئ العرض بشكل حتمي يمنع الطرفين من بدء Offer في الوقت نفسه.
      if (uid.compareTo(peerUid) < 0) {
        unawaited(_createOffer(peerUid).catchError(_reportError));
      }
    }
  }

  Future<RTCPeerConnection> _peer(String peerUid) {
    return _audio.createPeerConnectionFor(
      peerUid,
      iceServers: iceServers,
      onIceCandidate: (candidate) {
        if (candidate.candidate == null) return;
        unawaited(_signaling.sendSignal(
          roomId: roomId,
          targetUid: peerUid,
          signalType: 'candidate',
          payload: {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        ).catchError(_reportError));
      },
      onRemoteTrack: (event) => onRemoteTrack?.call(peerUid, event),
      onConnectionState: (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          // يظل الاتصال قابلاً لإعادة المحاولة؛ لا نحذف العضو من الغرفة هنا.
        }
      },
    );
  }

  Future<void> _createOffer(String peerUid) async {
    if (!_activePeers.contains(peerUid) || !_offeringPeers.add(peerUid)) return;
    try {
      final peer = await _peer(peerUid);
      final offer = await peer.createOffer();
      await peer.setLocalDescription(offer);
      await _signaling.sendSignal(
        roomId: roomId,
        targetUid: peerUid,
        signalType: 'offer',
        payload: {'sdp': offer.sdp, 'type': offer.type},
      );
    } finally {
      _offeringPeers.remove(peerUid);
    }
  }

  void _onSignals(QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final signalId = change.doc.id;
      if (!_handledSignals.add(signalId)) continue;
      unawaited(_handleSignal(signalId, change.doc.data()!).catchError((error) {
        _handledSignals.remove(signalId);
        _reportError(error);
      }));
    }
  }

  Future<void> _handleSignal(
    String signalId,
    Map<String, dynamic> data,
  ) async {
    final peerUid = data['senderUid'];
    final type = data['signalType'];
    final payload = data['payload'];
    if (peerUid is! String ||
        !_activePeers.contains(peerUid) ||
        payload is! Map<String, dynamic>) {
      throw StateError('وصلت إشارة WebRTC غير متوقعة.');
    }

    final peer = await _peer(peerUid);
    if (type == 'offer') {
      final sdp = payload['sdp'];
      final descriptionType = payload['type'];
      if (sdp is! String || descriptionType != 'offer') {
        throw StateError('عرض WebRTC غير صالح.');
      }
      await peer.setRemoteDescription(
        RTCSessionDescription(sdp, descriptionType as String),
      );
      _remoteDescriptionReady.add(peerUid);
      await _flushCandidates(peerUid, peer);
      final answer = await peer.createAnswer();
      await peer.setLocalDescription(answer);
      await _signaling.sendSignal(
        roomId: roomId,
        targetUid: peerUid,
        signalType: 'answer',
        payload: {'sdp': answer.sdp, 'type': answer.type},
      );
    } else if (type == 'answer') {
      final sdp = payload['sdp'];
      final descriptionType = payload['type'];
      if (sdp is! String || descriptionType != 'answer') {
        throw StateError('رد WebRTC غير صالح.');
      }
      await peer.setRemoteDescription(
        RTCSessionDescription(sdp, descriptionType as String),
      );
      _remoteDescriptionReady.add(peerUid);
      await _flushCandidates(peerUid, peer);
    } else if (type == 'candidate') {
      final candidateText = payload['candidate'];
      if (candidateText is! String || candidateText.isEmpty) {
        throw StateError('مرشح ICE غير صالح.');
      }
      final candidate = RTCIceCandidate(
        candidateText,
        payload['sdpMid'] as String?,
        payload['sdpMLineIndex'] as int?,
      );
      if (_remoteDescriptionReady.contains(peerUid)) {
        await peer.addCandidate(candidate);
      } else {
        _pendingCandidates.putIfAbsent(peerUid, () => []).add(candidate);
      }
    } else {
      throw StateError('نوع إشارة WebRTC غير معروف.');
    }

    await _signaling.acknowledgeSignal(
      roomId: roomId,
      signalId: signalId,
    );
  }

  Future<void> _flushCandidates(
    String peerUid,
    RTCPeerConnection peer,
  ) async {
    final queued = _pendingCandidates.remove(peerUid) ?? [];
    for (final candidate in queued) {
      await peer.addCandidate(candidate);
    }
  }

  Future<void> setMicrophoneMuted(bool muted) {
    _ensureActive();
    return _audio.setMicrophoneMuted(muted);
  }

  void _reportError(Object error) {
    onError?.call(error);
  }

  Future<void> leave() async {
    if (_disposed) return;
    await _participantsSub?.cancel();
    await _signalsSub?.cancel();
    _participantsSub = null;
    _signalsSub = null;
    for (final peerUid in _activePeers.toList()) {
      await _audio.closePeer(peerUid);
    }
    _activePeers.clear();
    _pendingCandidates.clear();
    _remoteDescriptionReady.clear();
    if (_started) {
      await _signaling.leaveRoom(roomId);
      _started = false;
    }
    await _audio.dispose();
    _disposed = true;
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('تم إغلاق منسق الصوت لهذه الغرفة.');
    }
  }
}
