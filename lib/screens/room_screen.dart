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
  final TextEditingController _roomMessageController = TextEditingController();

  @override
  void dispose() {
    _roomMessageController.dispose();
    super.dispose();
  }

  void _sendRoomMessage() {
    final message = _roomMessageController.text.trim();
    if (message.isEmpty) return;
    setState(() => messages.add(message));
    _roomMessageController.clear();
    FocusScope.of(context).unfocus();
  }

  final List<String> messages = [
    'أهلاً بالجميع في روكسا ❤️',
    'نورتوا المجلس يا أصدقاء',
    'مساء الخير على الجميع 🌹',
  ];

  final List<Map<String, dynamic>> seats = [
    {'name': 'أبو نايف', 'icon': Icons.person_rounded, 'host': true, 'emoji': '👑'},
    {'name': 'ليان', 'icon': Icons.headphones_rounded, 'host': false, 'emoji': '🎧'},
    {'name': 'سعود', 'icon': Icons.person_rounded, 'host': false, 'emoji': '🕶️'},
    {'name': 'نوره', 'icon': Icons.person_rounded, 'host': false, 'emoji': '🌸'},
    {'name': 'ماجد', 'icon': Icons.person_rounded, 'host': false, 'emoji': '🌙'},
    {'name': 'الأسطورة', 'icon': Icons.workspace_premium_rounded, 'host': false, 'emoji': '🦁'},
    {'name': 'دانة', 'icon': Icons.person_rounded, 'host': false, 'emoji': '🌼'},
    {'name': 'مقعد فارغ', 'icon': Icons.add_rounded, 'host': false, 'emoji': '➕'},
  ];

  static const Color aqua = Color(0xFFB78CFF);
  static const Color violet = Color(0xFF8B22FF);
  static const Color background = Color(0xFF0C0820);

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
          const SizedBox(height: 3),
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
      const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.workspace_premium_rounded, color: Color(0xFFB66CFF), size: 28)),
      const Text('Roqksa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19)),
      const SizedBox(width: 7),
      const Icon(Icons.verified_rounded, color: Color(0xFF9C5BFF), size: 17),
      const Spacer(),
      _roundIcon(Icons.arrow_back_rounded, () => Navigator.pop(context)),
      _headerStat(Icons.headphones_rounded, '264'),
      const SizedBox(width: 6),
      _roundIcon(Icons.share_outlined, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مشاركة الغرفة قريباً')))),
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
      gradient: const LinearGradient(colors: [Color(0xFF26104B), Color(0xFF160D32), Color(0xFF32105C)]),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xFF7543B5).withValues(alpha: .55)),
      boxShadow: [BoxShadow(color: violet.withValues(alpha: .22), blurRadius: 18, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(width: 58, height: 58, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D20C9), Color(0xFF210A4A)]), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFB96BFF))), child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD36E), size: 34)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('👑  ${widget.roomName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text('أهلاً وسهلاً بالجميع', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 11)),
        const SizedBox(height: 4),
        const Text('👥 264   |   🔥 12.5K', style: TextStyle(color: Colors.white70, fontSize: 10)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8D19F5), Color(0xFF4B0DA8)]), borderRadius: BorderRadius.circular(22)), child: const Column(children: [Row(children: [Icon(Icons.circle, color: Color(0xFF38F18D), size: 7), SizedBox(width: 5), Text('مباشر', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]), SizedBox(height: 3), Text('00:24:17', style: TextStyle(color: Colors.white, fontSize: 10))])),
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
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    itemCount: seats.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 9, crossAxisSpacing: 7, childAspectRatio: .72),
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
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isHost ? const Color(0xFFB45CFF) : const Color(0xFF5B8DFF)).withValues(alpha: .5), blurRadius: 13)], gradient: LinearGradient(colors: isHost ? [const Color(0xFFFFD76D), const Color(0xFFB45CFF)] : [const Color(0xFFFF72C6), const Color(0xFF5B8DFF)])),
                child: CircleAvatar(radius: 30, backgroundColor: isEmpty ? const Color(0xFF1A1234) : const Color(0xFF30204E), child: isEmpty ? const Icon(Icons.add_rounded, color: Colors.white, size: 28) : Text(seat['emoji'] as String, style: const TextStyle(fontSize: 27))),
              ),
              if (!isEmpty) Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF36D6A2), shape: BoxShape.circle, border: Border.all(color: background, width: 1.5))),
            ]),
            const SizedBox(height: 7),
            Text(isHost ? '👑 المضيف' : requestedSeat == index ? 'بانتظار الموافقة' : seat['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isHost ? const Color(0xFFFFD36E) : requestedSeat == index ? aqua : Colors.white70, fontSize: 10, fontWeight: isHost || requestedSeat == index ? FontWeight.bold : FontWeight.normal)),
            if (isHost) const Text('مالك الغرفة', style: TextStyle(color: Colors.white38, fontSize: 8)),
          ]),
        ),
      );
    },
  );

  Widget _buildChatPreview() => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFF282044),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: aqua.withValues(alpha: .22)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Material(
        color: const Color(0xFF3A2C60),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: openGifts,
          child: const SizedBox(width: 39, height: 39, child: Icon(Icons.card_giftcard_rounded, color: Color(0xFFFFC96B), size: 21)),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: _roomMessageController,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendRoomMessage(),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'اكتب رسالة للأصدقاء...',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF1D1833),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
      ),
      const SizedBox(width: 7),
      Material(
        color: aqua,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _sendRoomMessage,
          child: const SizedBox(width: 39, height: 39, child: Icon(Icons.send_rounded, color: Color(0xFF172A35), size: 19)),
        ),
      ),
    ]),
  );

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
    decoration: BoxDecoration(color: const Color(0xFF201936), borderRadius: const BorderRadius.vertical(top: Radius.circular(23)), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .08)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _RoomButton(icon: Icons.exit_to_app_rounded, label: 'خروج', color: Colors.white, onTap: () => Navigator.pop(context)),
      _RoomButton(icon: Icons.favorite_rounded, label: 'إعجاب', color: Colors.white, onTap: () => setState(() => likes++)),
      _RoomButton(icon: micRequested ? Icons.mic_rounded : Icons.mic_none_rounded, label: 'ميكروفون', color: const Color(0xFFB86BFF), onTap: () => setState(() => micRequested = !micRequested)),
      _RoomButton(icon: Icons.share_rounded, label: 'مشاركة', color: Colors.white, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مشاركة الغرفة قريباً')))),
      _RoomButton(icon: Icons.more_horiz_rounded, label: 'المزيد', color: Colors.white, onTap: _showRoomDetails),
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
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF190A35), Color(0xFF090619), Color(0xFF100923)])),
    child: CustomPaint(painter: _RoomGlowPainter(), child: const SizedBox.expand()),
  );
}

class _RoomGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = const RadialGradient(colors: [Color(0x665D1AA5), Color(0x005D1AA5)]).createShader(Rect.fromCircle(center: Offset(size.width * .82, size.height * .42), radius: size.width * .55));
    canvas.drawRect(Offset.zero & size, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
