import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? email;
  final String? username;
  final String? password;

  User({
    this.email,
    this.username,
    this.password,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      email: data?['email'],
      username: data?['username'],
      password: data?['password'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "name": email,
      if (username != null) "username": username,
      if (password != null) "password": password,
    };
  }
}
