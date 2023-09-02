import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/party/QueueSearch.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:nock/nock.dart';
import 'package:djparty/entities/User.dart' as u2;
import 'package:mockito/mockito.dart';
import 'dart:convert';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('check Start the party button is present', (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: QueueSearch(
          loggedUser: user,
          db: firestore,
          code: 'nx29B',
        )));

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.text('Start the Party');
    expect(finder, findsOneWidget);
  });
}
