import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

Future<void> main() async {
  testWidgets('SignIn page has a title', (tester) async {
    Widget signInWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: SignIn()));

    await tester.pumpWidget(signInWidget);

    // Create the Finders.
    final appBarFinder = find.text('Login');

    expect(find.byType(SignIn), findsOneWidget);
  });

  testWidgets('Enter e-mail and password', (tester) async {
    Widget signInWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: SignIn()));

    await tester.pumpWidget(signInWidget);
    final signinBtnFinder = find.text('Sign in');

    // Create the Finders.
    await tester.enterText(find.byType(TextFormField).first, 'ric@ric.it');
    await tester.enterText(find.byType(TextFormField).last, 'pizza');
    await tester.tap(signinBtnFinder);
    await tester.pump();

    expect(find.byType(SignIn), findsOneWidget);
  });
}
