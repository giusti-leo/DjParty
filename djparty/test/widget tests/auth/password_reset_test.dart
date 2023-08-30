import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/auth/ResetPassword.dart';

void main() {
  testWidgets('LoginPage has a title', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: ResetPassword()));

    await tester.pumpWidget(loginWidget);

    // Create the Finders.
    final appBarFinder = find.text('Password Reset');

    expect(appBarFinder, findsOneWidget);
  });

  testWidgets('LoginPage try to log with email and password', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: ResetPassword()));

    await tester.pumpWidget(loginWidget);

    final resetBtnFinder = find.text('Reset password');

    await tester.enterText(find.byType(TextFormField).first, 'ric@ric.it');

    await tester.tap(resetBtnFinder);

    expect(find.byType(ResetPassword), findsOneWidget);
  });
}
