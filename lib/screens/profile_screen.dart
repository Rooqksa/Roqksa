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
  static const gold = Color(0xFFFFC86B);

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
        'country': result.country, 'hideCountry': result.hideCountry,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'حسابي',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: 'الإعدادات',
                onPressed: () => _showInfo(
                  'إعدادات الحساب',
                  'سيتم تفعيل إعدادات الخصوصية والأمان والإشعارات بعد ربط خدمات الحساب.',
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C8992), Color(0xFF1B3546)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: .10)),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 43,
                        backgroundColor: Color(0xFF245064),
                        child: Icon(Icons.person_rounded, size: 48, color: gold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 15, color: Color(0xFF162B3B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(displayName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hideCountry) ...[
                      const Icon(Icons.location_on_outlined, size: 15, color: gold),
                      const SizedBox(width: 4),
                      Text(country, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.verified_user_outlined, size: 15, color: gold),
                    const SizedBox(width: 4),
                    const Text('حساب تجريبي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('تعديل الملف الشخصي'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: .35)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF192A3B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold.withValues(alpha: .18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: gold, size: 19),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'الرتبة والألقاب',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VIP 1',
                        style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _IdentityBadge(label: 'عضو المجتمع', icon: Icons.person_rounded, color: const Color(0xFF5DE0D7)),
                    _IdentityBadge(label: 'محب الألعاب', icon: Icons.sports_esports_rounded, color: const Color(0xFF69B7E8)),
                    _IdentityBadge(label: 'صديق المجتمع', icon: Icons.diversity_3_rounded, color: const Color(0xFFB49BFF)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'الألقاب المعروضة تجريبية؛ منح الألقاب ومستويات VIP الفعلية يتطلب صلاحيات وخدمات خلفية.',
                  style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _ProfileStat(value: '0', label: 'الأصدقاء', icon: Icons.people_outline)),
              SizedBox(width: 10),
              Expanded(child: _ProfileStat(value: '0', label: 'المتابعون', icon: Icons.favorite_border)),
              SizedBox(width: 10),
              Expanded(child: _ProfileStat(value: '1', label: 'المستوى', icon: Icons.workspace_premium_outlined)),
            ],
          ),
          const SizedBox(height: 22),
          const Text('حسابي وخدماتي', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _ProfileMenuTile(
            icon: Icons.visibility_outlined,
            title: 'من الذي رأني',
            subtitle: 'اعرف من زار ملفك الشخصي',
            color: const Color(0xFF5DE0D7),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileVisitorsScreen())),
          ),
          _ProfileMenuTile(
            icon: Icons.article_outlined,
            title: 'منشوراتي',
            subtitle: 'إدارة منشوراتك وتفاعلات الأصدقاء',
            color: const Color(0xFF69B7E8),
            onTap: () => _showInfo('منشوراتي', 'ستظهر منشوراتك هنا بعد تفعيل خدمة المنشورات.'),
          ),
          _ProfileMenuTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'محفظتي',
            subtitle: 'رصيد العملات وسجل العمليات',
            color: gold,
            onTap: () => _showInfo('محفظتي', 'المحفظة حالياً واجهة فقط. لن يتم تنفيذ أي تحويل أو شراء قبل ربط نظام مالي آمن بالخادم.'),
          ),
          _ProfileMenuTile(
            icon: Icons.local_offer_outlined,
            title: 'مركز العروض',
            subtitle: 'العروض والمكافآت المتاحة',
            color: const Color(0xFFFF9D70),
            onTap: () => _showInfo('مركز العروض', 'سيتم عرض العروض الفعلية هنا عند تجهيز نظام العروض.'),
          ),
          _ProfileMenuTile(
            icon: Icons.workspace_premium_outlined,
            title: 'VIP',
            subtitle: 'مزايا واشتراكات VIP',
            color: const Color(0xFFFFD166),
            onTap: () => _showInfo('VIP', 'ستظهر مستويات VIP ومزاياها من 1 إلى 17 بعد ربط الاشتراكات والتحقق من الدفع.'),
          ),
          _ProfileMenuTile(
            icon: Icons.diamond_outlined,
            title: 'استثمار المنجم',
            subtitle: 'منجم العملات والمكافآت',
            color: const Color(0xFFB49BFF),
            onTap: () => _showInfo('استثمار المنجم', 'هذه الخدمة لم تُفعّل بعد. لن نعرض أرباحاً أو نستقبل أموالاً قبل بناء نظام موثوق وآمن لها.'),
          ),
          _ProfileMenuTile(
            icon: Icons.storefront_outlined,
            title: 'المركز التجاري',
            subtitle: 'الهدايا والعناصر والمتجر',
            color: const Color(0xFFFF8EAC),
            onTap: () => _showInfo('المركز التجاري', 'سيتم ربط المتجر بالهدايا والعناصر والعملات بعد تجهيز خدمات الشراء الآمنة.'),
          ),
          _ProfileMenuTile(
            icon: Icons.person_add_alt_1_rounded,
            title: 'ادعو الأصدقاء',
            subtitle: 'شارك Roqksa مع أصدقائك',
            color: const Color(0xFF73D69B),
            onTap: () => _showInfo('ادعو الأصدقاء', 'سيتم إضافة رابط دعوة خاص بك ومتابعة الدعوات هنا.'),
          ),
          _ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'المساعدة',
            subtitle: 'الأسئلة الشائعة والتواصل مع الدعم',
            color: const Color(0xFF76C7F2),
            onTap: () => _showInfo('المساعدة', 'سيتم إضافة مركز المساعدة ووسيلة التواصل مع فريق Roqksa.'),
          ),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            subtitle: 'الخصوصية والأمان والإشعارات',
            color: const Color(0xFFB0BEC5),
            onTap: () => _showInfo('الإعدادات', 'سيتم إضافة إعدادات الحساب والخصوصية والأمان والإشعارات.'),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Roqksa • الإصدار التجريبي',
              style: TextStyle(color: Colors.white.withValues(alpha: .38), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF192A3B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFC86B), size: 19),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF192A3B),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .13),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: const Icon(Icons.chevron_left, color: Colors.white54),
      ),
    );
  }
}
