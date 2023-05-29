import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Track.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseRequests extends ChangeNotifier {
  final String? uid;

  FirebaseRequests({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference partyCollection =
      FirebaseFirestore.instance.collection("parties");

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _musicStatus = false;
  bool get musicStatus => _musicStatus;

  bool _status = false;
  bool get status => _status;

  String? _errorCode;
  String? get errorCode => _errorCode;

  DateTime? _startParty;
  DateTime? get startParty => _startParty;

  Timestamp? _partyDate;
  Timestamp? get partyDate => _partyDate;

  String? _admin;
  String? get admin => _admin;

  String? _partyTime;
  String? get partyTime => _partyTime;

  String? _partyCode;
  String? get partyCode => _partyCode;

  DateTime? _creationTime;
  DateTime? get creationTime => _creationTime;

  DateTime? _nextVotingPhase;
  DateTime? get nextVotingPhase => _nextVotingPhase;

  bool? _isStarted;
  bool? get isStarted => _isStarted;

  bool? _isVoting;
  bool? get isVoting => _isVoting;

  bool? _isEnded;
  bool? get isEnded => _isEnded;

  List<dynamic>? _partecipantList;
  List<dynamic>? get partecipantList => _partecipantList;

  String? _partyName;
  String? get partyName => _partyName;

  int? _timer;
  int? get timer => _timer;

  String? _songUri;
  String? get songUri => _songUri;

  String? _songName;
  String? get songName => _songName;

  String? _songArtist;
  String? get songArtist => _songArtist;

  String? _songUrlImage;
  String? get songUrlImage => _songUrlImage;

  String? _partyStatus;
  String? get partyStatus => _partyStatus;

  int? _songDuration;
  int? get songDuration => _songDuration;

  int? _votingTimer;
  int? get votingTimer => _votingTimer;

  /*

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  */

  // getting the parties
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getParties(
      {required String uid}) async {
    return userCollection
        .doc(uid)
        .collection("party")
        .orderBy("startDate", descending: true)
        .snapshots();
  }

  savePartyDataFromFirebase({required String code}) async {
    return userCollection.doc(code).snapshots();
  }

  Future<void> removeUserFromPartyList(String user, String party) async {
    try {
      List<dynamic> users = [user];
      await partyCollection
          .doc(party)
          .update({
            'partecipant_list': FieldValue.arrayRemove([users]),
          })
          .then((_) => print('Party Deleted'))
          .catchError((error) => print('Failed: $error'));
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> changeVotingStatus(String code, bool val) async {
    try {
      await partyCollection.doc(code).collection('Party').doc('Voting').update({
        'votingStatus': val,
        'countdown': false,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  // checkPartyCode exists or not in cloudfirestore
  Future<bool> checkPartyExists({required String code}) async {
    DocumentSnapshot snap = await partyCollection.doc(code).get();
    if (snap.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future getPartyStatusFromFirestore(String code) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('PartyStatus')
          .get()
          .then((DocumentSnapshot snapshot) => {
                _isEnded = snapshot['isEnded'],
                _isStarted = snapshot['isStarted']
              });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future getPartyVotingFromFirestore(String code) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('Voting')
          .get()
          .then((DocumentSnapshot snapshot) => {
                _timer = snapshot['timer'],
                _votingTimer = snapshot['votingTime'],
              });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future getPartySongFromFirestore(String code) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('Song')
          .get()
          .then((DocumentSnapshot snapshot) => {
                _songUri = snapshot['songCurrentlyPlayed'],
              });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future getPartyDataFromFirestore(String code) async {
    try {
      await getPartyInfoFromFirestore(code);
      await getPartyStatusFromFirestore(code);
      await getPartyVotingFromFirestore(code);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future getPartyInfoFromFirestore(String code) async {
    try {
      await partyCollection
          .doc(code)
          .get()
          .then((DocumentSnapshot snapshot) => {
                _admin = snapshot['admin'],
                _partyCode = snapshot['code'],
                _creationTime =
                    (snapshot['creationTime'] as Timestamp).toDate(),
                _partyName = snapshot['partyName']
              });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> removeUserFromRanking(String user, String party) async {
    try {
      await partyCollection.doc(party).collection('members').doc(user).delete();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> addUserToRanking(
      String uid, String name, String imageUrl, int image, String party) async {
    try {
      await partyCollection.doc(party).collection('members').doc(uid).set({
        "uid": uid,
        "username": name,
        "image_url": imageUrl,
        'init': name[0],
        'image': image,
        'initColor': const Color(0xFFFFFFFF).value,
        "points": 0,
        "playlistSpotify": false
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> addPlaylist(String uid, String party) async {
    try {
      await partyCollection
          .doc(party)
          .collection('members')
          .doc(uid)
          .update({"playlistSpotify": true});
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    _partyName = s.getString('partyName');
    _admin = s.getString('admin');
    _partyCode = s.getString('code');

    _timer = s.getInt('timer');
    _votingTimer = s.getInt('votingTime');

    _isEnded = s.getBool('isStarted');
    _isStarted = s.getBool('isEnded');

    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

//  generic data
    await s.setString('admin', _admin!);
    await s.setString('code', _partyCode!);
    await s.setString('partyName', _partyName!);

//  Party Status
    await s.setBool('isStarted', _isStarted!);
    await s.setBool('isEnded', _isEnded!);

    notifyListeners();
  }

  Future addParty(String uid, String partyName, String partyCode, int image,
      String username, String imageUrl) async {
    try {
      //await createParty(uid, partyName, partyCode);
      await organizeParty(uid, partyName, partyCode);
      await createPartyForAUser(uid, uid, partyName, partyCode);
      await addUserToRanking(uid, username, imageUrl, image, partyCode);
      await createPartyStatus(partyCode);
      await createMusicStatus(partyCode);
      await createPartyVoting(partyCode);
      await createStatus(partyCode);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createPartyVoting(
    String code,
  ) async {
    try {
      await partyCollection.doc(code).collection('Party').doc('Voting').set({
        'votingStatus': false,
        'nextVotingPhase': DateTime.now(),
        'timer': 2,
        'votingTime': 3,
        'countdown': false
      }).then((value) => print('Music added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createStatus(
    String code,
  ) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('MusicStatus')
          .set({
        'selected': false,
        'songs': false,
        'firstVoting': false,
        'songsReproduced': 0,
        'running': false,
        "pause": false,
        "resume": false,
        "backSkip": false
      }).then((value) => print('Music added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createMusicStatus(
    String code,
  ) async {
    try {
      await partyCollection.doc(code).collection('Party').doc('Song').set({
        'songCurrentlyPlayed': '',
        'trackDuration': 0,
        'image': '',
        'name': '',
        'artist': [],
        'recs': Timestamp.now(),
        "previousSong": '',
        "previousImage": '',
        "previousName": '',
        "previousTrackDuration": 0,
        "previousArtist": [],
        "previousRecs": Timestamp.now(),
      }).then((value) => print('Music added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future setRestart(
    String code,
  ) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      var pathVoting =
          partyCollection.doc(code).collection('Party').doc('Song');

      batch.update(pathVoting, {'recs': Timestamp.now()});

      var pathPartyStatus =
          partyCollection.doc(code).collection('Party').doc('PartyStatus');

      batch.update(pathPartyStatus, {
        'isBackgrounded': false,
      });

      batch.commit();

      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createPartyStatus(
    String code,
  ) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('PartyStatus')
          .set({
        'isStarted': false,
        'isEnded': false,
        'isBackgrounded': false,
        'startTime': DateTime.now(),
        'endTime': DateTime.now(),
      }).then((value) => print('Party Status added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future organizeParty(
    String admin,
    String partyName,
    String code,
  ) async {
    List<Map<String, dynamic>> queue = [];
    List<String> members = [admin];
    try {
      await partyCollection.doc(code).set({
        'admin': admin,
        'partyName': partyName,
        'code': code,
        'creationTime': DateTime.now(),
      }).then((value) => print('Party added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createParty(
    String admin,
    String partyName,
    String code,
  ) async {
    List<Map<String, dynamic>> queue = [];
    List<String> members = [admin];
    try {
      await partyCollection.doc(code).set({
        'admin': admin,
        'partyName': partyName,
        'code': code,
        'creationTime': DateTime.now(),
        'isStarted': false,
        'isEnded': false,
        'partecipant_list': members,
        'queue': queue,
        'votingStatus': false,
        'nextVotingPhase': DateTime.now(),
        'startParty': DateTime.now(),
        'status': 'C',
        'timer': 2,
        'votingTime': 3,
        'songCurrentlyPlayed': '',
        'songsReproduced': 0
      }).then((value) => print('Party added'));
      notifyListeners();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<bool> checkUserExists(String user) async {
    DocumentSnapshot snap = await userCollection.doc(user).get();
    if (snap.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isPartyStarted() async {
    DocumentSnapshot snap = await partyCollection.doc(partyCode).get();
    if (snap.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isPartyEnded() async {
    DocumentSnapshot snap = await partyCollection.doc(partyCode).get();
    if (snap.get('isEnded')) {
      return true;
    } else {
      return false;
    }
  }

  getIsEnded() {
    return isEnded;
  }

  getIsStarted() {
    return isStarted;
  }

  Future<List<String>> getPartecipants(String partyCode) async {
    List<String> list = [];
    try {
      await partyCollection.doc(partyCode).get().then((value) {
        for (var element in List.from(value.get('partecipant_list'))) {
          String data = (element.toString());
          list.add(data);
        }
      });
      return list;
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          return list;
      }
    }
  }

  Future<void> deleteParty(String party) async {
    try {
      await partyCollection.doc(party).delete();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future createPartyForAUser(
    String uid,
    String admin,
    String partyName,
    String code,
  ) async {
    try {
      await userCollection.doc(uid).collection('party').doc(code).set({
        'admin': admin,
        'PartyName': partyName,
        'code': code,
        "startDate": DateTime.now()
      }).then((value) => print('Party added'));
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future setSelection(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('MusicStatus');
    await db.update({
      "selected": false,
      "running": false,
      "resume": false,
      "pause": false,
      "backSkip": false
    });
  }

  Future setBackSkip(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('MusicStatus');
    await db.update({
      "selected": false,
      "running": false,
      "resume": false,
      "pause": false,
      "backSkip": true
    });
  }

  Future setResume(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('MusicStatus');
    await db.update({"resume": true, "pause": false});
  }

  Future setPause(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('MusicStatus');
    await db.update({"pause": true, "resume": false});
  }

  Future setBackgrounded(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('PartyStatus');
    await db.update({"isBackgrounded": true});
  }

  Future setNotBackgrounded(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('PartyStatus');
    await db.update({"isBackgrounded": false});
  }

  Future setNotSelection(String code) async {
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(code)
        .collection('Party')
        .doc('MusicStatus');
    await db.update({
      "selected": false,
      "running": true,
    });
  }

  Future<bool> isUserInsideParty(String user) async {
    DocumentSnapshot snap =
        await userCollection.doc(user).collection('party').doc(partyCode).get();
    if (snap.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> userIsInTheParty(String uid) async {
    List<dynamic> members = [];
    List<String> currentMembers = [];

    try {
      await partyCollection.doc(partyCode).get().then((value) {
        members = value.get('partecipant_list');
      });

      for (var element in members) {
        currentMembers.add(element.toString());
      }
      return currentMembers.contains(uid);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
          return false;
      }
    }
  }

  Future<void> addPartyInfoToUser(String uid) async {
    try {
      await userCollection.doc(uid).collection('party').doc(partyCode).set({
        'PartyName': partyName.toString(),
        'startDate': creationTime,
        'code': partyCode,
        'admin': admin
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> userJoinParty(String user, String party, String name,
      String imageUrl, int image) async {
    try {
      await addPartyInfoToUser(user);
//      await addUserToParty(user);
      await addUserToRanking(user, name, imageUrl, image, party);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> userExitParty(String user, String party) async {
    try {
      await userExitFromParty(user, party);
      await removeUserFromPartyList(user, party);
      await removeUserFromRanking(user, party);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> adminExitParty(String user, String party) async {
    try {
      await userExitFromParty(user, party);
      await removeUserFromPartyList(user, party);
      await removeUserFromRanking(user, party);
      await changes(party);
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> changes(String party) async {
    try {
      var users = await partyCollection.doc(party).collection('members').get();
      if (users.size > 0) {
        String user = users.docs[0].get('uid').toString();
        await partyCollection.doc(party).update({'admin': user});
      } else {
        await partyCollection.doc(party).delete();
      }
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> userExitFromParty(String user, String party) async {
    try {
      await userCollection.doc(user).collection('party').doc(party).delete();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> updatePartySettings(
    String code,
    int timer,
    int interval,
  ) async {
    try {
      await partyCollection.doc(code).collection('Party').doc('Voting').update({
        'timer': timer,
        'votingTime': interval,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> setPartyStarted(String code) async {
    try {
      Timestamp now = Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: _votingTimer!)));

      var batch = FirebaseFirestore.instance.batch();
      var pathVoting =
          partyCollection.doc(code).collection('Party').doc('Voting');

      batch.update(pathVoting, {'countdown': false, 'votingStatus': true});

      var pathPartyStatus =
          partyCollection.doc(code).collection('Party').doc('PartyStatus');

      batch.update(pathPartyStatus, {
        'isStarted': true,
        'startTime': DateTime.now(),
      });

      batch.commit();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> startsVoting(String code) async {
    try {
      Timestamp now = Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: _votingTimer!)));
      await partyCollection.doc(code).collection('Party').doc('Voting').update({
        'votingStatus': true,
        'nextVotingPhase': now,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> setCountdown(int t, String code) async {
    try {
      Timestamp now =
          Timestamp.fromDate(DateTime.now().add(Duration(minutes: t)));
      await partyCollection.doc(code).collection('Party').doc('Voting').update({
        'countdown': true,
        'nextVotingPhase': now,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> startsParty(String code) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('PartyStatus')
          .update({
        'isStarted': true,
        'startTime': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> changeFirstVoting(String code) async {
    try {
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('MusicStatus')
          .update({
        'firstVoting': true,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> changeVoting(String code, bool val) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      var pathVoting =
          partyCollection.doc(code).collection('Party').doc('MusicStatus');
      batch.update(pathVoting, {
        'firstVoting': true,
      });

      var pathPartyStatus =
          partyCollection.doc(code).collection('Party').doc('Voting');
      batch.update(pathPartyStatus, {
        'votingStatus': val,
        'countdown': false,
      });

      batch.commit();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> setPartyEnded(String code) async {
    try {
      DateTime now = DateTime.now();
      await partyCollection.doc(code).update({
        'isEnded': true,
        'endTime': DateTime.now(),
      });
      await partyCollection
          .doc(code)
          .collection('Party')
          .doc('MusicStatus')
          .update({});
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> userLikesSong(String song, String user) async {
    List<String> users = [user];
    try {
      await partyCollection
          .doc(partyCode)
          .collection('queue')
          .doc(song)
          .update({
        'votes': FieldValue.arrayUnion(users),
        'likes': FieldValue.increment(1)
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> userDoesNotLikeSong(String song, String user) async {
    List<String> users = [user];
    try {
      await partyCollection
          .doc(partyCode)
          .collection('queue')
          .doc(song)
          .update({
        'votes': FieldValue.arrayRemove(users),
        'likes': FieldValue.increment(-1)
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

/*
  Future<void> addUserToParty(String uid) async {
    try {
      await partyCollection.doc(partyCode).update({
        'partecipant_list': FieldValue.arrayUnion([uid]),
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }*/

  Future addSongToFirebase(Track track) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      var pathVoting =
          partyCollection.doc(partyCode).collection('queue').doc(track.uri);

      batch.set(pathVoting, {
        'admin': admin,
        'songName': track.name,
        'uri': track.uri,
        'votes': [],
        'likes': 0,
        'artists': FieldValue.arrayUnion(track.artists),
        'duration_ms': track.duration,
        'image': track.images,
        'timestamp': Timestamp.now(),
        'Streamings': 0,
        'inQueue': true
      });

      var pathPartyStatus =
          partyCollection.doc(partyCode).collection('Party').doc('MusicStatus');
      batch.update(pathPartyStatus, {'songs': true});

      batch.commit();
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<bool> songExists(Track track) async {
    try {
      DocumentSnapshot snap = await partyCollection
          .doc(partyCode)
          .collection('queue')
          .doc(track.uri)
          .get();
      if (snap.exists) {
        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          return true;
      }
    }
  }

  /*

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }



  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  */
}
