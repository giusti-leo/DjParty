import 'package:cloud_firestore/cloud_firestore.dart';

class Track {
  final String uri;
  final List<String> artists;
  final String images;
  final String name;
  final String admin;
  final Timestamp timestamp;
  final int duration;
  final bool inQueue;
  List<String> likes;

  Track(this.likes, this.uri, this.artists, this.images, this.name, this.admin,
      this.duration, this.timestamp, this.inQueue);

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

class Song {
  final String uri;
  final List<String> artists;
  final String images;
  final String name;
  final int duration;
  final Timestamp? tmp;

  final String previousUri;
  final List<String> previousArtists;
  final String previousImages;
  final String previousName;
  final int previousDuration;
  final Timestamp? previousTmp;

  Song(
      this.artists,
      this.name,
      this.images,
      this.uri,
      this.duration,
      this.tmp,
      this.previousArtists,
      this.previousUri,
      this.previousImages,
      this.previousName,
      this.previousDuration,
      this.previousTmp);

  factory Song.getPartyFromFirestore(dynamic song) {
    List<String> currentArtistList = [];
    List<String> previousArtistList = [];

    if (song['artist'].toString() != '[]') {
      List<dynamic> artists = song['artist'];
      for (var element in artists) {
        currentArtistList.add(element.toString());
      }
    }

    if (song['previousArtist'].toString() != '[]') {
      List<dynamic> previousArtists = song['previousArtist'];

      for (var element in previousArtists) {
        previousArtistList.add(element.toString());
      }
    }

    return Song(
        currentArtistList,
        song["name"],
        song["image"],
        song["songCurrentlyPlayed"],
        song["trackDuration"],
        song["recs"],
        previousArtistList,
        song["previousSong"],
        song["previousImage"],
        song["previousName"],
        song["previousTrackDuration"],
        song["previousRecs"]);
  }
}
