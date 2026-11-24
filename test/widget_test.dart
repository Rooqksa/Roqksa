import 'package:material_ui/material_ui.dart';
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
  });
}
