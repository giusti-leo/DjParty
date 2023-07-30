import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fake_cloud_firestore/src/mock_document_snapshot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

@GenerateMocks([Firebase])
void main() async {
  FakeFirebaseFirestore firestore = await getFakeFirestoreInstance();
  //var firebase = MockFirebase();
}

typedef Callback(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future<T>.delayed(const Duration(minutes: 5));
  }
}

Future<User> getMockedUser() async {
  /// Mock user sign in
  final googleSignIn = MockGoogleSignIn();
  final signInAccount = await googleSignIn.signIn();
  final googleAuth = await signInAccount!.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final user = MockUser(
    isAnonymous: false,
    uid: '076R1REcV2cFma2h2gFcrPU8kT92',
    email: 'ric@ric.com',
    displayName: 'ric',
    isEmailVerified: true,
    photoURL:
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
  );
  final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
  await auth.signInWithCredential(credential);

  setupFirebaseAuthMocks();

  return user;
}

Future<FakeFirebaseFirestore> getFakeFirestoreInstance() async {
  final firestore = FakeFirebaseFirestore();
  final User user = await getMockedUser();

  /// Populate the mock database.
  await firestore.collection('parties').doc('nx29B').set(<String, dynamic>{
    'admin': user.uid,
    'code': 'nx29B',
    'creationTime': DateTime(2023, 9, 7, 17, 30),
    'offline': false,
    'partyName': 'test',
  });

  await firestore.collection('users').doc(user.uid).set(<String, dynamic>{
    'email': user.email,
    'initcolor': 4294967295,
    'imageURL':
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
    'init': "r",
    'username': user.displayName
  });

  await firestore
      .collection('users')
      .doc('076R1REcV2cFma2h2gFcrPU8kT92')
      .collection('party')
      .doc('nx29B')
      .set(<String, dynamic>{
    'PartyName': 'test',
    'code': 'nx29B',
    'startDate': Timestamp.now(),
    'admin': '076R1REcV2cFma2h2gFcrPU8kT92'
  });

  final QuerySnapshot qSnap = await firestore
      .collection('users')
      .doc('076R1REcV2cFma2h2gFcrPU8kT92')
      .collection('party')
      .get();
  final int documents = qSnap.docs.length;
  print(documents);

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('Party')
      .doc('Voting')
      .set(<String, dynamic>{
    'countdown': true,
    'nextVotingPhase': Timestamp.now(),
    'timer': 1,
    'votingStatus': false,
    'votingTime': 1,
  });

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('Party')
      .doc('Song')
      .set(<String, dynamic>{
    'artist': ['Leonardo Giusti'],
    'image':
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
    'name': 'La Cucaracha',
    'previousArtist': ['Riccardo di Palma'],
    'previousImage':
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
    'previousRecs': Timestamp.now(),
    'previousSong': 'spotify:track:3eaya4A2mIUwmiQo3TcpSi',
    'previousTrackDuration': 120000,
    'recs': Timestamp.now(),
    'songCurrentlyPlayed': 'spotify:track:5H2kfeMoJQIlSQSTHjJ5f4',
    'trackDuration': 120000,
  });

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('Party')
      .doc('PartyStatus')
      .set(<String, dynamic>{
    'endTime': Timestamp(100, 10),
    'isBackgrounded': false,
    'isEnded': false,
    'isStarted': true,
    'startTime': Timestamp.now(),
  });

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('Party')
      .doc('MusicStatus')
      .set(<String, dynamic>{
    'backSkip': false,
    'firstVoting': false,
    'pause': false,
    'resume': false,
    'running': true,
    'selected': false,
    'songs': true,
    'songsReproduced': 2,
  });

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('members')
      .doc(user.uid)
      .set(<String, dynamic>{
    'image': 0,
    'image_url':
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
    'init': 'R',
    'initColor': 4938423987,
    'playlistSpotify': false,
    'points': 2,
    'uid': user.uid,
    'username': 'Ric',
  });

  await firestore
      .collection('parties')
      .doc('nx29B')
      .collection('queue')
      .doc('spotify:track:5H2kfeMoJQIlSQSTHjJ5f4')
      .set(<String, dynamic>{
    'Streamings': 0,
    'admin': user.uid,
    'artists': ['Leonarrdo Giusti'],
    'duration_ms': 49384,
    'image':
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpflb.us%2Fblog%2Fload-testing-profile-creation%2F&psig=AOvVaw0SYdzeDU9u1IdzREWY5mpi&ust=1690723673976000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCLiujNKCtIADFQAAAAAdAAAAABAE',
    'inQueue': true,
    'likes': 1,
    'songName': 'La cucaracha',
    'timestamp': Timestamp.now(),
    'uri': 'spotify:track:5H2kfeMoJQIlSQSTHjJ5f4',
    'votes': [user.uid],
  });

  return firestore;
}

Future<void> setupMockStorage() async {
  final storage = MockFirebaseStorage();
  final storageRef = storage.ref().child('assets/images/default-profile.png');
  final image = File('assets/images/default-profile.png');
  await storageRef.putFile(image);
}

List<DocumentSnapshot<Object?>> getDocumentSnapshots(
    QuerySnapshot<Map<String, dynamic>> querySnapshot) {
  final snap = querySnapshot.docs.first;
  MockDocumentSnapshot documentSnapshot = MockDocumentSnapshot(
      snap.reference, snap.id, snap.data(), Object(), false, true, false);
  List<DocumentSnapshot> snapshots = [];
  snapshots.add(documentSnapshot);
  return snapshots;
}
