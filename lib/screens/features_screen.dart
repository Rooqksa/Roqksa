// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'admin_permissions_screen.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  static const bg = Color(0xFF101C2B);
  static const surface = Color(0xFF192A3B);
  static const gold = Color(0xFFFFC86B);
  static const turquoise = Color(0xFF27D7D0);

  final posts = <Map<String, dynamic>>[
    {'name': 'صديق Roqksa', 'vip': 8, 'text': 'مساء الخير يا أجمل مجتمع ❤️', 'likes': 12},
    {'name': 'عضو مميز', 'vip': 4, 'text': 'نلتقي الليلة في الغرف الصوتية 🌙', 'likes': 7},
  ];

  final visitors = [
    {'name': 'أحمد', 'vip': 12, 'time': 'الآن'},
    {'name': 'سارة', 'vip': 7, 'time': 'منذ 15 دقيقة'},
    {'name': 'محمد', 'vip': 3, 'time': 'منذ ساعة'},
    {'name': 'نورة', 'vip': 17, 'time': 'أمس'},
  ];

  final products = [
    {'name': 'وردة', 'price': 10, 'icon': Icons.local_florist_rounded, 'color': Color(0xFFE879A5)},
    {'name': 'قلب ذهبي', 'price': 50, 'icon': Icons.favorite_rounded, 'color': gold},
    {'name': 'تاج ملكي', 'price': 150, 'icon': Icons.workspace_premium_rounded, 'color': turquoise},
    {'name': 'سيارة فاخرة', 'price': 500, 'icon': Icons.directions_car_rounded, 'color': Color(0xFF59B7C7)},
  ];

  final featureGroups = const [
    ('الحساب والملف الشخصي', 'التسجيل، الملف الشخصي، الصور، الغلاف، الأصدقاء والمتابعون', Icons.account_circle_rounded),
    ('الحالات والمنشورات', 'حالات شبيهة بواتساب، صور، منشورات، تعليقات وإعجابات', Icons.dynamic_feed_rounded),
    ('الرسائل الخاصة', 'محادثات، صور، فيديوهات قصيرة وإشعارات لقطات الشاشة حسب دعم الجهاز', Icons.chat_rounded),
    ('الغرف الصوتية', 'مقاعد، متحدثون، مستمعون، دردشة، خلفيات ومستويات الغرف', Icons.mic_rounded),
    ('القبائل والمنافسات', 'قادة ونواب وأعضاء ودعوات ومستويات وترتيب وتحديات', Icons.groups_rounded),
    ('المتجر والمحفظة', 'عملات وهدايا واشتراكات وسجل عمليات ومعاملات آمنة', Icons.wallet_rounded),
    ('مركز العروض والمنجم', 'عروض ومكافآت ونظام استثمار المنجم وفق قواعد واضحة', Icons.diamond_rounded),
    ('استوديو الصوت والفنون', 'تسجيل ونشر القصائد والغناء والعزف والكوميديا وتحسين الصوت', Icons.graphic_eq_rounded),
    ('المشاهدة والمحتوى', 'فتح YouTube والخدمات الرسمية للمشاهدة الجماعية', Icons.ondemand_video_rounded),
    ('الألقاب والشارات', 'فنان، مصمم، كوميدي، شاعر، مبدع، أسطورة وألقاب مخصصة', Icons.workspace_premium_rounded),
    ('لوحة المالك والإدارة', 'إدارة الأعضاء والرتب والإعلانات والغرف والمحفظة وسجل التدقيق', Icons.admin_panel_settings_rounded),
    ('الأمان والخصوصية', 'مصادقة وصلاحيات وبلاغات وحظر وحماية الحساب والمعاملات', Icons.shield_rounded),
  ];

  final games = const [
    _GameInfo(name: 'كيرم', subtitle: 'تحدَّ أصدقاءك في لعبة الكيرم', icon: Icons.sports_esports_rounded, color: Color(0xFFE8A45B)),
    _GameInfo(name: 'لودو', subtitle: 'سباق الحظ والذكاء بين الأصدقاء', icon: Icons.casino_rounded, color: Color(0xFF67C6A3)),
    _GameInfo(name: 'جاكارو مجنونة', subtitle: 'نسخة مليئة بالمفاجآت والتحديات', icon: Icons.bolt_rounded, color: Color(0xFFE879A5)),
    _GameInfo(name: 'جاكارو عادية', subtitle: 'النسخة الكلاسيكية مع الأصدقاء', icon: Icons.style_rounded, color: Color(0xFF7FA9E8)),
    _GameInfo(name: 'كاندي', subtitle: 'لعبة خفيفة وتحديات ممتعة', icon: Icons.emoji_events_rounded, color: Color(0xFFB68BE8)),
    _GameInfo(name: 'من سيربح المليون؟', subtitle: 'أسئلة متنوعة ومنافسة على القمة', icon: Icons.quiz_rounded, color: gold),
  ];

  Color vipColor(int n) {
    const colors = [
      Color(0xFF9E9E9E), Color(0xFF8D9AA6), Color(0xFF69A7C8),
      Color(0xFF4E91D8), Color(0xFF4776D0), Color(0xFF6957D8),
      Color(0xFF9256D8), Color(0xFFB04FC4), Color(0xFFD34F9A),
      Color(0xFFE65376), Color(0xFFE66A4C), Color(0xFFE99A3D),
      Color(0xFFD6B43D), Color(0xFF9AB94A), Color(0xFF55B78A),
      Color(0xFF39BDBD), Color(0xFFFFC86B),
    ];
    return colors[n.clamp(1, 17).toInt() - 1];
  }

  Widget vip(int n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: vipColor(n).withValues(alpha: .15),
          border: Border.all(color: vipColor(n)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('VIP $n', style: TextStyle(color: vipColor(n), fontWeight: FontWeight.bold, fontSize: 11)),
      );

  Widget panel(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16)),
        child: child,
      );

  Widget heading(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      );

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: bg,
          child: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('مجتمع Roqksa', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                heading('الألعاب الجماعية', Icons.sports_esports_rounded),
                const SizedBox(height: 6),
                const Text(
                  'اضغط على أي لعبة لتجربة نسخة محلية قابلة للعب. اللعب مع الأصدقاء أونلاين سيُفعّل بعد تجهيز خادم الألعاب.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildGamesGrid(),
                const SizedBox(height: 22),
                heading('جميع خدمات Roqksa', Icons.apps_rounded),
                const SizedBox(height: 6),
                const Text('هذه خارطة الوظائف المعتمدة؛ تظهر هنا للتوضيح، وتُفعّل الخدمات تدريجياً بعد ربط الخوادم وقواعد البيانات.', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 10),
                _buildFeatureGroups(),
                const SizedBox(height: 10),
                Card(
                  color: surface,
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings_rounded, color: gold),
                    title: const Text('معاينة إدارة صلاحيات الإداريين', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('واجهة تجريبية — الحفظ غير مفعّل حتى ربط صلاحيات المالك بالخادم', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPermissionsScreen())),
                  ),
                ),
                const SizedBox(height: 22),
                heading('من زارني', Icons.visibility),
                const SizedBox(height: 10),
                panel(Column(
                  children: visitors.map((v) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Row(children: [
                      Text(v['name'] as String),
                      const SizedBox(width: 8),
                      vip(v['vip'] as int),
                    ]),
                    subtitle: Text(v['time'] as String, style: const TextStyle(color: Colors.white54)),
                  )).toList(),
                )),
                const SizedBox(height: 20),
                heading('مستويات VIP', Icons.workspace_premium),
                const SizedBox(height: 10),
                panel(Wrap(spacing: 7, runSpacing: 8, children: List.generate(17, (i) => vip(i + 1)))),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: heading('المنشورات', Icons.dynamic_feed)),
                  TextButton(onPressed: addPost, child: const Text('منشور جديد', style: TextStyle(color: gold))),
                ]),
                ...posts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: panel(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const CircleAvatar(child: Icon(Icons.person)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p['name'] as String)),
                        vip(p['vip'] as int),
                      ]),
                      const SizedBox(height: 12),
                      Text(p['text'] as String),
                      Row(children: [
                        IconButton(
                          onPressed: () => setState(() => p['likes'] = (p['likes'] as int) + 1),
                          icon: const Icon(Icons.favorite_border, color: Color(0xFFE879A5)),
                        ),
                        Text('${p['likes']} إعجاب'),
                      ]),
                    ],
                  )),
                )),
                const SizedBox(height: 12),
                heading('متجر Roqksa', Icons.shopping_bag),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.15, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return panel(Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p['icon'] as IconData, color: p['color'] as Color, size: 32),
                        const SizedBox(height: 8),
                        Text(p['name'] as String),
                        Text('${p['price']} عملة', style: const TextStyle(color: gold)),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('شراء تجريبي: ${p['name']}')),
                          ),
                          child: const Text('شراء تجريبي'),
                        ),
                      ],
                    ));
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'ملاحظة: هذه بيانات تجريبية. الزيارات والمنشورات والمشتريات الفعلية تحتاج خادماً وقاعدة بيانات ونظام دفع.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFeatureGroups() => Column(
        children: featureGroups.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: turquoise.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.$3, color: turquoise),
            ),
            title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item.$2, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ),
            trailing: const Text('ضمن الخطة', style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
            isThreeLine: true,
          ),
        )).toList(),
      );

  Widget _buildGamesGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: games.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.18,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final game = games[index];
          return Material(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameScreen(gameName: game.name, gameIndex: index))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: game.color.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(game.icon, color: game.color),
                      ),
                      const Spacer(),
                      const Icon(Icons.play_circle_fill_rounded, color: turquoise, size: 24),
                    ]),
                    const Spacer(),
                    Text(game.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(game.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Future<void> addPost() async {
    final c = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('منشور جديد'),
          content: TextField(controller: c, maxLines: 4, maxLength: 300,
            decoration: const InputDecoration(hintText: 'اكتب ما تريد مشاركته')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('نشر')),
          ],
        ),
      ),
    );
    c.dispose();
    if (value != null && value.isNotEmpty && mounted) {
      setState(() => posts.insert(0, {'name': 'أنا', 'vip': 1, 'text': value, 'likes': 0}));
    }
  }
}

class _GameInfo {
  const _GameInfo({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
}
