import 'package:djparty/page/lobby/GenerateShare.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('generate', () {
    testWidgets('Page has a title', (tester) async {
      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(
              home: GeneratorScreen(loggedUser: user, db: firestore)));

      await tester.pumpWidget(testWidget);

      final appBarFinder = find.text('Create Party');

      expect(appBarFinder, findsOneWidget);
    });

    testWidgets('insert party title', (tester) async {
      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(
              home: GeneratorScreen(loggedUser: user, db: firestore)));

      await tester.pumpWidget(testWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Party');
      final btnFinder = find.text('Confirm');
      await tester.tap(btnFinder);

      expect(find.byType(GeneratorScreen), findsOneWidget);
    });
  });
}
