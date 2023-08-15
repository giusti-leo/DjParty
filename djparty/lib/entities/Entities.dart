import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  final String? imageUrl;
  final String? username;
  final int? image;
  final String? email;
  final String? description;

  Person(String this.imageUrl, String this.username, int this.image,
      String this.email, String this.description);

  factory Person.getTrackFromFirestore(dynamic user) {
    return Person(user["image_url"], user["username"], user["initColor"],
        user["email"], user["description"]);
  }
}
