import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/lobby/Home.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:mockito/mockito.dart';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Explore Home Widget', (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Home(
                loggedUser: user,
                db: firestore,
                drawerController: drawerController)));

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.byType(Scaffold);

    expect(finder, findsOneWidget);

    expect(find.descendant(of: finder, matching: find.byType(Stack)),
        findsNWidgets(2));
  });

  testWidgets('Sb Home Widget', (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Home(
                loggedUser: user,
                db: firestore,
                drawerController: drawerController)));

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.byType(Scaffold);

    expect(finder, findsOneWidget);

    final stackFinder =
        find.descendant(of: finder, matching: find.byType(Stack));

    expect(stackFinder, findsNWidgets(2));

    var sbFinder = find.descendant(
        of: stackFinder.first,
        matching: find.byType(StreamBuilder<QuerySnapshot>));

    expect(find.descendant(of: sbFinder, matching: find.byType(RichText)),
        findsOneWidget);
  });

  testWidgets('Test Content Expansion Tile', (tester) async {
    String partyCode = '10AAa';

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
                child: HomeRow(
          partyCode,
        ))));

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Container);
    expect(find.text('Party Code : 10AAa'), findsOneWidget);
  });
}
