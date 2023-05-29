/*

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Party.dart';
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

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future<List<dynamic>> GetTracks() async {
    var response = await http.get(Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer $myToken"
        });
    final tracksJson = json.decode(response.body);
    var trackList = tracksJson['queue'].toList();
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
    final sp = context.read<SignInProvider>();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: mainGreen)),
        home: SizedBox(
          height: 5,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parties')
                .doc(fr.partyCode!)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Party party =
                    Party.getPartyFromFirestore(snapshot.data!.data());
                if (party.isEnded) {
                  return fullSongList(context);
                } else {
                  return FutureBuilder(
                      future: Future.delayed(const Duration(milliseconds: 500)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return queueListSong(context);
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                            color: mainGreen,
                            backgroundColor: backGround,
                            strokeWidth: 10,
                          ));
                        }
                        // Return empty container to avoid build errors
                      });
                }
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  color: mainGreen,
                  backgroundColor: backGround,
                  strokeWidth: 10,
                ));
              }
            },
          ),
        ));
  }

  Widget fullSongList(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .collection('queue')
            .orderBy('lastStreaming')
            .limit(50)
            .get(),
        builder: (context, AsyncSnapshot snap1) {
          bool empty = true;
          if (snap1.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
              strokeWidth: 10,
            ));
          }
          if (!snap1.hasData) {
            return const Center(
                child: Text(
              'No data found',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ));
          }
          if (snap1.data.docs.toString() == '[]') {
            return Center(
                child: RichText(
              text: TextSpan(
                text: 'Hello ',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                      text: '${sp.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const TextSpan(
                      text: '. No songs in your Queue!',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.white)),
                ],
              ),
            ));
          } else {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: mainGreen,
                      backgroundColor: backGround,
                      strokeWidth: 10,
                    ));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Text(
                      'No data found',
                      selectionColor: Colors.white,
                      strutStyle: StrutStyle(
                        fontSize: 20,
                      ),
                    ));
                  }

                  final partySnap = snapshot.data!.data();
                  Party party;
                  party = Party.getPartyFromFirestore(partySnap);

                  return Scaffold(
                      backgroundColor: backGround,
                      body: Column(children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: snap1.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final track = snap1.data.docs[index];
                                Track currentTrack =
                                    Track.getTrackFromFirestore(track);
                                return Column(
                                  children: [
                                    ListTile(
                                      tileColor:
                                          const Color.fromARGB(255, 35, 34, 34),
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      title: Text(currentTrack.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          )),
                                      subtitle: Text(currentTrack.artists[0],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color.fromARGB(
                                                255, 134, 132, 132),
                                          )),
                                      leading: Image.network(
                                        currentTrack.images,
                                        fit: BoxFit.cover,
                                        height: 60,
                                        width: 60,
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 1,
                                    ),
                                  ],
                                );
                              }),
                        )
                      ]));
                });
          }
        });
  }

  Widget queueListSong(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .collection('queue')
            .where('inQueue', isEqualTo: true)
            .orderBy('likes', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, AsyncSnapshot snap1) {
          bool empty = true;
          if (snap1.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
              strokeWidth: 10,
            ));
          }
          if (!snap1.hasData) {
            return const Center(
                child: Text(
              'No data found',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ));
          }
          if (snap1.data.docs.toString() == '[]') {
            return Center(
                child: RichText(
              text: TextSpan(
                text: 'Hello ',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                      text: '${sp.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const TextSpan(
                      text: '. Add some new songs!',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.white)),
                ],
              ),
            ));
          } else {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: mainGreen,
                      backgroundColor: backGround,
                      strokeWidth: 10,
                    ));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Text(
                      'No data found',
                      selectionColor: Colors.white,
                      strutStyle: StrutStyle(
                        fontSize: 20,
                      ),
                    ));
                  }

                  final partySnap = snapshot.data!.data();
                  Party party;
                  party = Party.getPartyFromFirestore(partySnap);

                  return Scaffold(
                      backgroundColor: backGround,
                      body: Column(children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: snap1.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final track = snap1.data.docs[index];
                                Track currentTrack =
                                    Track.getTrackFromFirestore(track);
                                //if (currentTrack.inQueue) empty = false;
                                if (party.votingStatus) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        tileColor: backGround,
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        title: Text(currentTrack.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            )),
                                        subtitle: Text(currentTrack.artists[0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color.fromARGB(
                                                  255, 134, 132, 132),
                                            )),
                                        leading: Image.network(
                                          currentTrack.images,
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: 60,
                                        ),
                                        trailing: Icon(
                                            userLikeSong(currentTrack)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: userLikeSong(currentTrack)
                                                ? mainGreen
                                                : Colors.white),
                                        onTap: () {
                                          _handleLikeLogic(currentTrack);
                                        },
                                      ),
                                      Text(
                                        'Like: ${currentTrack.likes.length}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
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
                                        subtitle: Text(currentTrack.artists![0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color.fromARGB(
                                                  255, 134, 132, 132),
                                            )),
                                        leading: Image.network(
                                          currentTrack.images,
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
                                }
                              }),
                        )
                      ]));
                });
          }
        });
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
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
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
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
        return;
      }
    });
  }
}
*/