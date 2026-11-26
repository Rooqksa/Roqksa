import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_visit_service.dart';

class ProfileVisitorsScreen extends StatelessWidget {
  const ProfileVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('من زار ملفي')),
        body: user == null
            ? const Center(child: Text('سجّل الدخول لعرض زوار ملفك.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ProfileVisitService().watchMyVisitors(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('تعذر تحميل الزيارات. تحقق من اتصالك وصلاحيات قاعدة البيانات.'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('لا توجد زيارات حتى الآن.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final visit = docs[index].data();
                      final visitorId = visit['visitorId'] as String? ?? docs[index].id;
                      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance.collection('publicProfiles').doc(visitorId).get(),
                        builder: (context, profileSnapshot) {
                          final profile = profileSnapshot.data?.data();
                          final name = profile?['displayName'] as String? ?? 'عضو Roqksa';
                          final photoUrl = profile?['photoUrl'] as String?;
                          final timestamp = visit['lastVisitedAt'];
                          final date = timestamp is Timestamp ? timestamp.toDate() : null;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                              child: photoUrl == null || photoUrl.isEmpty ? const Icon(Icons.person_outline) : null,
                            ),
                            title: Text(name),
                            subtitle: Text(date == null ? 'زاره ملفك' : 'آخر زيارة: ${date.toLocal()}'),
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
