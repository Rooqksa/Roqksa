// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_visitors_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String displayName = 'عضو Roqksa';
  String bio = 'أهلاً بكم في عالمي الصوتي ❤️';
  String country = 'السعودية';
  int? age;
  String? gender;
  bool hideCountry = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final privateDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final publicDoc = await FirebaseFirestore.instance.collection('publicProfiles').doc(user.uid).get();
      final privateData = privateDoc.data() ?? {};
      final publicData = publicDoc.data() ?? {};
      if (!mounted) return;
      setState(() {
        displayName = (privateData['displayName'] ?? publicData['displayName'] ?? displayName) as String;
        bio = (privateData['bio'] ?? publicData['bio'] ?? bio) as String;
        country = (publicData['country'] ?? privateData['country'] ?? country) as String;
        hideCountry = (publicData['hideCountry'] ?? privateData['hideCountry'] ?? false) as bool;
        age = privateData['age'] as int?;
        gender = privateData['gender'] as String?;
      });
    } catch (_) {}
  }

  Future<void> _editProfile() async {
    final result = await showDialog<_ProfileEditResult>(
      context: context,
      builder: (_) => _ProfileEditDialog(
        initialName: displayName,
        initialBio: bio,
        initialCountry: country,
        initialHideCountry: hideCountry,
        initialAge: age,
        initialGender: gender,
      ),
    );

    if (result == null || !mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      final now = FieldValue.serverTimestamp();
      batch.set(FirebaseFirestore.instance.collection('users').doc(user.uid), {
        'uid': user.uid, 'displayName': result.name, 'bio': result.bio,
        'country': result.country, 'hideCountry': result.hideCountry,
        'age': result.age, 'gender': result.gender, 'updatedAt': now,
      }, SetOptions(merge: true));
      batch.set(FirebaseFirestore.instance.collection('publicProfiles').doc(user.uid), {
        'uid': user.uid, 'displayName': result.name, 'bio': result.bio,
        'country': result.hideCountry ? null : result.country, 'hideCountry': result.hideCountry,
        'updatedAt': now,
      }, SetOptions(merge: true));
      await batch.commit();
      if (!mounted) return;
      setState(() {
        displayName = result.name; bio = result.bio; country = result.country;
        hideCountry = result.hideCountry; age = result.age; gender = result.gender;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات الحساب.')));
    } on FirebaseException catch (error) {
      if (mounted) _showInfo('تعذر الحفظ', 'راجع صلاحيات قاعدة البيانات: ${error.code}');
    }
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF292929);
    const muted = Color(0xFF969696);
    const page = Color(0xFFF3F5F8);
    const mint = Color(0xFF43D9B1);
    final actions = <({String title, IconData icon, Color color, String message})>[
      (title: 'المستوى', icon: Icons.workspace_premium_rounded, color: Color(0xFF45D9A8), message: 'تفاصيل مستوى العضوية ستظهر هنا.'),
      (title: 'مستوى اللعبة', icon: Icons.emoji_events_rounded, color: Color(0xFFFF896F), message: 'مستوى اللعبة ومكافآته.'),
      (title: 'التأثير', icon: Icons.diamond_rounded, color: Color(0xFF9285F6), message: 'مؤشر التأثير والتفاعل.'),
      (title: 'شارة ولقب', icon: Icons.stars_rounded, color: Color(0xFFFFC34E), message: 'الألقاب والشارات المتاحة.'),
      (title: 'مكان السي بي', icon: Icons.favorite_rounded, color: Color(0xFFF45B9C), message: 'إعدادات مكانك المفضل.'),
      (title: 'الأيدي المميزة', icon: Icons.shield_rounded, color: Color(0xFF39BDEB), message: 'الأرقام المميزة.'),
      (title: 'متجر', icon: Icons.shopping_bag_rounded, color: Color(0xFF38CDAA), message: 'متجر الهدايا والعناصر.'),
      (title: 'شخص غامض', icon: Icons.masks_rounded, color: Color(0xFFB28AF2), message: 'خيارات الظهور والشخصيات.'),
    ];

    Widget menuRow(IconData icon, String title, VoidCallback onTap) {
      return ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: ink, size: 27),
        title: Text(title, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_left, color: Color(0xFFCACACA), size: 27),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: page,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: mint, width: 2)),
                        child: const CircleAvatar(
                          radius: 43,
                          backgroundColor: Color(0xFFE8F4F1),
                          child: Icon(Icons.person_rounded, color: Color(0xFF5C9D8D), size: 48),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Flexible(child: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w900))),
                              const SizedBox(width: 6),
                              const Icon(Icons.male_rounded, color: Color(0xFF55AFFF), size: 22),
                            ]),
                            const SizedBox(height: 5),
                            Text('ID: ${FirebaseAuth.instance.currentUser?.uid.substring(0, 7) ?? '—'}',
                              style: const TextStyle(color: muted, fontSize: 14)),
                            const SizedBox(height: 9),
                            Wrap(spacing: 6, runSpacing: 5, children: const [
                              _ProfilePill(icon: Icons.emoji_events_rounded, label: '4', color: Color(0xFFEBCB87)),
                              _ProfilePill(icon: Icons.favorite, label: '79', color: Color(0xFFF05A67)),
                              _ProfilePill(icon: Icons.diamond_rounded, label: '78', color: Color(0xFF9A58E9)),
                            ]),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'تعديل الملف الشخصي',
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit_outlined, color: ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 14)),
                  ),
                  if (!hideCountry) Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('📍 $country', style: const TextStyle(color: muted, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 23),
                  const Row(children: [
                    Expanded(child: _ProfileStat(value: '—', label: 'المتابعة', icon: Icons.people_outline_rounded)),
                    Expanded(child: _ProfileStat(value: '—', label: 'المعجبون', icon: Icons.favorite_border_rounded)),
                    Expanded(child: _ProfileStat(value: '—', label: 'الزوار', icon: Icons.visibility_outlined)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Row(children: [
                    const Expanded(child: Text('محفظة النقود', style: TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w900))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: const Color(0xFFFF8B28), borderRadius: BorderRadius.circular(20)),
                      child: const Text('قسيمة شراء لأول مرة 🎁', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.chevron_left, color: Color(0xFFCCCCCC)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _MembershipCard(title: 'SVIP', icon: Icons.workspace_premium_rounded, color: Color(0xFFF6D2BC), onTap: () => _showInfo('SVIP', 'مزايا SVIP لم تُفعّل بعد.'))),
                    const SizedBox(width: 12),
                    Expanded(child: _MembershipCard(title: 'VIP', icon: Icons.military_tech_rounded, color: Color(0xFFFFE9A5), onTap: () => _showInfo('VIP', 'مستويات VIP من 1 إلى 17 ستظهر بعد ربط الاشتراكات والتحقق من الدفع.'))),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 18, 10, 17),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 17, crossAxisSpacing: 5, childAspectRatio: .78,
                ),
                itemBuilder: (context, index) {
                  final item = actions[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showInfo(item.title, item.message),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(color: item.color.withValues(alpha: .14), borderRadius: BorderRadius.circular(23)),
                        child: Icon(item.icon, color: item.color, size: 39),
                      ),
                      const SizedBox(height: 8),
                      Text(item.title, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800)),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                menuRow(Icons.card_giftcard_rounded, 'تفاصيل الهدايا', () => _showInfo('تفاصيل الهدايا', 'سجل الهدايا سيظهر هنا بعد ربط خدمة الهدايا.')),
                const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF0F0F0)),
                menuRow(Icons.person_add_alt_1_rounded, 'دعوة الصديق', () => _showInfo('دعوة الصديق', 'سيتم إضافة رابط دعوة خاص بك ومتابعة الدعوات هنا.')),
                const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF0F0F0)),
                menuRow(Icons.visibility_outlined, 'من زارني', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileVisitorsScreen()))),
                const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF0F0F0)),
                menuRow(Icons.article_outlined, 'منشوراتي', () => _showInfo('منشوراتي', 'ستظهر منشوراتك هنا بعد تفعيل خدمة المنشورات.')),
                const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF0F0F0)),
                menuRow(Icons.settings_outlined, 'الإعدادات', () => _showInfo('الإعدادات', 'إعدادات الحساب والخصوصية والأمان.')),
              ]),
            ),
            const SizedBox(height: 18),
            const Center(child: Text('Roqksa', style: TextStyle(color: muted, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.white), const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
    ]),
  );
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.title, required this.icon, required this.color, required this.onTap});
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      height: 100, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(17)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Icon(icon, size: 48, color: const Color(0xFF98612F)),
        Text(title, style: const TextStyle(color: Color(0xFF784628), fontSize: 19, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.name,
    required this.bio,
    required this.country,
    required this.hideCountry,
    required this.age,
    required this.gender,
  });

  final String name;
  final String bio;
  final String country;
  final bool hideCountry;
  final int? age;
  final String? gender;
}

