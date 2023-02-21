import 'package:cloud_firestore/cloud_firestore.dart';

class Track {
  final String? uri;
  final List<String>? artists;
  final String? images;
  final String? name;
  final String? admin;
  final Timestamp? timestamp;
  final int? duration;
  final bool? inQueue;
  List<String> likes;

  Track(
      List<String> this.likes,
      String this.uri,
      List<String> this.artists,
      String this.images,
      String this.name,
      String this.admin,
      int this.duration,
      Timestamp this.timestamp,
      bool this.inQueue);

  factory Track.getTrackFromFirestore(dynamic track) {
    List<dynamic> artists = track['artists'].toList();
    List<String> currentArtistList = [];

    List<dynamic> likes = track['votes'].toList();
    List<String> currentLikes = [];

    for (var element in likes) {
      currentLikes.add(element.toString());
    }

    for (var element in artists) {
      currentArtistList.add(element.toString());
    }
    return Track(
        currentLikes,
        track["uri"],
        currentArtistList,
        track["image"],
        track["songName"],
        track["admin"],
        track["duration_ms"],
        track["timestamp"],
        track["inQueue"]);
  }

  factory Track.getTrackFromSpotify(dynamic track, String user) {
    List<dynamic> artists = track['artists'];
    List<String> currentArtistList = [];

    for (var element in artists) {
      currentArtistList.add(element['name']);
    }

    List<dynamic> images = track['album']['images'];
    List<String> currentImages = [];
    for (var element in images) {
      currentImages.add(element['url']);
    }

    return Track([], track["uri"], currentArtistList, currentImages[0],
        track["name"], user, track["duration_ms"], Timestamp.now(), false);
  }
}
