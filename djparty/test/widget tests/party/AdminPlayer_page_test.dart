import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/party/partyAdmin/AdminPlayer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:nock/nock.dart';
import 'package:djparty/entities/Track.dart' as t;
import 'package:mockito/mockito.dart';
import 'dart:convert';

import '../../utils/firebase.dart';

Future<void> main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('party not started', () {
    testWidgets('check image is present', (tester) async {
      ZoomDrawerController drawerController = ZoomDrawerController();
      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(home: AdminPlayerNotStarted()));

      await tester.pumpWidget(testWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('text is present', (tester) async {
      ZoomDrawerController drawerController = ZoomDrawerController();
      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(home: AdminPlayerNotStarted()));

      await tester.pumpWidget(testWidget);
      expect(
          find.text(
              'Songs in the Queue will be reproduced\n when the party will start'),
          findsOneWidget);
    });
  });

  group('party started', () {
    testWidgets('check image is present', (tester) async {
      t.Song song = t.Song(
          ['leo'],
          'ciao',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'spotify:artist:1a2b3c4d5e6f7g',
          10000,
          Timestamp.now(),
          ['ric'],
          'uriexamples',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'test',
          12000,
          Timestamp.now());

      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(home: AdminPlayerDisplayStarted(song)));

      await tester.pumpWidget(testWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('artist is present', (tester) async {
      t.Song song = t.Song(
          ['leo'],
          'ciao',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'spotify:artist:1a2b3c4d5e6f7g',
          10000,
          Timestamp.now(),
          ['ric'],
          'uriexamples',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'test',
          12000,
          Timestamp.now());

      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(home: AdminPlayerDisplayStarted(song)));

      await tester.pumpWidget(testWidget);
      expect(find.text('leo'), findsOneWidget);
    });
    testWidgets('title is present', (tester) async {
      t.Song song = t.Song(
          ['leo'],
          'ciao',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'spotify:artist:1a2b3c4d5e6f7g',
          10000,
          Timestamp.now(),
          ['ric'],
          'uriexamples',
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
          'test',
          12000,
          Timestamp.now());

      Widget testWidget = MediaQuery(
          data: MediaQueryData(),
          child: MaterialApp(home: AdminPlayerDisplayStarted(song)));

      await tester.pumpWidget(testWidget);
      expect(find.text('ciao'), findsOneWidget);
    });
  });
}