class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({
    required this.initialName,
    required this.initialBio,
    required this.initialCountry,
    required this.initialHideCountry,
    required this.initialAge,
    required this.initialGender,
  });

  final String initialName, initialBio, initialCountry;
  final bool initialHideCountry;
  final int? initialAge;
  final String? initialGender;

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _ageController;
  late String _country;
  late bool _hideCountry;
  String? _gender;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
    _ageController = TextEditingController(text: widget.initialAge?.toString() ?? '');
    _country = widget.initialCountry;
    _hideCountry = widget.initialHideCountry;
    _gender = widget.initialGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        scrollable: true,
        title: const Text('تعديل الملف الشخصي'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 24,
                decoration: const InputDecoration(labelText: 'الاسم الظاهر'),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.length < 2) {
                    return 'الاسم يجب أن يكون حرفين على الأقل';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'النبذة الشخصية'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _country,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'البلد'),
                items: const ['السعودية','الإمارات','الكويت','قطر','البحرين','عُمان','مصر','العراق','الأردن','لبنان','المغرب','الجزائر','تونس','اليمن','السودان','فلسطين','سوريا','تركيا','أخرى']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) { if (v != null) setState(() => _country = v); },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('إخفاء البلد عن الآخرين'),
                value: _hideCountry,
                onChanged: (v) => setState(() => _hideCountry = v),
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العمر'),
                validator: (v) {
                  final raw = v?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  final n = int.tryParse(raw);
                  if (n == null || n < 13 || n > 120) return 'أدخل عمراً صحيحاً من 13 إلى 120';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                  DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  _ProfileEditResult(
                    name: _nameController.text.trim(),
                    bio: _bioController.text.trim(),
                    country: _country,
                    hideCountry: _hideCountry,
                    age: int.tryParse(_ageController.text.trim()),
                    gender: _gender,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF292929), fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Color(0xFF969696), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
