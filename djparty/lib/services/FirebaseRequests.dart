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

  /*Future<List<dynamic>> getMySongs({required String code, String? user}) async {
    try {
      List<dynamic> mySongs = [];
      await userCollection
          .doc(user)
          .collection("party")
          .doc(code)
          .get()
          .then((value) {
        mySongs = value.get("mySongs");
      });
      return mySongs;
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
          return [];
      }
    }
  }
  */

  getSongs({required String code}) async {
    Stream<QuerySnapshot<Map<String, dynamic>>> res;
    try {
      res = partyCollection
          .doc(code)
          .collection("queue")
          .where('inQueue', isEqualTo: true)
          .orderBy('votes')
          .snapshots();
      return res;
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
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

  Future<void> changeStatus(bool val, DateTime nextVotingPhase) async {
    try {
      await partyCollection
          .doc(_partyCode)
          .update({
            'votingStatus': val,
            'nextVotingPhase': nextVotingPhase,
          })
          .then((_) => print('Party status changed'))
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

  // checkPartyCode exists or not in cloudfirestore
  Future<bool> checkPartyExists({required String code}) async {
    DocumentSnapshot snap = await partyCollection.doc(code).get();
    if (snap.exists) {
      return true;
    } else {
      return false;
    }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getPartyDataFromFirestore(String code) async {
    try {
      await partyCollection
          .doc(code)
          .get()
          .then((DocumentSnapshot snapshot) => {
                _admin = snapshot['admin'],
                _partyCode = snapshot['code'],
                _creationTime =
                    (snapshot['creationTime'] as Timestamp).toDate(),
                _isStarted = snapshot['isStarted'],
                _isEnded = snapshot['isEnded'],
                _partecipantList = snapshot['partecipant_list'],
                _partyName = snapshot['partyName'],
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

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _partyName = s.getString('partyName');
    _admin = s.getString('admin');
    _partyCode = s.getString('code');
    _timer = s.getInt('timer');
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setInt('votingTime', _votingTimer!);
    await s.setInt('timer', _timer!);
    await s.setString('admin', _admin!);
    await s.setString('code', _partyCode!);
    await s.setBool('isStarted', _isStarted!);
    await s.setBool('isEnded', _isEnded!);
    await s.setString('partyName', _partyName!);
    notifyListeners();
  }

  Future addParty(String uid, String partyName, String partyCode, int image,
      String username, String imageUrl) async {
    try {
      await createParty(uid, partyName, partyCode);
      await createPartyForAUser(uid, uid, partyName, partyCode);
      await addUserToRanking(uid, username, imageUrl, image, partyCode);
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
        'timer': 2,
        'votingTime': 3,
        'songCurrentlyPlayed': ''
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
      await addUserToParty(user);
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

  Future<void> updateParty(
    String code,
    int timer,
    int interval,
  ) async {
    try {
      await partyCollection.doc(code).update({
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
      DateTime now = DateTime.now();
      await partyCollection.doc(code).update({
        'isStarted': true,
        'startParty': now,
        'votingStatus': false,
        'nextVotingPhase': now.add(const Duration(minutes: 1)),
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

  Future<void> userLikesSong(String song, String user) async {
    List<String> users = [user];
    try {
      await partyCollection
          .doc(partyCode)
          .collection('queue')
          .doc(song)
          .update({
        'votes': FieldValue.arrayUnion(users),
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
  }

  Future addSongToFirebase(Track track) async {
    try {
      await partyCollection
          .doc(partyCode)
          .collection('queue')
          .doc(track.uri)
          .set({
        'admin': admin,
        'songName': track.name,
        'uri': track.uri,
        'votes': [],
        'artists': FieldValue.arrayUnion(track.artists!),
        'duration_ms': track.duration,
        'image': track.images,
        'timestamp': Timestamp.now(),
        'inQueue': true
      }).then((value) => print('Song added to Collection'));
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
