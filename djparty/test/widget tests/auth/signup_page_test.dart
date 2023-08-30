import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/auth/SignUp.dart';

void main() {
  testWidgets('LoginPage has a title', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: SignIn()));

    await tester.pumpWidget(loginWidget);

    // Create the Finders.
    final appBarFinder = find.text('Registration');

    expect(appBarFinder, findsOneWidget);
  });

  testWidgets('LoginPage try to log with email and password', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: SignIn()));

    await tester.pumpWidget(loginWidget);

    final signinBtnFinder = find.text('Register');

    await tester.enterText(find.byType(TextFormField).first, 'ric@ric.it');
    await tester.enterText(find.byType(TextFormField).last, 'Password');

    await tester.tap(signinBtnFinder);

    expect(find.byType(SignIn), findsOneWidget);
  });
}
