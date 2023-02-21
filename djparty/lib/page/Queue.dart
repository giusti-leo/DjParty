import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../entities/Track.dart';

class Queue extends StatefulWidget {
  static String routeName = 'Queue';
  final bool voting;
  const Queue({Key? key, required this.voting}) : super(key: key);
  @override
  State<Queue> createState() => _Queue();
}

class _Queue extends State<Queue> {
  final TextEditingController textController = TextEditingController();
  String endpoint = "https://api.spotify.com/v1/me/player/queue";
  String myToken = "";
  String input = "";
  List _tracks = [];
  List _queue = [];
  bool isCalled = false;
  bool changed = false;

  Stream<QuerySnapshot>? songs;

  List<dynamic>? firebaseSongs = [];
  List<Track>? queueSongs = [];
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
    //print(trackList);
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
    final fr = context.read<FirebaseRequests>();

    sp.getDataFromSharedPreferences();

    fr.getDataFromSharedPreferences();
    changed = false;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  bool userLikeSong(Track track) {
    final sp = context.read<SignInProvider>();

    return (track.likes.contains(sp.uid));
  }

  @override
  Widget build(BuildContext context) {
    final fr = context.read<FirebaseRequests>();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parties')
                .doc(fr.partyCode)
                .collection('queue')
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              return snapshot.hasData && snapshot.data.docs.length > 0
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
                                    ? Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(10.0),
                                            title: Text(currentTrack.name!,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                )),
                                            subtitle: Text(
                                                currentTrack.artists![0],
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
                                                userLikeSong(currentTrack)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color:
                                                    userLikeSong(currentTrack)
                                                        ? const Color.fromARGB(
                                                            228, 53, 191, 101)
                                                        : Colors.grey),
                                            onTap: () {
                                              _handleLikeLogic(currentTrack);
                                              print('1');
                                            },
                                          ),
                                          Text(
                                            'votes: ${currentTrack.likes.length}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const Divider(
                                            color: Colors.white24,
                                            height: 1,
                                          )
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(10.0),
                                            title: Text(currentTrack.name!,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                )),
                                            subtitle: Text(
                                                currentTrack.artists![0],
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
                                          ),
                                          Text(
                                            'votes: ${currentTrack.likes.length}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const Divider(
                                            color: Colors.white24,
                                            height: 1,
                                          )
                                        ],
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

  Future _handleLikeLogic(Track track) async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();

    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    if (!userLikeSong(track)) {
      _handleLikeSong(track);
    } else {
      _handleDisLikeSong(track);
    }
  }

  void _handleLikeSong(Track track) {
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

    List<String> newLikes = track.likes;
    newLikes.add(sp.uid!);

    setState(() {
      track.likes = newLikes;
    });

    fr.userLikesSong(track.uri!, sp.uid!).then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), Colors.red);
        return;
      }
    });
  }

  void _handleDisLikeSong(Track track) {
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

    List<String> newLikes = track.likes;
    newLikes.remove(sp.uid!);

    setState(() {
      track.likes = newLikes;
    });

    fr.userDoesNotLikeSong(track.uri!, sp.uid!).then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), Colors.red);
        return;
      }
    });
  }
}
