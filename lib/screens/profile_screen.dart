// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const gold = Color(0xFFE9BD68);
  static const purple = Color(0xFF9B72FF);

  String displayName = 'عضو Roqksa';
  String bio = 'أهلاً بكم في عالمي الصوتي ❤️';
  String country = 'السعودية';

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: displayName);
    final bioController = TextEditingController(text: bio);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                maxLength: 24,
                decoration: const InputDecoration(labelText: 'الاسم الظاهر'),
              ),
              TextField(
                controller: bioController,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'النبذة الشخصية'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        if (nameController.text.trim().isNotEmpty) {
          displayName = nameController.text.trim();
        }
        bio = bioController.text.trim();
      });
    }
    nameController.dispose();
    bioController.dispose();
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
                colors: [Color(0xFF6842A9), Color(0xFF29213F)],
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
                        backgroundColor: Color(0xFF40345D),
                        child: Icon(Icons.person_rounded, size: 48, color: gold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 15, color: Color(0xFF241B32)),
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
                    const Icon(Icons.location_on_outlined, size: 15, color: gold),
                    const SizedBox(width: 4),
                    Text(country, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 12),
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
          const Text('المحفظة والإنجازات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _ProfileMenuTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'محفظتي',
            subtitle: 'رصيد العملات: 0',
            color: gold,
            onTap: () => _showInfo('المحفظة', 'المحفظة حالياً واجهة تجريبية. لن يتم تنفيذ أي عملية دفع قبل إضافة نظام دفع آمن.'),
          ),
          _ProfileMenuTile(
            icon: Icons.emoji_events_outlined,
            title: 'المستويات والإنجازات',
            subtitle: 'اكتشف تقدمك ومكافآتك',
            color: purple,
            onTap: () => _showInfo('الإنجازات', 'سيتم ربط المستويات والإنجازات بنشاط الحساب بعد إنشاء قاعدة البيانات.'),
          ),
          _ProfileMenuTile(
            icon: Icons.card_giftcard_outlined,
            title: 'الهدايا المستلمة',
            subtitle: 'شاهد هدايا أصدقائك',
            color: const Color(0xFFE58BA7),
            onTap: () => _showInfo('الهدايا', 'سجل الهدايا سيظهر هنا بعد ربط الغرف والخادم.'),
          ),
          const SizedBox(height: 14),
          _ProfileMenuTile(
            icon: Icons.shield_outlined,
            title: 'الخصوصية والأمان',
            subtitle: 'إدارة الحظر وخصوصية الحساب',
            color: Colors.lightBlueAccent,
            onTap: () => _showInfo('الخصوصية والأمان', 'ستتم إضافة أدوات الحظر والتحكم بالخصوصية قبل إطلاق الحسابات الفعلية.'),
          ),
          _ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'المساعدة والدعم',
            subtitle: 'تواصل مع فريق Roqksa',
            color: Colors.lightGreenAccent,
            onTap: () => _showInfo('الدعم', 'قنوات الدعم ستُضاف قبل الإطلاق العام.'),
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
        color: const Color(0xFF211C31),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE9BD68), size: 19),
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
      color: const Color(0xFF211C31),
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
