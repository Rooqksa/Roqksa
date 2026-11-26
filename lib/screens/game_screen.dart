// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameName, required this.gameIndex});
  final String gameName;
  final int gameIndex;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const bg = Color(0xFF101C2B), panel = Color(0xFF192A3B), aqua = Color(0xFF27D7D0);
  final random = Random();
  int score = 0, turn = 0, dice = 1, a = 0, b = 0, power = 50, question = 0;
  String message = 'ابدأ اللعب واستمتع!';
  static const quiz = [
    ('ما عاصمة المملكة العربية السعودية؟', ['جدة','الرياض','مكة','الدمام'], 1),
    ('كم عدد أيام السنة الكبيسة؟', ['364','365','366','367'], 2),
    ('ما الكوكب الأحمر؟', ['الزهرة','المشتري','المريخ','زحل'], 2),
    ('كم ضلعاً للمثلث؟', ['2','3','4','5'], 1),
    ('ما أكبر محيط في العالم؟', ['الأطلسي','الهندي','المتجمد','الهادئ'], 3),
  ];
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text(widget.gameName), backgroundColor: bg, foregroundColor: Colors.white),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [const Icon(Icons.sports_esports, color: aqua), const SizedBox(width: 10),
            const Expanded(child: Text('نسخة تجريبية محلية', style: TextStyle(fontWeight: FontWeight.bold))),
            Text('النقاط: ' + score.toString(), style: const TextStyle(color: aqua, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 14), _body(), const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
        const SizedBox(height: 12),
        const Text('اللعب على نفس الجهاز للتجربة. اللعب أونلاين مع الأصدقاء يحتاج خادم غرف ومزامنة وسيضاف لاحقاً.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
        TextButton(onPressed: _reset, child: const Text('إعادة اللعبة')),
      ])),
    ),
  );

  Widget _box(Widget child) => Container(padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)), child: child);

  Widget _body() {
    if (widget.gameIndex == 0) return _carrom();
    if (widget.gameIndex == 1 || widget.gameIndex == 2 || widget.gameIndex == 3) return _race();
    if (widget.gameIndex == 4) return _candy();
    return _million();
  }

  Widget _carrom() => _box(Column(children: [
    const Text('كيرم: اختر قوة الضربة ثم اضرب القرص', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    const SizedBox(height: 18),
    Container(height: 205, decoration: BoxDecoration(color: const Color(0xFFB9824D), borderRadius: BorderRadius.circular(14)),
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 170, height: 170, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF603B22), width: 5), shape: BoxShape.circle)),
        const Icon(Icons.album, color: Colors.white, size: 42),
        const Positioned(top: 8, left: 8, child: Icon(Icons.circle_outlined, color: Colors.black, size: 30)),
        const Positioned(top: 8, right: 8, child: Icon(Icons.circle_outlined, color: Colors.black, size: 30)),
        const Positioned(bottom: 8, left: 8, child: Icon(Icons.circle_outlined, color: Colors.black, size: 30)),
        const Positioned(bottom: 8, right: 8, child: Icon(Icons.circle_outlined, color: Colors.black, size: 30)),
      ])),
    Row(children: [const Text('القوة'), Expanded(child: Slider(value: power.toDouble(), min: 10, max: 100, divisions: 9,
      onChanged: (v) => setState(() => power = v.round())))]),
    FilledButton(onPressed: () { final gain = max(0, (power / 20).round() + random.nextInt(3) - 1);
      setState(() { score += gain; message = gain == 0 ? 'لم تدخل القطعة، حاول مرة أخرى.' : 'ضربة ناجحة! حصلت على ' + gain.toString() + ' نقطة.'; }); },
      child: const Text('اضرب القرص')),
  ]));

  Widget _race() => _box(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(widget.gameName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16), _track('أنت', a, aqua), const SizedBox(height: 12), _track('الصديق المحلي', b, Colors.orangeAccent),
    const SizedBox(height: 18), Text('النرد: ' + dice.toString(), textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    FilledButton.icon(onPressed: a >= 30 || b >= 30 ? null : _roll, icon: const Icon(Icons.casino), label: const Text('ارمِ النرد')),
    if (widget.gameIndex == 2) const Text('الوضع المجنون: الرقم 6 يمنح حركة إضافية.', textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white54, fontSize: 12)),
  ]));

  Widget _track(String name, int pos, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(name + ' — ' + pos.toString() + ' / 30'),
    const SizedBox(height: 6),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pos / 30, minHeight: 14,
      color: color, backgroundColor: Colors.white12)),
  ]);

  void _roll() {
    final value = random.nextInt(6) + 1;
    setState(() {
      dice = value;
      if (turn == 0) {
        a = min(30, a + value); score += value;
        message = a >= 30 ? 'مبروك! وصلت إلى النهاية.' : 'تقدمت ' + value.toString() + ' خطوات. دور الصديق.';
        if (widget.gameIndex == 2 && value == 6) message += ' حركة إضافية!';
      } else {
        b = min(30, b + value);
        message = b >= 30 ? 'فاز الصديق في هذه الجولة.' : 'تقدم الصديق ' + value.toString() + ' خطوات. دورك.';
      }
      turn = 1 - turn;
    });
  }

  Widget _candy() => _box(
    Column(
      children: [
        const Text('كاندي: اجمع الحلوى', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(score.toString(), style: const TextStyle(fontSize: 46, color: aqua, fontWeight: FontWeight.w900)),
        const Text('نقطة'),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(9, (i) {
            const sweets = ['🍬', '🍭', '🍫', '🍡', '🍩'];
            return InkWell(
              onTap: () => setState(() {
                score += random.nextInt(3) + 1;
                message = 'جميل! واصل جمع الحلوى.';
              }),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(sweets[i % sweets.length], style: const TextStyle(fontSize: 30))),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        const Text('اضغط على الحلوى لزيادة نقاطك.', style: TextStyle(color: Colors.white54)),
      ],
    ),
  );

  Widget _million() {
    final q = quiz[question % quiz.length];
    return _box(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('السؤال ' + (question + 1).toString(), style: const TextStyle(color: aqua, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), Text(q.$1, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton(onPressed: () => setState(() {
          if (i == q.$3) { score += 100; message = 'إجابة صحيحة! ربحت 100 نقطة تجريبية.'; }
          else { message = 'إجابة غير صحيحة. جرّب السؤال التالي.'; }
          question++;
        }), child: Text(String.fromCharCode(65 + i) + '. ' + q.$2[i])))),
    ]));
  }

  void _reset() => setState(() { score = 0; turn = 0; dice = 1; a = 0; b = 0; power = 50; question = 0; message = 'بدأت لعبة جديدة!'; });
}
