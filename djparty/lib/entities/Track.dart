import 'package:cloud_firestore/cloud_firestore.dart';

class Track {
  final String? uri;
  final List<String>? artists;
  final String? images;
  final String? name;
  final String? admin;
  final Timestamp? timestamp;
  int? vote;
  final int? duration;
  final bool? inQueue;

  Track(
      String this.uri,
      List<String> this.artists,
      String this.images,
      String this.name,
      String this.admin,
      int this.duration,
      Timestamp this.timestamp,
      int this.vote,
      bool this.inQueue);

  factory Track.getTrackFromFirestore(dynamic track) {
    return Track(
        track["uri"],
        track["artists"],
        track["image"],
        track["songName"],
        track["admin"],
        track["duration_ms"],
        track["timestamp"],
        track["votes"],
        track["inQueue"]);
  }
}
