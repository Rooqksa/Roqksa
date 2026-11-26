// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/profile_visit_service.dart';

/// Public member profile. Opening this screen records a visit for the owner.
class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _profile;

  @override
  void initState() {
    super.initState();
    _profile = FirebaseFirestore.instance
        .collection('publicProfiles')
        .doc(widget.userId)
        .get();
    ProfileVisitService().recordVisit(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _profile,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل الملف الشخصي.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!.data();
            if (data == null) {
              return const Center(child: Text('هذا الملف الشخصي غير متاح.'));
            }
            final photoUrl = data['photoUrl'] as String?;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 42)
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data['displayName'] as String? ?? 'عضو Roqksa',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(data['bio'] as String? ?? ''),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
