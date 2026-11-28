// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/agora_voice_service.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.roomName});
  final String roomName;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _voiceConnecting = false, _voiceJoined = false, _micMuted = false;
  bool speakerEnabled = true;
  int _remoteUsers = 0;
  final AgoraVoiceService _voiceService = AgoraVoiceService();
  int requestedSeat = -1;
  final messageController = TextEditingController();
  final List<String> messages = ['أهلاً وسهلاً بالجميع 🌹', 'نورتوا الغرفة ❤️'];
  static const aqua = Color(0xFF31E4D4);
  static const green = Color(0xFF27D34D);

  @override
  void dispose() {
    _voiceService.leave();
    messageController.dispose();
    super.dispose();
  }

  String _channelNameForRoom(String name) {
    var hash = 0;
    for (final unit in name.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return 'roqksa_room_$hash';
  }

  Future<void> _toggleVoice() async {
    if (_voiceConnecting) return;
    if (_voiceJoined) {
      final nextMuted = !_micMuted;
      try {
        await _voiceService.setMicrophoneMuted(nextMuted);
        if (mounted) setState(() => _micMuted = nextMuted);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تغيير حالة الميكروفون.')),
          );
        }
      }
      return;
    }

    setState(() => _voiceConnecting = true);
    try {
      await _voiceService.join(
        channelName: _channelNameForRoom(widget.roomName),
        onLocalJoin: () {
          if (mounted) setState(() => _voiceJoined = true);
        },
        onRemoteUserJoined: (uid) {
          if (mounted) setState(() => _remoteUsers++);
        },
        onRemoteUserLeft: (uid) {
          if (mounted) setState(() => _remoteUsers = math.max(0, _remoteUsers - 1));
        },
      );
      if (mounted) {
        setState(() => _voiceJoined = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الاتصال بالغرفة الصوتية.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تشغيل الصوت: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _voiceConnecting = false);
    }
  }

  void sendMessage() {
    final value = messageController.text.trim();
    if (value.isEmpty) return;
    setState(() => messages.add(value));
    messageController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF063B4A),
    resizeToAvoidBottomInset: true,
    body: Stack(children: [
      const Positioned.fill(child: _RoomBackdrop()),
      SafeArea(child: Column(children: [
        _header(), _roomBanner(), Expanded(child: _seatsArea()),
        _chatArea(), _bottomBar(),
      ])),
    ]),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
    child: Row(children: [
      _circleButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
      const SizedBox(width: 8),
      const Text('روكسا', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      const Spacer(),
      const Text('💗  نجوم الغرفة', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8), _circleButton(Icons.more_vert, _roomMenu),
    ]),
  );

  Widget _circleButton(IconData icon, VoidCallback onTap) => Material(
    color: Colors.black.withOpacity(.22), shape: const CircleBorder(),
    child: InkWell(onTap: onTap, customBorder: const CircleBorder(),
      child: SizedBox(width: 38, height: 38, child: Icon(icon, color: Colors.white, size: 21))),
  );

  Widget _roomBanner() => Container(
    margin: const EdgeInsets.fromLTRB(15, 3, 15, 7),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF158CEB), Color(0xFF7B19DD), Color(0xFF3A22C6)]),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: const Color(0xFFB9E8FF), width: 1.3),
      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(.35), blurRadius: 15)],
    ),
    child: Row(children: [
      const Text('🎁', style: TextStyle(fontSize: 28)), const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.roomName, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const Text('💎 53   🟢 VIP   •   أهلاً بكم في الغرفة',
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFF20D54B), borderRadius: BorderRadius.circular(20)),
        child: const Text('Lv.1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ]),
  );

  int seatLayout = 0;

  static const _seatLayoutNames = [
    '12',
    '10',
    '8',
    '20',
    '16',
    '14',
    '20 VIP',
    '10 VIP',
    '24',
  ];
  static const _seatCounts = [12, 10, 8, 20, 16, 14, 20, 10, 24];

  void _showSeatLayouts() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        backgroundColor: const Color(0xFFFDFDFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * .86,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
            child: Column(children: [
              const Text('عدد المقاعد',
                style: TextStyle(color: Color(0xFF20212B), fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Expanded(child: GridView.builder(
                itemCount: _seatCounts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 10,
                  childAspectRatio: .82,
                ),
                itemBuilder: (context, i) {
                  final selected = seatLayout == i;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => seatLayout = i),
                    child: Column(children: [
                      Expanded(child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Color(0xFF064354), Color(0xFF087F91), Color(0xFF08AFC1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? const Color(0xFF19D3C6) : Colors.transparent, width: 3),
                        ),
                        child: Stack(children: [
                          if (selected) const Positioned(left: 8, top: 8,
                            child: Icon(Icons.check_circle, color: Color(0xFF19D3C6), size: 28)),
                          ..._seatPoints(i).asMap().entries.map((entry) {
                            final point = entry.value;
                            final speakerSeat = (i == 1 || i == 3 || i == 5) && entry.key < 2;
                            return Align(
                              alignment: Alignment(point.dx * 2 - 1, point.dy * 2 - 1),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  width: (i == 6 || i == 7) && entry.key < 2 ? 25 : 18,
                                  height: (i == 6 || i == 7) && entry.key < 2 ? 25 : 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF102F40),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white54, width: .8),
                                  ),
                                  child: const Icon(Icons.mic, color: Colors.white, size: 10),
                                ),
                                if (speakerSeat)
                                  Text('S${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 6, height: 1)),
                              ]),
                            );
                          }),
                          if (i == 1) const Positioned(left: 0, right: 0, top: 13,
                            child: Icon(Icons.mic, color: Color(0xFFB8FFF4), size: 16)),
                          if (i == 2) const Positioned(left: 0, right: 0, top: 0, bottom: 0,
                            child: Center(child: Icon(Icons.mic, color: Color(0xFFB8FFF4), size: 19))),
                        ]),
                      )),
                      const SizedBox(height: 5),
                      Text(_seatLayoutNames[i], style: TextStyle(
                        color: selected ? const Color(0xFF19CDBF) : Colors.grey.shade600,
                        fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                  );
                },
              )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19CDBF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  List<Offset> _seatPoints(int layout) {
    final count = _seatCounts[layout];
    if (layout == 2) {
      return List.generate(8, (i) {
        final angle = -math.pi / 2 + (2 * math.pi * i / 8);
        return Offset(.5 + .36 * math.cos(angle), .5 + .36 * math.sin(angle));
      });
    }
    if (layout == 1 || layout == 5 || layout == 3 || layout == 7) {
      final remaining = count - 2;
      final columns = layout == 3 ? 6 : 4;
      final rows = (remaining / columns).ceil();
      return [
        const Offset(.38, .12), const Offset(.62, .12),
        ...List.generate(remaining, (i) => Offset(
          ((i % columns) + .5) / columns,
          .38 + ((i ~/ columns) + .5) / rows * .55,
        )),
      ];
    }
    if (layout == 6) {
      const vip = [Offset(.25, .15), Offset(.75, .15), Offset(.25, .43), Offset(.75, .43)];
      return [...vip, ...List.generate(16, (i) => Offset(
        ((i % 6) + .5) / 6, .68 + (i ~/ 6) * .19,
      ))];
    }
    if (layout == 8) {
      return List.generate(24, (i) => Offset(
        ((i % 6) + .5) / 6, ((i ~/ 6) + .5) / 4,
      ));
    }
    final columns = 4;
    final rows = (count / columns).ceil();
    return List.generate(count, (i) => Offset(
      ((i % columns) + .5) / columns,
      ((i ~/ columns) + .5) / rows,
    ));
  }

  Widget _seatsArea() => LayoutBuilder(builder: (context, constraints) {
    final points = _seatPoints(seatLayout);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Column(children: [
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: _showSeatLayouts,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.28),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: aqua.withOpacity(.55)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.event_seat, color: aqua, size: 17),
                const SizedBox(width: 6),
                Text(_seatLayoutNames[seatLayout],
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 17),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Expanded(child: LayoutBuilder(builder: (context, area) {
          final areaW = area.maxWidth;
          final areaH = area.maxHeight;
          return Stack(clipBehavior: Clip.hardEdge, children: [
            for (var i = 0; i < points.length; i++)
              Positioned(
                left: (points[i].dx * areaW - 35).clamp(0.0, areaW - 70).toDouble(),
                top: (points[i].dy * areaH - 39).clamp(0.0, areaH - 78).toDouble(),
                child: SizedBox(
                  width: 70,
                  height: 78,
                  child: _seat(i, 'مقعد ${i + 1}',
                    occupied: i == 0,
                    host: i == 0,
                    locked: i == 1),
                ),
              ),
            if (seatLayout == 2)
              Positioned(
                left: areaW / 2 - 27,
                top: areaH / 2 - 27,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF102D43),
                    border: Border.all(color: aqua, width: 2),
                    boxShadow: [BoxShadow(color: aqua.withOpacity(.4), blurRadius: 16)],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 29),
                ),
              ),
          ]);
        })),
      ]),
    );
  });

  Widget _seat(int index, String name, {bool occupied = false, bool locked = false, bool host = false, String? vip}) =>
    Tooltip(message: locked ? 'مقعد مقفل' : occupied ? name : 'مقعد فارغ',
      child: InkWell(borderRadius: BorderRadius.circular(50), onTap: () {
        if (locked) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا المقعد مقفل')));
        } else if (!occupied) {
          setState(() => requestedSeat = index);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال طلب الصعود إلى المقعد رقم ${index + 1}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('عضو الغرفة: $name')));
        }
      }, child: LayoutBuilder(builder: (context, box) {
        final d = math.min(box.maxWidth * .76, box.maxHeight * .72).clamp(38.0, 82.0).toDouble();
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: d, height: d, decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withOpacity(.17),
            border: Border.all(color: occupied ? aqua.withOpacity(.7) : Colors.white.withOpacity(.10), width: occupied ? 2 : 1),
            boxShadow: occupied ? [BoxShadow(color: aqua.withOpacity(.18), blurRadius: 12)] : null,
          ), child: Center(child: locked ? Icon(Icons.lock_outline, color: Colors.white.withOpacity(.5), size: d * .42)
            : occupied ? Text(index == 0 ? '👨🏻' : '👤', style: TextStyle(fontSize: d * .45))
            : Icon(Icons.add, color: Colors.white.withOpacity(.55), size: d * .55))),
          const SizedBox(height: 4),
          Text(requestedSeat == index ? 'بانتظار الموافقة' : name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: host ? green : Colors.white.withOpacity(.82), fontSize: 10, fontWeight: FontWeight.w600)),
          if (vip != null) Text(vip, style: const TextStyle(color: Color(0xFFB7F7C3), fontSize: 9)),
        ]);
      })),
    );

  Widget _chatArea() => SizedBox(height: MediaQuery.of(context).size.height * .28,
    child: Stack(children: [
      Positioned.fill(child: IgnorePointer(child: Container(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, const Color(0xFF001B28).withOpacity(.72)]))))),
      Column(children: [
        Expanded(child: ListView.builder(reverse: true, padding: const EdgeInsets.fromLTRB(13, 5, 13, 4),
          itemCount: messages.length > 5 ? 5 : messages.length,
          itemBuilder: (context, index) => Align(alignment: Alignment.centerRight, child: Container(
            margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(.36), borderRadius: BorderRadius.circular(14)),
            child: Text(messages[messages.length - 1 - index], textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          )))),
        Padding(padding: const EdgeInsets.fromLTRB(10, 2, 10, 5), child: Row(children: [
          _chatIcon(Icons.chat_bubble_outline, () {}), _chatIcon(Icons.card_giftcard, _giftSheet),
          const SizedBox(width: 6),
          Expanded(child: TextField(controller: messageController, textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.send, onSubmitted: (_) => sendMessage(),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(hintText: 'قل شيئاً...', hintStyle: const TextStyle(color: Colors.white60),
              filled: true, fillColor: Colors.black.withOpacity(.25), isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))),
          _chatIcon(Icons.emoji_emotions_outlined, _emojiSheet),
          _chatIcon(_voiceConnecting ? Icons.hourglass_top_rounded :
            (_voiceJoined && !_micMuted ? Icons.mic_rounded : Icons.mic_off_rounded), _toggleVoice),
          _chatIcon(speakerEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            () async {
              final next = !speakerEnabled;
              if (_voiceJoined) await _voiceService.setSpeakerEnabled(next);
              if (mounted) setState(() => speakerEnabled = next);
            }),
        ])),
      ]),
    ]),
  );

  Widget _chatIcon(IconData icon, VoidCallback onTap) => IconButton(onPressed: onTap,
    icon: Icon(icon, color: Colors.white.withOpacity(.88), size: 24),
    padding: const EdgeInsets.symmetric(horizontal: 5), constraints: const BoxConstraints(minWidth: 38));

  Widget _bottomBar() => Container(padding: const EdgeInsets.fromLTRB(8, 4, 8, 7),
    color: Colors.black.withOpacity(.25),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _bottomAction(Icons.chat_bubble_outline, 'الدردشة', () {}),
      _bottomAction(Icons.card_giftcard, 'الهدايا', _giftSheet, color: const Color(0xFFFF9BCB)),
      _bottomAction(Icons.menu, 'القائمة', _roomMenu),
      _bottomAction(
        _voiceConnecting ? Icons.hourglass_top_rounded :
          (_voiceJoined && !_micMuted ? Icons.mic_rounded : Icons.mic_off_rounded),
        _voiceConnecting ? 'جاري الاتصال' :
          (!_voiceJoined ? 'تشغيل الصوت' : (_micMuted ? 'فتح المايك' : 'كتم المايك')),
        _toggleVoice,
        color: aqua,
      ),
      _bottomAction(Icons.exit_to_app, 'خروج', () => Navigator.pop(context)),
    ]));

  Widget _bottomAction(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) =>
    InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 25), const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ])));

  void _giftSheet() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF073A48),
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Wrap(
      alignment: WrapAlignment.spaceAround, spacing: 18, runSpacing: 18,
      children: ['🌹','❤️','🎁','💎','👑','🦋','⭐','🎉'].map((g) =>
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(g, style: const TextStyle(fontSize: 32)))).toList()))));

  void _emojiSheet() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF073A48),
    builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Wrap(
      spacing: 12, runSpacing: 12, children: ['😀','😂','😍','🥰','😎','👏','👍','❤️','🔥','🌹','🙏','🥳'].map((e) =>
        TextButton(onPressed: () { messageController.text += e; Navigator.pop(ctx); },
          child: Text(e, style: const TextStyle(fontSize: 28)))).toList()))));

  void _roomMenu() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF073A48),
    builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.people, color: aqua), title: const Text('أعضاء الغرفة', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(ctx)),
      ListTile(leading: const Icon(Icons.lock, color: aqua), title: const Text('المقاعد والأقفال', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(ctx)),
      ListTile(leading: const Icon(Icons.card_giftcard, color: aqua), title: const Text('الهدايا', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _giftSheet(); }),
    ])));
}

