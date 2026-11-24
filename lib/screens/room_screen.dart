// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.roomName});

  final String roomName;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool micRequested = false;
  int likes = 128;
  int selectedSeat = -1;
  int requestedSeat = -1;

  final List<String> messages = [
    'أهلاً بالجميع في روكسا ❤️',
    'نورتوا المجلس يا أصدقاء',
    'مساء الخير على الجميع 🌹',
  ];

  final List<Map<String, dynamic>> seats = [
    {'name': 'المضيف', 'icon': Icons.star, 'host': true},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'متصل', 'icon': Icons.person, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add, 'host': false},
  ];

  static const gold = Color(0xFFE9BD68);
  static const background = Color(0xFF10101E);

  void openChat() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF201D2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'دردشة الغرفة',
                    style: TextStyle(
                      color: gold,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...messages.map(
                    (message) => Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF343044),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(message),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF302B3D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: gold),
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            setState(() {
                              messages.add(controller.text.trim());
                            });
                            setSheetState(() {});
                            controller.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showRoomDetails() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF201D2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الغرفة',
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            _RoomDetailRow(icon: Icons.meeting_room_outlined, label: 'اسم الغرفة', value: widget.roomName),
            _RoomDetailRow(icon: Icons.people_alt_outlined, label: 'المقاعد', value: '12 مقعداً'),
            _RoomDetailRow(icon: Icons.headphones_rounded, label: 'المستمعون', value: '128 مستمعاً'),
            _RoomDetailRow(icon: Icons.favorite_border_rounded, label: 'الإعجابات', value: '$likes'),
            const SizedBox(height: 12),
            const Text(
              'الأرقام والتفاعلات المعروضة حالياً تجريبية ومحلية.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void openGifts() {
    final gifts = ['🌹', '❤️', '🌷', '💎', '👑', '🎁', '🦋', '⭐'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF201D2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر هديتك',
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              children: gifts.map((gift) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('اخترت الهدية $gift'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(gift, style: const TextStyle(fontSize: 35)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const Positioned.fill(child: _StarBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildRoomInfo(),
                const SizedBox(height: 12),
                _buildAnnouncement(),
                const SizedBox(height: 15),
                Expanded(child: _buildSeats()),
                _buildChatPreview(),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: gold),
          ),
          Expanded(
            child: Text(
              widget.roomName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: gold,
              ),
            ),
          ),
          IconButton(
            onPressed: _showRoomDetails,
            icon: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF252235).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: gold.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF6C4A24),
            child: Icon(Icons.mic, color: gold),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مجلس الأصدقاء',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'أهلاً وسهلاً بكم في Roqksa',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.headphones, color: gold, size: 18),
          const SizedBox(width: 5),
          const Text('128', style: TextStyle(color: gold)),
        ],
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3825).withValues(alpha: .55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.campaign, color: gold, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'مرحباً بكم في غرفة Roqksa، نتمنى لكم وقتاً ممتعاً',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeats() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: seats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 12,
        childAspectRatio: .92,
      ),
      itemBuilder: (context, index) {
        final seat = seats[index];
        final isHost = seat['host'] as bool;
        final isEmpty = seat['name'] == 'مقعد فارغ';
        final isSelected = selectedSeat == index;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (isEmpty) {
              setState(() {
                selectedSeat = index;
                requestedSeat = index;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال طلب الصعود إلى المقعد رقم ${index + 1}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              setState(() => selectedSeat = index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('هذا ${seat['name']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHost || isSelected ? gold : const Color(0xFF76658A),
                    width: isHost || isSelected ? 2.5 : 1.3,
                  ),
                  boxShadow: isHost
                      ? [
                          BoxShadow(
                            color: gold.withValues(alpha: .25),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: isEmpty
                      ? const Color(0xFF282438)
                      : const Color(0xFF51416D),
                  child: Icon(
                    seat['icon'] as IconData,
                    size: 29,
                    color: isEmpty ? Colors.white54 : gold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (isHost)
                const Text(
                  '👑 المضيف',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  requestedSeat == index
                      ? 'طلبك قيد الانتظار'
                      : seat['name'] as String,
                  style: TextStyle(
                    color: requestedSeat == index ? gold : Colors.white70,
                    fontSize: 11,
                    fontWeight: requestedSeat == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatPreview() {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252235),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat, color: gold, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              messages.isEmpty ? 'ابدأ الدردشة...' : messages.last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: openChat,
            child: const Text('الدردشة', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF201D2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF5B4934))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RoomButton(
            icon: Icons.chat_bubble_outline,
            label: 'الدردشة',
            onTap: openChat,
          ),
          _RoomButton(
            icon: Icons.card_giftcard,
            label: 'الهدايا',
            onTap: openGifts,
          ),
          _RoomButton(
            icon: Icons.favorite,
            label: '$likes',
            color: Colors.pinkAccent,
            onTap: () => setState(() => likes++),
          ),
          _RoomButton(
            icon: micRequested ? Icons.mic : Icons.mic_off,
            label: micRequested ? 'إلغاء الطلب' : 'طلب المايك',
            color: gold,
            onTap: () => setState(() => micRequested = !micRequested),
          ),
          _RoomButton(
            icon: Icons.exit_to_app,
            label: 'خروج',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _RoomDetailRow extends StatelessWidget {
  const _RoomDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE9BD68), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RoomButton extends StatelessWidget {
  const _RoomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFFE9BD68),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF393143),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarBackground extends StatelessWidget {
  const _StarBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF171629),
              Color(0xFF10101E),
              Color(0xFF171321),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDCC58D).withValues(alpha: .45);

    final stars = [
      Offset(size.width * .12, size.height * .12),
      Offset(size.width * .82, size.height * .18),
      Offset(size.width * .65, size.height * .38),
      Offset(size.width * .20, size.height * .54),
      Offset(size.width * .90, size.height * .68),
      Offset(size.width * .42, size.height * .80),
      Offset(size.width * .08, size.height * .90),
      Offset(size.width * .72, size.height * .93),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
