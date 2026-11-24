import 'package:flutter/material.dart';
import '../widgets/room_card.dart';
import 'room_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  int selectedCategory = 0;

  static const Color gold = Color(0xFFE9BD68);
  static const Color purple = Color(0xFF9B72FF);

  final List<Map<String, dynamic>> rooms = [
    {
      'title': 'سوالف آخر الليل',
      'subtitle': 'ضحك • تعارف • أصدقاء',
      'listeners': 128,
      'color': Color(0xFF6545A5),
      'category': 0,
    },
    {
      'title': 'مجلس Roqksa',
      'subtitle': 'أهلاً بالجميع في مجلسنا',
      'listeners': 76,
      'color': Color(0xFF286779),
      'category': 1,
    },
    {
      'title': 'موسيقى وهدوء',
      'subtitle': 'مساحة للاسترخاء والدردشة',
      'listeners': 42,
      'color': Color(0xFF8A4968),
      'category': 2,
    },
    {
      'title': 'تحدي الأسئلة',
      'subtitle': 'شاركنا التحدي واربح قلوباً',
      'listeners': 91,
      'color': Color(0xFF986A32),
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
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 22),
        _buildSectionTitle('لحظات الأصدقاء', 'عرض الكل'),
        const SizedBox(height: 12),
        _buildMomentsRow(),
        const SizedBox(height: 23),
        _buildSectionTitle('الغرف النشطة الآن', 'كل الغرف', onTap: () {
          setState(() => selectedTab = 1);
        }),
        const SizedBox(height: 12),
        ...rooms.take(3).map(_buildRoomCard),
        const SizedBox(height: 10),
        _buildCreateRoomButton(),
      ],
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
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF7146C7), Color(0xFF39265F), Color(0xFF29203F)],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'صوتك يجمعنا',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          const Text(
            'ادخل غرفتك المفضلة وتعرّف على أصدقاء جدد',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, size: 29, color: gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'غرف صوتية ومساحات تجمعنا',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton.tonal(
                onPressed: () => setState(() => selectedTab = 1),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .16),
                  foregroundColor: Colors.white,
                ),
                child: const Text('اكتشف'),
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
    const moments = [
      ('أضف لحظتك', Icons.add_rounded, Color(0xFF7953C7)),
      ('صديق 1', Icons.person_rounded, Color(0xFFB56B83)),
      ('صديق 2', Icons.person_rounded, Color(0xFF4C8190)),
      ('صديق 3', Icons.person_rounded, Color(0xFF98713F)),
      ('صديق 4', Icons.person_rounded, Color(0xFF6E8A5C)),
    ];

    return SizedBox(
      height: 91,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: moments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final moment = moments[index];
          return SizedBox(
            width: 62,
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
                    backgroundColor: moment.$3,
                    child: Icon(moment.$2, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  moment.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          );
        },
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

  Widget _buildComingSoonPage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: purple.withValues(alpha: .18),
              child: Icon(icon, color: gold, size: 38),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.6)),
          ],
        ),
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
  Widget buildResults(BuildContext context) => _buildMatches();

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches();

  Widget _buildMatches() {
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
            close(context, null);
            onOpen(name);
          },
        );
      }).toList(),
    );
  }
}