class _RoomBackdrop extends StatelessWidget {
  const _RoomBackdrop();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoomBackdropPainter(), child: const SizedBox.expand());
}

class _RoomBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF063B4A), Color(0xFF087083), Color(0xFF064252), Color(0xFF001C2A)]).createShader(rect));
    final star = Paint()..color = const Color(0xFFB8F8F4).withOpacity(.42);
    for (int i = 0; i < 220; i++) {
      final x = ((i * 73) % 997) / 997 * size.width;
      final y = ((i * 137) % 1009) / 1009 * size.height * .72;
      canvas.drawCircle(Offset(x, y), i % 7 == 0 ? 1.15 : .55, star);
    }
    final mountain = Path()..moveTo(0, size.height * .78)
      ..lineTo(size.width * .23, size.height * .73)..lineTo(size.width * .40, size.height * .77)
      ..lineTo(size.width * .58, size.height * .68)..lineTo(size.width * .70, size.height * .74)
      ..lineTo(size.width * .84, size.height * .70)..lineTo(size.width, size.height * .76)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(mountain, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF073343), Color(0xFF001723)]).createShader(rect));
    final peak = Path()..moveTo(size.width * .35, size.height)..lineTo(size.width * .50, size.height * .72)
      ..lineTo(size.width * .66, size.height)..close();
    canvas.drawPath(peak, Paint()..color = const Color(0xFF001B2A).withOpacity(.9));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
