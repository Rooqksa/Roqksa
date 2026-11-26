// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../widgets/room_card.dart';
import 'room_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'features_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  int selectedCategory = 0;
  final List<String> myMoments = [];

  static const Color gold = Color(0xFFFFC86B);
  static const Color purple = Color(0xFF27D7D0);

  final List<Map<String, dynamic>> rooms = [
    {
      'title': 'سوالف آخر الليل',
      'subtitle': 'ضحك • تعارف • أصدقاء',
      'listeners': 128,
      'color': Color(0xFF287E91),
      'category': 0,
    },
    {
      'title': 'مجلس Roqksa',
      'subtitle': 'أهلاً بالجميع في مجلسنا',
      'listeners': 76,
      'color': Color(0xFF267C78),
      'category': 1,
    },
    {
      'title': 'موسيقى وهدوء',
      'subtitle': 'مساحة للاسترخاء والدردشة',
      'listeners': 42,
      'color': Color(0xFF66558D),
      'category': 2,
    },
    {
      'title': 'تحدي الأسئلة',
      'subtitle': 'شاركنا التحدي واربح قلوباً',
      'listeners': 91,
      'color': Color(0xFF987044),
      'category': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 18,
          title: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [purple, Color(0xFFCB78E8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'Roqksa',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'البحث',
              onPressed: _showSearch,
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: _showNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 5),
          ],
        ),
        body: _buildSelectedPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (value) => setState(() => selectedTab = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none_rounded),
              selectedIcon: Icon(Icons.mic_rounded),
              label: 'الغرف',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'الرسائل',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (selectedTab) {
      case 1:
        return _buildRoomsPage();
      case 2:
        return const MessagesScreen();
      case 3:
        return const ProfileScreen();
      case 4:
        return const FeaturesScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 26),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 20),
        _buildSectionTitle('العب مع أصدقائك', 'كل الألعاب', onTap: () {
          setState(() => selectedTab = 4);
        }),
        const SizedBox(height: 10),
        _buildQuickGames(),
        const SizedBox(height: 22),
        _buildSectionTitle('لحظات الأصدقاء', 'عرض الكل'),
        const SizedBox(height: 11),
        _buildMomentsRow(),
        const SizedBox(height: 22),
        _buildSectionTitle('غرف صوتية مقترحة', 'كل الغرف', onTap: () {
          setState(() => selectedTab = 1);
        }),
        const SizedBox(height: 11),
        ...rooms.take(3).map(_buildRoomCard),
        const SizedBox(height: 8),
        _buildCreateRoomButton(),
      ],
    );
  }

  Widget _buildQuickGames() {
    const games = <({String name, String subtitle, IconData icon, Color color, int index})>[
      (name: 'كيرم', subtitle: 'تحدي الأصدقاء', icon: Icons.sports_esports_rounded, color: Color(0xFFFFA64D), index: 0),
      (name: 'لودو', subtitle: 'ارمِ النرد', icon: Icons.casino_rounded, color: Color(0xFF57D6A2), index: 1),
      (name: 'جاكارو مجنونة', subtitle: 'حماس وتحدي', icon: Icons.bolt_rounded, color: Color(0xFFFF6E9D), index: 2),
      (name: 'جاكارو عادية', subtitle: 'اللعبة الكلاسيكية', icon: Icons.style_rounded, color: Color(0xFF7EABFF), index: 3),
      (name: 'كاندي', subtitle: 'اجمع الحلوى', icon: Icons.emoji_food_beverage_rounded, color: Color(0xFFB58BFF), index: 4),
      (name: 'من سيربح المليون؟', subtitle: 'اختبر معلوماتك', icon: Icons.emoji_events_rounded, color: Color(0xFFFFD166), index: 5),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .92,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      itemBuilder: (context, index) {
        final game = games[index];
        return Material(
          color: const Color(0xFF172B3B),
          borderRadius: BorderRadius.circular(19),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(gameName: game.name, gameIndex: game.index),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(7, 12, 7, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: game.color.withValues(alpha: .30)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    game.color.withValues(alpha: .19),
                    const Color(0xFF172B3B),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: .17),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(game.icon, color: game.color, size: 29),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    game.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomsPage() {
    const categories = ['الكل', 'تعارف', 'مجالس', 'هدوء'];
    final visibleRooms = rooms.where((room) {
      return selectedCategory == 0 || room['category'] == selectedCategory - 1;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text(
          'اكتشف الغرف',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'اختر مجلسك وانضم إلى الأصدقاء',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = selectedCategory == index;
              return ChoiceChip(
                label: Text(categories[index]),
                selected: selected,
                onSelected: (_) => setState(() => selectedCategory = index),
                selectedColor: purple,
                backgroundColor: const Color(0xFF252235),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        ...visibleRooms.map(_buildRoomCard),
        if (visibleRooms.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('لا توجد غرف في هذا التصنيف حالياً')),
          ),
        _buildCreateRoomButton(),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF12AFAE), Color(0xFF087B91), Color(0xFF173C58)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF7AF4E9).withValues(alpha: .30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16CFC4).withValues(alpha: .20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            top: -34,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF8BFFC4), size: 8),
                        SizedBox(width: 6),
                        Text('مجتمعك الآن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.graphic_eq_rounded, color: Color(0xFFFFD27A), size: 32),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'هنا تبدأ\nأجمل السوالف',
                style: TextStyle(fontSize: 29, height: 1.12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              const Text(
                'ادخل غرفة صوتية، شارك لحظتك، وتعرّف على أصدقاء جدد',
                style: TextStyle(color: Color(0xD1FFFFFF), height: 1.45, fontSize: 13),
              ),
              const SizedBox(height: 19),
              Row(
                children: [
                  FilledButton(
                    onPressed: () => setState(() => selectedTab = 1),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD27A),
                      foregroundColor: const Color(0xFF173C58),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text('اكتشف الغرف', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  const Text('🎙️  صوت • أصدقاء • متعة', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action, {VoidCallback? onTap}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onTap ?? () => setState(() => selectedTab = 1),
          child: Text(action, style: const TextStyle(color: gold)),
        ),
      ],
    );
  }

  Widget _buildMomentsRow() {
    final items = <({String title, IconData icon, Color color, String? message})>[
      (
        title: myMoments.isEmpty ? 'أضف لحظتك' : 'لحظتك',
        icon: myMoments.isEmpty ? Icons.add_rounded : Icons.person_rounded,
        color: const Color(0xFF168F9B),
        message: myMoments.isEmpty ? null : myMoments.last,
      ),
      (title: 'صديق 1', icon: Icons.person_rounded, color: const Color(0xFFB76E83), message: 'مساء الورد 🌹'),
      (title: 'صديق 2', icon: Icons.person_rounded, color: const Color(0xFF4C8190), message: 'أهلاً بأصدقاء Roqksa'),
      (title: 'صديق 3', icon: Icons.person_rounded, color: const Color(0xFF98713F), message: 'يوم جميل للجميع'),
      (title: 'صديق 4', icon: Icons.person_rounded, color: const Color(0xFF6E8A5C), message: 'نلتقي في الغرف'),
    ];

    return SizedBox(
      height: 91,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 62,
            child: InkWell(
              onTap: () {
                if (index == 0) {
                  _showMomentComposer();
                } else {
                  _showMoment(item.title, item.message ?? '');
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.7),
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: item.color,
                      child: Icon(item.icon, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMomentComposer() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('أضف لحظتك'),
        content: TextField(
          controller: controller,
          maxLength: 180,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'ماذا تود أن تشارك أصدقاءك؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() => myMoments.add(value));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('نشر'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showMoment(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return RoomCard(
      title: room['title'] as String,
      subtitle: room['subtitle'] as String,
      listeners: room['listeners'] as int,
      color: room['color'] as Color,
      onTap: () => _openRoom(room['title'] as String),
    );
  }

  Widget _buildCreateRoomButton() {
    return OutlinedButton.icon(
      onPressed: _showCreateRoomInfo,
      icon: const Icon(Icons.add_circle_outline_rounded),
      label: const Text('إنشاء غرفة جديدة'),
      style: OutlinedButton.styleFrom(
        foregroundColor: gold,
        side: BorderSide(color: gold.withValues(alpha: .5)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }


  void _openRoom(String roomName) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomScreen(roomName: roomName)),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _RoomSearchDelegate(
        rooms: rooms,
        onOpen: _openRoom,
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ستصل إشعاراتك هنا بعد ربط خدمة الإشعارات.')),
    );
  }

  void _showCreateRoomInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء غرفة'),
        content: const Text(
          'واجهة إنشاء الغرفة ستُفعّل بعد إضافة الحسابات والخادم وقواعد صلاحيات المضيفين.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _RoomSearchDelegate extends SearchDelegate<void> {
  _RoomSearchDelegate({required this.rooms, required this.onOpen});

  final List<Map<String, dynamic>> rooms;
  final ValueChanged<String> onOpen;

  @override
  String get searchFieldLabel => 'ابحث عن غرفة';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _buildMatches(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches(context);

  Widget _buildMatches(BuildContext buildContext) {
    final matches = rooms.where((room) {
      return (room['title'] as String).contains(query.trim());
    }).toList();

    if (matches.isEmpty) {
      return const Center(child: Text('لا توجد غرف مطابقة'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: matches.map((room) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: room['color'] as Color,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
          title: Text(room['title'] as String),
          subtitle: Text(room['subtitle'] as String),
          trailing: const Icon(Icons.chevron_left),
          onTap: () {
            final name = room['title'] as String;
            close(buildContext, null);
            onOpen(name);
          },
        );
      }).toList(),
    );
  }
}
