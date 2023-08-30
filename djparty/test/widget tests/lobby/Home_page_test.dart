import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/lobby/HomePage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/lobby/Home.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:mockito/mockito.dart';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('display user name', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: HomePage(loggedUser: user, db: firestore)));

    await tester.pumpWidget(testWidget);

    final nameFinder = find.text('P');
    expect(nameFinder, findsOneWidget);
  });
}
