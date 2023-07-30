import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:djparty/entities/Track.dart';

import '../utils/firebase.dart';

void main() async {
  final User user = await getMockedUser();
  final FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group("firestore checks", () {
    test("checkPartyExists", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      bool check = await fr.checkPartyExists(code: 'nx29B');
      expect(check, true);
    });

    test("checkPartyExists Fail", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      bool check = await fr.checkPartyExists(code: 'nx2A');
      expect(check, false);
    });

    test("checkUserExists", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      bool check = await fr.checkUserExists(user.uid);
      expect(check, true);
    });

    test("checkUserExists Fail", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      bool check = await fr.checkUserExists('user.uid');
      expect(check, false);
    });
  });

  group("firestore get data", () {
    test("getPartieslength", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      int response = await fr.getPartiesLength(uid: user.uid);
      expect(response, 1);
    });

    test("getPartyStatus", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.getPartyStatusFromFirestore('nx29B');
      expect(fr.isEnded, false);
      expect(fr.isStarted, true);
    });

    test("get currently played song", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.getPartySongFromFirestore('nx29B');
      expect(fr.songUri, 'spotify:track:5H2kfeMoJQIlSQSTHjJ5f4');
    });

    test("get party data", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.getPartyInfoFromFirestore('nx29B');
      expect(fr.admin, user.uid);
      expect(fr.partyCode, 'nx29B');
      expect(fr.creationTime, DateTime(2023, 9, 7, 17, 30));
      expect(fr.partyName, 'test');
    });
  });

  group("add/remove objects", () {
    test("create party", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.createParty(user.uid, 'test 2', 'code');
      final QuerySnapshot snap = await firestore.collection('parties').get();
      int length = snap.docs.length;
      expect(length, 2);
    });
    test("create party for a user", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.createPartyForAUser(user.uid, user.uid, 'test 2', 'code');
      int length = await fr.getPartiesLength(uid: user.uid);
      expect(length, 2);
    });

    test("add user to ranking", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.addUserToRanking(
          'user2', 'Bob', 'https://www.google.com/url?sa=example', 0, 'nx29B');
      final QuerySnapshot snap = await firestore
          .collection('parties')
          .doc('nx29B')
          .collection('members')
          .get();
      int length = snap.docs.length;
      expect(length, 2);
    });

    test("remove user to ranking", () async {
      FirebaseRequests fr = FirebaseRequests(db: firestore);
      await fr.addUserToRanking(
          'user2', 'Bob', 'https://www.google.com/url?sa=example', 0, 'nx29B');
      final QuerySnapshot snap = await firestore
          .collection('parties')
          .doc('nx29B')
          .collection('members')
          .get();
      int length = snap.docs.length;
      expect(length, 2);
      await fr.removeUserFromRanking('user2', 'nx29B');
      final QuerySnapshot snap2 = await firestore
          .collection('parties')
          .doc('nx29B')
          .collection('members')
          .get();
      int length2 = snap2.docs.length;
      expect(length2, 1);
    });
  });

  test("add song to Firebase", () async {
    FirebaseRequests fr = FirebaseRequests(db: firestore);
    Track testTrack = Track(['A'], 'spotify:track:5H2kfeMoJQIlSQSTHjJ5f5',
        ['artists'], 'images', 'test', user.uid, 10000, Timestamp.now(), true);
    await fr.addSongToFirebase(testTrack, 'nx29B');
    final QuerySnapshot snap = await firestore
        .collection('parties')
        .doc('nx29B')
        .collection('queue')
        .get();
    int length = snap.docs.length;
    expect(length, 2);
  });
}
