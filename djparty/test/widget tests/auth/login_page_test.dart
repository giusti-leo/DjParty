import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/auth/Login.dart';

void main() {
  testWidgets('LoginPage has a title', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: Login()));

    await tester.pumpWidget(loginWidget);

    final appBarFinder = find.text('Dj Party');

    expect(appBarFinder, findsOneWidget);
  });

  testWidgets('LoginPage try to log with email and password', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: Login()));

    await tester.pumpWidget(loginWidget);

    final signinBtnFinder = find.text('Sign in');

    await tester.enterText(find.byType(TextFormField).first, 'ric@ric.it');
    await tester.enterText(find.byType(TextFormField).last, 'Password');

    await tester.tap(signinBtnFinder);

    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('Google Login', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: Login()));

    await tester.pumpWidget(loginWidget);

    final signinBtnFinder = find.text('Sign in with Google');
    await tester.tap(signinBtnFinder);

    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('Facebook Login', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: Login()));

    await tester.pumpWidget(loginWidget);

    final signinBtnFinder = find.text('Sign in with Facebook');
    await tester.tap(signinBtnFinder);

    expect(find.byType(Login), findsOneWidget);
  });
}
