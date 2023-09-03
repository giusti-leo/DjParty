import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/party/partyGuest/GuestRanking.dart';
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

  testWidgets('check Start the party button is not present because of guest',
      (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: GuestRankingNotStarted(
          db: firestore,
          code: 'nx29B',
        )));

    await tester.pumpWidget(testWidget);

    //create the finders
    final finder = find.text('Start the Party');
    expect(finder, findsNothing);
  });

  testWidgets('Test guest ranking row', (tester) async {
    u2.User userRanking = u2.User(
        '12345',
        'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
        'leo',
        0,
        12);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(child: NotStartedRankingRow(userRanking))));

    await tester.pumpWidget(testWidget);

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('leo'), findsOneWidget);
  });

  testWidgets('Test guest ranking row not started not showing points',
      (tester) async {
    u2.User userRanking = u2.User(
        '12345',
        'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
        'leo',
        0,
        12);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(child: NotStartedRankingRow(userRanking))));

    await tester.pumpWidget(testWidget);
    expect(find.text('Score'), findsNothing);
  });

  testWidgets('Test guest ranking row started showing points', (tester) async {
    u2.User userRanking = u2.User(
        '12345',
        'https://camo.githubusercontent.com/b4c566de1ceca472d9c01c7558999fa947a045164019cd180d7713f17fafa9c2/68747470733a2f2f692e6962622e636f2f516d567a4a77562f557365722d486f6d65706167652e706e67',
        'leo',
        0,
        12);

    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child:
            MaterialApp(home: Material(child: StartedRankingRow(userRanking))));

    await tester.pumpWidget(testWidget);
    expect(find.text(' Score: 12'), findsOneWidget);
  });
}
