import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/admin/AdminRanking.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/Home.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:djparty/services/FirebaseRequests.dart';

import '../utils/firebase.dart';

Future<void> main() async {
  late FakeFirebaseFirestore firestore;
  final User user = await getMockedUser();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    firestore = await getFakeFirestoreInstance();
  });

  testWidgets('Explore Admin Ranking Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: AdminRankingNotStarted(code: 'nx29B', db: firestore)));

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.byType(Center);

    expect(finder, findsNWidgets(4));

    expect(find.descendant(of: finder.first, matching: find.byType(Column)),
        findsOneWidget);
  });

  // testWidgets('Sb Home Widget', (tester) async {
  //   ZoomDrawerController drawerController = ZoomDrawerController();
  //   Widget testWidget = MediaQuery(
  //       data: MediaQueryData(),
  //       child: MaterialApp(
  //           home: Home(
  //               loggedUser: user,
  //               db: firestore,
  //               drawerController: drawerController)));

  //   await tester.pumpWidget(testWidget);

  //   //create the finders
  //   final finder = find.byType(Scaffold);

  //   expect(finder, findsOneWidget);

  //   final stackFinder =
  //       find.descendant(of: finder, matching: find.byType(Stack));

  //   final sbFinder = find.descendant(
  //       of: finder, matching: find.byType(StreamBuilder<QuerySnapshot>));

  //   final centerFinder = find.descendant(
  //       of: finder, matching: find.byType(StreamBuilder<QuerySnapshot>));

  //   expect(find.descendant(of: centerFinder, matching: find.byType(RichText)),
  //       findsOneWidget);
  // });
}
