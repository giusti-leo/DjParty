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

  int? _partecipantNumber;
  int? get partecipantNumber => _partecipantNumber;

  Timestamp? _partyDate;
  Timestamp? get partyDate => _partyDate;

  String? _admin;
  String? get admin => _admin;

  String? _partyTime;
  String? get partyTime => _partyTime;

  String? _partyCode;
  String? get partyCode => _partyCode;

  Timestamp? _creationTime;
  Timestamp? get creationTime => _creationTime;

  bool? _isStarted;
  bool? get isStarted => _isStarted;

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
        .orderBy("startDate")
        .snapshots();
  }

  Future<List<String>> getMySongs({required String code, String? user}) async {
    try {
      List<String> mySongs = [];
      await userCollection
          .doc(user)
          .collection("party")
          .doc(code)
          .get()
          .then((value) => mySongs = value.get("mySongs"));
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

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getSongs(
      {required String code}) async {
    return partyCollection
        .doc(code)
        .collection("queue")
        .where('inQueue', isEqualTo: true)
        .orderBy(['timestamp', 'votes']).snapshots();
  }

  savePartyDataFromFirebase({required String code}) async {
    return userCollection.doc(code).snapshots();
  }

  Future<void> exit(String user) async {
    try {
      await userCollection
          .doc(user)
          .collection('party')
          .doc(partyCode!)
          .delete()
          .then((_) => print('Party Deleted from User Party'));
    } on FirebaseException catch (e) {
      switch (e.code) {
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    }
  }

  Future<void> remove(String? user) async {
    try {
      await partyCollection
          .doc(_partyCode)
          .update({
            '#partecipant': FieldValue.increment(-1),
            'partecipant_list': FieldValue.arrayRemove([user]),
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
                _partecipantNumber = snapshot['#partecipant'],
                _admin = snapshot['admin'],
                _partyDate = snapshot['PartyDate'],
                _partyTime = snapshot['PartyTime'],
                _partyCode = snapshot['code'],
                _creationTime = snapshot['creationTime'],
                _isStarted = snapshot['isStarted'],
                _isEnded = snapshot['isEnded'],
                _partecipantList = snapshot['partecipant_list'],
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

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setInt('#partecipant', _partecipantNumber!);
    await s.setString('admin', _admin!);
    await s.setString('PartyTime', _partyTime!);
    await s.setString('code', _partyCode!);
    await s.setBool('isStarted', _isStarted!);
    await s.setBool('isEnded', _isEnded!);
    await s.setString('partyName', _partyName!);
    notifyListeners();
  }

  Future createParty(String admin, String partyName, String code,
      DateTime selectedDate, String choosenTime, List<String> members) async {
    List<Map<String, dynamic>> queue = [];
    try {
      await partyCollection.doc(code).set({
        'admin': admin,
        'partyName': partyName,
        'code': code,
        'creationTime': Timestamp.now(),
        'PartyDate': selectedDate,
        'PartyTime': choosenTime,
        'isStarted': false,
        'isEnded': false,
        '#partecipant': 1,
        'partecipant_list': members,
        'timer': 15,
        'queue': queue
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

  Future<void> delete(String code) async {
    try {
      List<dynamic> list = [];

      if (isStarted! && isEnded!) {
        exit(uid!);
        notifyListeners();
        return;
      }

      var snap = await partyCollection.doc(partyCode!).get();

      if (!isStarted!) {
        list = snap.get('partecipant_list');
        if (list.isNotEmpty) {
          list.forEach((elem) async {
            await checkUserExists(elem).then(
              (value) {
                if (value == true) {
                  exit(elem.toString());
                  notifyListeners();
                }
              },
            );
          });
        }

        deleteParty();
      } else {
        _errorCode = 'Please, stop the party first!';
        _hasError = true;
        notifyListeners();
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

  Future<void> deleteParty() async {
    try {
      await partyCollection.doc(partyCode).delete();
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
    DateTime selectedDate,
  ) async {
    try {
      await userCollection.doc(uid).collection('party').doc(code).set({
        'admin': admin,
        'PartyName': partyName,
        'code': code,
        'startDate': selectedDate,
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

  Future<void> userJoinParty(String uid) async {
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

  Future<void> setPartyStarted(String code) async {
    try {
      await partyCollection.doc(code).update({
        'isStarted': true,
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
        '#partecipant': FieldValue.increment(1),
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
        'votes': 0,
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
