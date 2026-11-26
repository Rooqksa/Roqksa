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
    {'name': 'المضيف', 'icon': Icons.star_rounded, 'host': true},
    {'name': 'سارة', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'متصل', 'icon': Icons.person_rounded, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add_rounded, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add_rounded, 'host': false},
    {'name': 'مقعد فارغ', 'icon': Icons.add_rounded, 'host': false},
  ];

  static const Color aqua = Color(0xFF53E4D0);
  static const Color violet = Color(0xFF8A68E8);
  static const Color background = Color(0xFF17112D);

  void openChat() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF211A3D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(18, 20, 18, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('دردشة الغرفة', style: TextStyle(color: aqua, fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...messages.map((message) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: const Color(0xFF342A58), borderRadius: BorderRadius.circular(14)),
                  child: Text(message, style: const TextStyle(color: Colors.white)),
                ),
              )),
              Row(children: [
                Expanded(child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true, fillColor: const Color(0xFF30264D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                )),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: aqua),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() => messages.add(controller.text.trim()));
                      setSheetState(() {});
                      controller.clear();
                    }
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _showRoomDetails() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF211A3D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('معلومات الغرفة', style: TextStyle(color: aqua, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          _RoomDetailRow(icon: Icons.meeting_room_outlined, label: 'اسم الغرفة', value: widget.roomName),
          const _RoomDetailRow(icon: Icons.people_alt_outlined, label: 'المقاعد', value: '12 مقعداً'),
          const _RoomDetailRow(icon: Icons.headphones_rounded, label: 'المستمعون', value: '128 مستمعاً'),
          _RoomDetailRow(icon: Icons.favorite_border_rounded, label: 'الإعجابات', value: '$likes'),
          const SizedBox(height: 12),
          const Text('الأرقام والتفاعلات المعروضة حالياً تجريبية ومحلية.', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    );
  }

  void openGifts() {
    const gifts = ['🌹', '❤️', '🌷', '💎', '👑', '🎁', '🦋', '⭐'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF211A3D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('اختر هديتك', style: TextStyle(color: aqua, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            children: gifts.map((gift) => InkWell(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('اخترت الهدية $gift')));
              },
              child: Center(child: Text(gift, style: const TextStyle(fontSize: 35))),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(children: [
        const Positioned.fill(child: _RoomBackdrop()),
        SafeArea(child: Column(children: [
          _buildHeader(),
          _buildRoomBanner(),
          _buildAnnouncement(),
          const SizedBox(height: 8),
          _buildSeatHeading(),
          Expanded(child: _buildSeats()),
          _buildChatPreview(),
          _buildControls(),
        ])),
      ]),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 3, 10, 8),
    child: Row(children: [
      _roundIcon(Icons.arrow_back_rounded, () => Navigator.pop(context)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.roomName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('غرفة صوتية عامة  •  #2048', style: TextStyle(color: Colors.white60, fontSize: 10)),
      ])),
      _headerStat(Icons.headphones_rounded, '128'),
      const SizedBox(width: 7),
      _roundIcon(Icons.share_outlined, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مشاركة الغرفة قريباً')))),
      const SizedBox(width: 5),
      _roundIcon(Icons.more_horiz_rounded, _showRoomDetails),
    ]),
  );

  Widget _roundIcon(IconData icon, VoidCallback onTap) => Material(
    color: Colors.white.withValues(alpha: .10),
    shape: const CircleBorder(),
    child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: SizedBox(width: 38, height: 38, child: Icon(icon, color: Colors.white, size: 19))),
  );

  Widget _headerStat(IconData icon, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(18)),
    child: Row(children: [Icon(icon, color: aqua, size: 15), const SizedBox(width: 5), Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]),
  );

  Widget _buildRoomBanner() => Container(
    margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF6846B8), Color(0xFF30235E), Color(0xFF1C5570)]),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: aqua.withValues(alpha: .35)),
      boxShadow: [BoxShadow(color: violet.withValues(alpha: .22), blurRadius: 18, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.graphic_eq_rounded, color: aqua, size: 28)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('مجلس الأصدقاء', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text('أهلاً وسهلاً بكم في Roqksa', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 10)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1DCA9D), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, color: Colors.white, size: 6), SizedBox(width: 5), Text('مباشر', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
    ]),
  );

  Widget _buildAnnouncement() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 15),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(color: const Color(0xFF352A55).withValues(alpha: .85), borderRadius: BorderRadius.circular(13)),
    child: const Row(children: [
      Icon(Icons.campaign_rounded, color: Color(0xFFFFD36E), size: 18),
      SizedBox(width: 8),
      Expanded(child: Text('مرحباً بكم! احترموا الجميع واستمتعوا بوقتكم 💜', style: TextStyle(fontSize: 10, color: Colors.white))),
    ]),
  );

  Widget _buildSeatHeading() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
    child: Row(children: [
      const Icon(Icons.mic_rounded, color: aqua, size: 17),
      const SizedBox(width: 7),
      const Text('مقاعد المتحدثين', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      const Spacer(),
      Text('اضغط على مقعد فارغ للانضمام', style: TextStyle(color: Colors.white.withValues(alpha: .52), fontSize: 9)),
    ]),
  );

  Widget _buildSeats() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
    itemCount: seats.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 10, childAspectRatio: 1.02),
    itemBuilder: (context, index) {
      final seat = seats[index];
      final isHost = seat['host'] as bool;
      final isEmpty = seat['name'] == 'مقعد فارغ';
      final isSelected = selectedSeat == index;
      return InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          if (isEmpty) {
            setState(() { selectedSeat = index; requestedSeat = index; });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال طلب الصعود إلى المقعد رقم ${index + 1}')));
          } else {
            setState(() => selectedSeat = index);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('هذا ${seat['name']}'), duration: const Duration(seconds: 1)));
          }
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: isSelected ? .13 : .055), borderRadius: BorderRadius.circular(17), border: Border.all(color: isHost || isSelected ? aqua.withValues(alpha: .8) : Colors.white.withValues(alpha: .08), width: isHost || isSelected ? 1.5 : 1)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Stack(alignment: Alignment.bottomRight, children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: isHost ? [const Color(0xFFFFD76D), const Color(0xFF9D70E8)] : [const Color(0xFF6E5BA8), const Color(0xFF332A59)])),
                child: CircleAvatar(radius: 24, backgroundColor: isEmpty ? const Color(0xFF292342) : const Color(0xFF46376F), child: Icon(seat['icon'] as IconData, color: isEmpty ? Colors.white54 : Colors.white, size: 23)),
              ),
              if (!isEmpty) Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF36D6A2), shape: BoxShape.circle, border: Border.all(color: background, width: 1.5))),
            ]),
            const SizedBox(height: 6),
            Text(isHost ? '👑 المضيف' : requestedSeat == index ? 'بانتظار الموافقة' : seat['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHost ? const Color(0xFFFFD36E) : requestedSeat == index ? aqua : Colors.white70, fontSize: 9, fontWeight: isHost || requestedSeat == index ? FontWeight.bold : FontWeight.normal)),
            if (isHost) const Text('مالك الغرفة', style: TextStyle(color: Colors.white38, fontSize: 8)),
          ]),
        ),
      );
    },
  );

  Widget _buildChatPreview() => InkWell(
    onTap: openChat,
    child: Container(
      height: 43, margin: const EdgeInsets.fromLTRB(14, 0, 14, 7), padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF282044), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: .07))),
      child: Row(children: [
        const Icon(Icons.chat_bubble_rounded, color: aqua, size: 17),
        const SizedBox(width: 8),
        Expanded(child: Text(messages.isEmpty ? 'ابدأ الدردشة...' : messages.last, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10))),
        const Text('الدردشة', style: TextStyle(color: aqua, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_left_rounded, color: aqua, size: 17),
      ]),
    ),
  );

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 13),
    decoration: BoxDecoration(color: const Color(0xFF201936), borderRadius: const BorderRadius.vertical(top: Radius.circular(23)), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .08)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _RoomButton(icon: Icons.chat_rounded, label: 'الدردشة', onTap: openChat),
      _RoomButton(icon: Icons.card_giftcard_rounded, label: 'الهدايا', onTap: openGifts),
      _RoomButton(icon: Icons.favorite_rounded, label: '$likes', color: const Color(0xFFFF6D9B), onTap: () => setState(() => likes++)),
      _RoomButton(icon: micRequested ? Icons.mic_rounded : Icons.mic_none_rounded, label: micRequested ? 'إلغاء الطلب' : 'طلب المايك', color: aqua, onTap: () => setState(() => micRequested = !micRequested)),
      _RoomButton(icon: Icons.exit_to_app_rounded, label: 'خروج', onTap: () => Navigator.pop(context)),
    ]),
  );
}

class _RoomDetailRow extends StatelessWidget {
  const _RoomDetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      const SizedBox(width: 2),
      Icon(icon, color: const Color(0xFF53E4D0), size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );
}

class _RoomButton extends StatelessWidget {
  const _RoomButton({required this.icon, required this.label, required this.onTap, this.color = const Color(0xFF53E4D0)});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 43, height: 43, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: .25))), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    ),
  );
}

class _RoomBackdrop extends StatelessWidget {
  const _RoomBackdrop();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF302052), Color(0xFF17112D), Color(0xFF102B3A)])),
    child: CustomPaint(painter: _RoomGlowPainter(), child: const SizedBox.expand()),
  );
}

class _RoomGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = const RadialGradient(colors: [Color(0x333CBAAE), Color(0x003CBAAE)]).createShader(Rect.fromCircle(center: Offset(size.width * .82, size.height * .42), radius: size.width * .55));
    canvas.drawRect(Offset.zero & size, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
