// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roqksa/main.dart';

void main() {
  testWidgets('Roqksa demo sign-in opens profile and messages tabs', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    expect(find.text('Roqksa'), findsOneWidget);
    expect(find.text('دخول تجريبي'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@roqksa.app');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('دخول تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);

    await tester.tap(find.text('الرسائل').first);
    await tester.pumpAndSettle();
    expect(find.text('صديق Roqksa'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'غير موجود');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد محادثات مطابقة'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'صديق');
    await tester.pumpAndSettle();
    expect(find.text('صديق Roqksa'), findsOneWidget);
  });

  testWidgets('sign-in form blocks empty and invalid email input', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('دخول تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('أدخل بريداً إلكترونياً صحيحاً'), findsOneWidget);
    expect(find.text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('دخول تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('أدخل بريداً إلكترونياً صحيحاً'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'user@invalid');
    await tester.tap(find.text('دخول تجريبي'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل بريداً إلكترونياً صحيحاً'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);
  });

  testWidgets('account creation requires a display name', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ليس لديك حساب؟ إنشاء حساب جديد'));
    await tester.pumpAndSettle();

    expect(find.text('إنشاء حساب تجريبي'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), 'new@roqksa.app');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    await tester.tap(find.text('إنشاء حساب تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('اكتب اسماً من حرفين على الأقل'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);
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
    await tester.tap(find.text('إنشاء حساب تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    await tester.tap(find.text('إنشاء حساب تجريبي'));
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('profile editor rejects short names and saves valid names', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@roqksa.app');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('دخول تجريبي'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل الملف الشخصي'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'س');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('الاسم يجب أن يكون حرفين على الأقل'), findsOneWidget);
    expect(find.text('عضو Roqksa'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'مستخدم جديد');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حفظ'));
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('مستخدم جديد'), findsOneWidget);
    expect(find.text('عضو Roqksa'), findsNothing);
  });

}
