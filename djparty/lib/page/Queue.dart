import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:flutter/material.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../entities/Track.dart';

class Queue extends StatefulWidget {
  static String routeName = 'Queue';
  final String code;
  final bool voting;
  const Queue({Key? key, required this.code, required this.voting})
      : super(key: key);
  @override
  State<Queue> createState() => _Queue();
}

class _Queue extends State<Queue> {
  final TextEditingController textController = TextEditingController();
  String endpoint = "https://api.spotify.com/v1/me/player/queue";
  String myToken = "";
  String input = "";
  List _tracks = [];
  bool isCalled = false;
  bool changed = false;

  Stream<QuerySnapshot>? songs;

  List<String>? mySongs = [];
  List<String>? newDeletedSongs = [];
  List<String>? newLikedSongs = [];

  Future<List<dynamic>> GetTracks() async {
    var response = await http.get(Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + myToken
        });
    final tracksJson = json.decode(response.body);
    var trackList = tracksJson['queue'].toList();
    print(trackList);
    _tracks = trackList;

    return trackList;
  }

  Future _updateTracks() async {
    List<dynamic> tracks = await GetTracks();
    setState(() {
      _tracks = tracks;
    });
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    sp.getDataFromSharedPreferences();
    changed = false;

    fr.getSongs(code: widget.code).then((val) {
      setState(() {
        songs = val;
      });
    });

    fr.getMySongs(code: widget.code, user: sp.uid).then((val) {
      setState(() {
        mySongs = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  bool userLikeSong(String uri) {
    if (mySongs!.isEmpty || mySongs == null) return false;
    return mySongs!.contains(uri);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: StreamBuilder(
            stream: songs,
            builder: (context, AsyncSnapshot snapshot) {
              return snapshot.hasData
                  ? Scaffold(
                      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
                      body: Column(children: [
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final track = snapshot.data.docs[index];
                                Track currentTrack =
                                    Track.getTrackFromFirestore(track);
                                return (widget.voting)
                                    ? ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        title: Text(currentTrack.name!,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            )),
                                        subtitle: Text(currentTrack.artists![0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color.fromARGB(
                                                  255, 134, 132, 132),
                                            )),
                                        leading: Image.network(
                                          currentTrack.images!,
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: 60,
                                        ),
                                        trailing: Icon(
                                            userLikeSong(currentTrack.uri!)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                userLikeSong(currentTrack.uri!)
                                                    ? const Color.fromARGB(
                                                        228, 53, 191, 101)
                                                    : Colors.grey),
                                        onTap: () {
                                          setState(() {
                                            _likeButtonLogic(currentTrack);
                                          });
                                        })
                                    : ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        title: Text(currentTrack.name!,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            )),
                                        subtitle: Text(currentTrack.artists![0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color.fromARGB(
                                                  255, 134, 132, 132),
                                            )),
                                        leading: Image.network(
                                          currentTrack.images!,
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: 60,
                                        ),
                                      );
                              }),
                        )
                      ]))
                  : Container(
                      alignment: Alignment.topCenter,
                      child: const Text(
                        "Add song to the queue",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    );
            }));
  }

  Future<String> getAuthToken() async {
    var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: 'a502045e3c4b47d6b9bcfded418afd32',
        redirectUrl: 'test-1-login://callback',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing,'
            'playlist-modify-private,'
            'user-read-playback-state');
    myToken = '$authenticationToken';
    _updateTracks();
    print(myToken);
    return authenticationToken;
  }

  void _likeButtonLogic(Track currentTrack) {
    if (!changed) changed = true;
    if (!userLikeSong(currentTrack.uri!)) {
      newLikedSongs!.add(currentTrack.uri!);
      if (newDeletedSongs!.contains(currentTrack.uri)) {
        newDeletedSongs!.remove(currentTrack.uri);
      }
      currentTrack.vote = currentTrack.vote! - 1;
    } else {
      newDeletedSongs!.add(currentTrack.uri!);
      if (newLikedSongs!.contains(currentTrack.uri)) {
        newLikedSongs!.remove(currentTrack.uri);
      }
      currentTrack.vote = currentTrack.vote! + 1;
    }
  }
}
