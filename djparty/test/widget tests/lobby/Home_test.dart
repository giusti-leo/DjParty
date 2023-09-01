import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/page/lobby/Home.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fake_firebase_performance/fake_firebase_performance.dart';
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

  testWidgets('Sb Home Widget 2', (tester) async {
    FakeFirebaseFirestore db = FakeFirebaseFirestore();
    await db
        .collection('users')
        .doc(user.uid)
        .collection('party')
        .add({'partyName': 'test'});

    await tester.pumpWidget(
      Flexible(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(user.uid)
              .collection("party")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final documents = snapshot.data?.docs;
            return ListView.builder(
              itemCount: documents?.length,
              itemBuilder: (context, index) {
                final document = documents![index];
                return ListTile(
                  title: Text(document['partyName']),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.idle();
    await tester.pump(Duration.zero);

    // Verify that the widget tree contains the expected data
    expect(find.byType(StreamBuilder<QuerySnapshot>), findsOneWidget);
  });
}
