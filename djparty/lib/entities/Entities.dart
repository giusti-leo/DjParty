import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String? email;

  Person({
    this.email,
  });

  factory Person.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Person(
      email: data?['email'],
    );
  }

  static Person fromJson(Map<String, dynamic> json) => Person(
        email: json['email'],
      );
}
/*

class Party {
  final String? admin;
  final String? code;
  final String? partyName;
  final DateTime? startTime;
  final int? timer;

  Party({
    this.admin,
    this.code,
    this.partyName,
    this.startTime,
    this.timer,
  });

  factory Party.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    List<Party> parties = [];
    parties.add(Party(
      admin: data?['admin'],
      code: data?['code'],
      startTime: data?['startTime'],
      timer: data?['timer'],
      partyName: data?['partyName'],
    ));
    return Party(
      email: data?['email'],
      parties: data?['myParties'],
    );
  }

  static Party fromJson(Map<String, dynamic> json) => Party(
        parties: json['myParties'],
        email: json['email'],
      );
}

*/
