import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/Home.dart';
import 'package:flutter_zoom_drawer/config.dart';

import '../utils/firebase.dart';

Future<void> main() async {
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();
  final User user = await getMockedUser();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Home Widget', (tester) async {
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
    // expect(
    //     find.descendant(
    //         of: finder, matching: find.byType(StreamBuilder<QuerySnapshot>)),
    //     findsNWidgets(2));
  });
}
