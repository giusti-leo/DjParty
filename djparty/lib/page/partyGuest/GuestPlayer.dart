import 'package:djparty/Icons/c_d_icons.dart';
import 'package:djparty/entities/Track.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:djparty/services/SpotifyRequests.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class GuestPlayerNotStarted extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const GuestPlayerNotStarted({Key? key}) : super(key: key);

  @override
  _GuestPlayerNotStarted createState() => _GuestPlayerNotStarted();
}

class _GuestPlayerNotStarted extends State<GuestPlayerNotStarted>
    with TickerProviderStateMixin {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  bool isPaused = false;

  Future getData() async {
    final sr = context.read<SpotifyRequests>();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _adminLobby(context));
  }

  Widget _adminLobby(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(children: [
      SizedBox(
        height: height * 0.052,
      ),
      SizedBox(
        height: height * 0.6,
        child: Center(
            child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 400,
                height: 400,
                colorBlendMode: BlendMode.hardLight,
              ),
            ),
            const Center(
              child: Text(
                'Songs in the Queue will be reproduced\nwhen the party will start.\nWait the admin starts the party!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )),
      )
    ]);
  }
}

class GuestPlayerSongRunning extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  String code;

  GuestPlayerSongRunning({Key? key, required this.code}) : super(key: key);

  @override
  _GuestPlayerSongRunning createState() => _GuestPlayerSongRunning();
}

class _GuestPlayerSongRunning extends State<GuestPlayerSongRunning>
    with TickerProviderStateMixin {
  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sr = context.read<SpotifyRequests>();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(children: [
        SizedBox(
          height: height * 0.052,
        ),
        Expanded(
          child: _playerWidget(context),
        ),
      ]),
    );
  }

  Widget _playerWidget(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('parties')
          .doc(widget.code)
          .collection('Party')
          .doc('Song')
          .snapshots(),
      builder: (context, AsyncSnapshot snap) {
        if (!snap.hasData) {
          return Container();
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: mainGreen,
            backgroundColor: backGround,
            strokeWidth: 10,
          ));
        }

        final songSnap = snap.data!.data();
        Song song;
        song = Song.getPartyFromFirestore(songSnap);

        return Column(
          children: [
            const SizedBox(height: 50),
            (song.uri != '')
                ? SizedBox(
                    width: 250, height: 250, child: Image.network(song.images))
                : SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 400,
                      height: 400,
                      colorBlendMode: BlendMode.hardLight,
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            (song.uri != '')
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text(
                          song.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          song.artists.first,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ])
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text(
                          'No Music in reprodution',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ]),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }
}

class GuestPlayerEnded extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  String code;
  FirebaseFirestore db;

  GuestPlayerEnded({Key? key, required this.code, required this.db})
      : super(key: key);

  @override
  _GuestPlayerEnded createState() => _GuestPlayerEnded();
}

class _GuestPlayerEnded extends State<GuestPlayerEnded>
    with TickerProviderStateMixin {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sr = context.read<SpotifyRequests>();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _endParty(context));
  }

  Widget _endParty(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: height * 0.051,
        ),
        Column(
          children: [
            FutureBuilder(
              future: widget.db.collection('parties').doc(widget.code).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: mainGreen,
                    backgroundColor: backGround,
                    strokeWidth: 10,
                  ));
                }

                Timestamp endTime = snapshot.data!.data()!['endTime'];
                Timestamp startTime = snapshot.data!.data()!['startTime'];

                int duration =
                    endTime.toDate().difference(startTime.toDate()).inMinutes;

                return SizedBox(
                  height: 30,
                  child: Text('The party lasted $duration min',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                );
              },
            ),
            const SizedBox(
              height: 5,
            ),
            FutureBuilder(
              future: widget.db
                  .collection('parties')
                  .doc(widget.code)
                  .collection('members')
                  .orderBy('points', descending: true)
                  .limit(1)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: mainGreen,
                    backgroundColor: backGround,
                    strokeWidth: 10,
                  ));
                }

                String username = snapshot.data!.docs[0]['username'];
                String imageUrl = snapshot.data!.docs[0]['image_url'];

                return SizedBox(
                  height: height * 0.3,
                  child: Column(
                    children: [
                      const Text('And the King of the Party is...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                      (imageUrl != '')
                          ? CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.025,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage('${imageUrl}'),
                                maxRadius: height * 0.022,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.025,
                              child: CircleAvatar(
                                  maxRadius: height * 0.022,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    username[0].toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontStyle: FontStyle.italic),
                                  ))),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(
              height: 5,
            ),
            FutureBuilder(
              future: widget.db
                  .collection('parties')
                  .doc(widget.code)
                  .collection('queue')
                  .orderBy('likes', descending: true)
                  .limit(1)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: mainGreen,
                    backgroundColor: backGround,
                    strokeWidth: 10,
                  ));
                }

                Track song =
                    Track.getTrackFromFirestore(snapshot.data!.docs[0]);

                return SizedBox(
                  height: height * 0.2,
                  child: Column(
                    children: [
                      const Text('The most voted song was: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                              width: 250,
                              height: 250,
                              child: Image.network(song.images)),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  song.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  song.artists.first,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ]),
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          ],
        )
      ],
    );
  }

  void _handleCreatePlaylist(BuildContext context) {
    final sr = context.read<SpotifyRequests>();
    sr.createPlaylist('DjParty_${widget.code}', sr.userId);

    Future.delayed(const Duration(seconds: 1), () {
      sr.addSongsToPlaylist(widget.code);
    });

    displayToastMessage(
        context, 'Playlist named DjParty_${widget.code} created!', mainGreen);
  }
}
