import 'package:flutter_test/flutter_test.dart';
import 'package:roqksa/main.dart';

void main() {
  testWidgets('Roqksa opens profile and messages tabs', (tester) async {
    await tester.pumpWidget(const RoqksaApp());
    await tester.pumpAndSettle();

    expect(find.text('Roqksa'), findsOneWidget);

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);

    await tester.tap(find.text('الرسائل').first);
    await tester.pumpAndSettle();
    expect(find.text('صديق Roqksa'), findsOneWidget);
  });
}
