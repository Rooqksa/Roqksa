// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqksa/main.dart';
import 'package:roqksa/screens/profile_screen.dart';
import 'package:roqksa/screens/game_screen.dart';
import 'package:roqksa/screens/room_screen.dart';

void main() {
  testWidgets('sign-in form blocks empty and invalid email input', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('أدخل بريداً إلكترونياً صحيحاً'), findsOneWidget);
    expect(find.text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('أدخل بريداً إلكترونياً صحيحاً'), findsOneWidget);
  });

  testWidgets('account creation requires a display name', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ليس لديك حساب؟ إنشاء حساب جديد'));
    await tester.pumpAndSettle();

    expect(find.text('إنشاء حساب'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), 'new@roqksa.app');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    await tester.tap(find.text('إنشاء حساب'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب اسماً من حرفين على الأقل'), findsOneWidget);
  });

  testWidgets('account creation requires matching password confirmation', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ليس لديك حساب؟ إنشاء حساب جديد'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'مستخدم جديد');
    await tester.enterText(find.byType(TextFormField).at(1), 'new@roqksa.app');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '654321');
    await tester.tap(find.text('إنشاء حساب'));
    await tester.pumpAndSettle();

    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
  });

  testWidgets('profile editor validates and updates the displayed name', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ProfileScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تعديل الملف الشخصي'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'س');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    expect(find.text('الاسم يجب أن يكون حرفين على الأقل'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'مستخدم جديد');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    expect(find.text('مستخدم جديد'), findsOneWidget);
  });

  testWidgets('million quiz ends after the final question and can restart', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(gameName: 'من سيربح المليون؟', gameIndex: 5),
    ));

    expect(find.text('السؤال 1 من 5'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();
    }

    expect(find.text('انتهت المسابقة!'), findsOneWidget);
    expect(find.text('السؤال 6'), findsNothing);

    await tester.tap(find.text('العب من جديد'));
    await tester.pumpAndSettle();
    expect(find.text('السؤال 1 من 5'), findsOneWidget);
  });



  testWidgets('all six local game prototypes open their expected controls', (tester) async {
    const games = [
      ('كيرم', 0, 'اضرب القرص'),
      ('لودو', 1, 'ارمِ النرد'),
      ('جاكارو مجنونة', 2, 'ارمِ النرد'),
      ('جاكارو عادية', 3, 'ارمِ النرد'),
      ('كاندي', 4, 'كاندي: اجمع الحلوى'),
      ('من سيربح المليون؟', 5, 'السؤال 1 من 5'),
    ];

    for (final game in games) {
      await tester.pumpWidget(MaterialApp(
        home: GameScreen(gameName: game.$1, gameIndex: game.$2),
      ));
      await tester.pumpAndSettle();

      expect(find.text('نسخة تجريبية محلية'), findsOneWidget,
          reason: 'The local-play notice should appear in ${game.$1}.');
      expect(find.text(game.$3), findsOneWidget,
          reason: 'The expected game control should appear in ${game.$1}.');
    }
  });

 
  testWidgets('room controls update local mic, seat request and likes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(
      home: RoomScreen(roomName: 'غرفة الاختبار'),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('غرفة الاختبار'), findsOneWidget);
    await tester.tap(find.text('ميكروفون'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

    await tester.tap(find.text('مقعد فارغ').first);
    await tester.pumpAndSettle();
    expect(find.text('بانتظار الموافقة'), findsOneWidget);

    // Dismiss the seat-request SnackBar so it cannot cover the bottom controls.
    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('إعجاب'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('129'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
 
}
