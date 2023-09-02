import 'package:djparty/page/lobby/UserProfile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Page has a title', (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: UserProfile(
                drawerController: drawerController,
                loggedUser: user,
                db: firestore)));

    await tester.pumpWidget(testWidget);

    final appBarFinder = find.text('Profile');

    expect(appBarFinder, findsOneWidget);
  });
}
