import 'package:flutter/material.dart';
import '../widgets/room_card.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roqksa', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF633CCB), Color(0xFFB05CE8)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('صوتك يجمعنا', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('ادخل غرفتك المفضلة وتعرّف على أصدقاء جدد'),
                SizedBox(height: 14),
                Row(children: [
                  Icon(Icons.graphic_eq_rounded, size: 30),
                  SizedBox(width: 8),
                  Text('غرف صوتية مباشرة', style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('الغرف النشطة الآن', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          RoomCard(
            title: 'سوالف آخر الليل',
            subtitle: 'ضحك • تعارف • أصدقاء',
            listeners: 128,
            color: const Color(0xFF553B91),
            onTap: () => _openRoom(context, 'سوالف آخر الليل'),
          ),
          RoomCard(
            title: 'مجلس Roqksa',
            subtitle: 'أهلاً بالجميع في مجلسنا',
            listeners: 76,
            color: const Color(0xFF245B70),
            onTap: () => _openRoom(context, 'مجلس Roqksa'),
          ),
          RoomCard(
            title: 'موسيقى وهدوء',
            subtitle: 'مساحة للاسترخاء والدردشة',
            listeners: 42,
            color: const Color(0xFF79405D),
            onTap: () => _openRoom(context, 'موسيقى وهدوء'),
          ),
          const SizedBox(height: 18),
          const Text('قريباً في Roqksa', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('الهدايا، العملات، مستويات VIP، والرسائل الخاصة — ستضاف في المراحل التالية.',
              style: TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (value) => setState(() => selectedTab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.mic_rounded), label: 'الغرف'),
          NavigationDestination(icon: Icon(Icons.card_giftcard_rounded), label: 'الهدايا'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }

  void _openRoom(BuildContext context, String roomName) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoomScreen(roomName: roomName)));
  }
}
