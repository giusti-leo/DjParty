import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/auth/SignUp.dart';

void main() {
  testWidgets('LoginPage has a title', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: Login()));

    await tester.pumpWidget(loginWidget);

    // Create the Finders.
    final appBarFinder = find.text('Create Dj Party account');

    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('LoginPage try to log with email and password', (tester) async {
    Widget loginWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: SignIn()));

    await tester.pumpWidget(loginWidget);

    final signinBtnFinder = find.text('Sign in');

    await tester.enterText(find.byType(TextFormField).first, 'ric@ric.it');
    await tester.enterText(find.byType(TextFormField).last, 'Password');

    await tester.tap(signinBtnFinder);

    // Create the Finders.
    final appBarFinder = find.text('Create Dj Party account');

    expect(find.byType(SignIn), findsOneWidget);
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
