import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? uri;
  final String? imageUrl;
  final String? username;
  final int? points;
  final int? image;

  User(
    String this.uri,
    String this.imageUrl,
    String this.username,
    int this.image,
    int this.points,
  );

  factory User.getTrackFromFirestore(dynamic user) {
    return User(
      user["uid"],
      user["image_url"],
      user["username"],
      user["initColor"],
      user["points"],
    );
  }
}
