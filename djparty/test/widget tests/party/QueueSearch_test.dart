import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/party/QueueSearch.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:nock/nock.dart';
import 'package:djparty/entities/Track.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('check Scaffold is present when the party is ended',
      (tester) async {
    ZoomDrawerController drawerController = ZoomDrawerController();
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: SongLists(
          loggedUser: user,
          db: firestore,
          code: 'nx29B',
        )));

    await tester.pumpWidget(testWidget);

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('test name queueRow', (tester) async {
    Track track = Track(
        ['1'],
        'uriexample',
        ['ciao'],
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
        'test',
        'admin',
        10000,
        Timestamp.now(),
        true);
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Scaffold(
          body: QueueRow(
            track,
            user,
            firestore,
          ),
        )));

    await tester.pumpWidget(testWidget);

    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('test finds heart icon queueRow', (tester) async {
    Track track = Track(
        ['1'],
        'uriexample',
        ['ciao'],
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
        'test',
        'admin',
        10000,
        Timestamp.now(),
        true);
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Scaffold(
          body: QueueRow(
            track,
            user,
            firestore,
          ),
        )));

    await tester.pumpWidget(testWidget);

    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('test not find heart icon queueRowNotVoting', (tester) async {
    Track track = Track(
        ['1'],
        'uriexample',
        ['ciao'],
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
        'test',
        'admin',
        10000,
        Timestamp.now(),
        true);
    Widget testWidget = MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
            home: Scaffold(
          body: QueueRowNotVoting(
            track,
            user,
            firestore,
          ),
        )));

    await tester.pumpWidget(testWidget);

    expect(find.byType(Icon), findsNothing);
  });
}
