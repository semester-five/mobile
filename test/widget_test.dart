import 'package:flutter_test/flutter_test.dart';

import 'package:face_locker/main.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
