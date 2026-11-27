import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// عميل آمن لقناة إشارات WebRTC.
/// لا يكتب هذا العميل مباشرةً إلى مستندات الإشارات؛ جميع عمليات الإرسال
/// تمر عبر Firebase Callable Functions للتحقق من هوية وعضوية الطرفين.
class VoiceSignalingService {
  VoiceSignalingService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> joinRoom(String roomId) async {
    final result = await _functions
        .httpsCallable('joinVoiceRoom')
        .call<Map<String, dynamic>>({'roomId': roomId});
    return result.data;
  }

  Future<void> leaveRoom(String roomId) async {
    await _functions
        .httpsCallable('leaveVoiceRoom')
        .call<void>({'roomId': roomId});
  }

  Future<String> sendSignal({
    required String roomId,
    required String targetUid,
    required String signalType,
    required Map<String, dynamic> payload,
  }) async {
    final result = await _functions
        .httpsCallable('sendVoiceSignal')
        .call<Map<String, dynamic>>({
      'roomId': roomId,
      'targetUid': targetUid,
      'signalType': signalType,
      'payload': payload,
    });
    final signalId = result.data['signalId'];
    if (signalId is! String || signalId.isEmpty) {
      throw StateError('لم يُرجع خادم الصوت معرّف الإشارة.');
    }
    return signalId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchIncomingSignals({
    required String roomId,
    required String uid,
  }) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('rtcSignals')
        .where('targetUid', isEqualTo: uid)
        .snapshots();
  }

  Future<void> acknowledgeSignal({
    required String roomId,
    required String signalId,
  }) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('rtcSignals')
        .doc(signalId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchParticipants(
    String roomId,
  ) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }
}
