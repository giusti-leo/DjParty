import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String? email;
  final String? username;
  final String? password;

  Person({
    this.email,
    this.username,
    this.password,
  });

  factory Person.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Person(
      email: data?['email'],
      username: data?['username'],
    );
  }

  /*
  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "name": email,
      if (username != null) "username": username,
      if (password != null) "password": password,
    };
  }
  */

  static Person fromJson(Map<String, dynamic> json) => Person(
        username: json['name'],
        email: json['email'],
      );
}
