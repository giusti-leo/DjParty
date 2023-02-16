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
    List<dynamic> artists = track['artists'].toList();
    List<String> currentArtistList = [];

    artists.forEach((element) {
      currentArtistList.add(element['name']);
    });
    return Track(
        track["uri"],
        currentArtistList,
        track["image"],
        track["songName"],
        track["admin"],
        track["duration_ms"],
        track["timestamp"],
        track["votes"],
        track["inQueue"]);
  }
}
