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
