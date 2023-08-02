import 'package:djparty/Icons/c_d_icons.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/admin/AdminTabPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:djparty/entities/Party.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/services.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class AdminPlayerNotStarted extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const AdminPlayerNotStarted({Key? key}) : super(key: key);

  @override
  _AdminPlayerNotStarted createState() => _AdminPlayerNotStarted();
}

class _AdminPlayerNotStarted extends State<AdminPlayerNotStarted>
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

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.052,
          ),
          SizedBox(
            height: height,
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
                    'Songs in the Queue will be reproduced\n when the party will start',
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
        ],
      ),
    );
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  Future<void> pause() async {
    isPaused = true;
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}

class AdminPlayerSongRunning extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  String code;
  FirebaseFirestore db;

  AdminPlayerSongRunning(
      {Key? key,
      required this.tabController,
      required this.db,
      required this.code})
      : super(key: key);
  TabController tabController;

  @override
  _AdminPlayerSongRunning createState() => _AdminPlayerSongRunning();
}

class _AdminPlayerSongRunning extends State<AdminPlayerSongRunning>
    with TickerProviderStateMixin {
  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  late LinearTimerController timerController1 = LinearTimerController(this);

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

    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        var data = snapshot.data;

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
      },
    );
  }

  Widget _playerWidget(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: widget.db
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
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
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: widget.db
                          .collection('parties')
                          .doc(widget.code)
                          .collection('Party')
                          .doc('MusicStatus')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        } else {
                          final partySnap = snapshot.data!.data();
                          MusicStatus musicStatus;
                          musicStatus =
                              MusicStatus.getPartyFromFirestore(partySnap);

                          if (musicStatus.running!) {
                            if (musicStatus.pause == false) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Icon(
                                        Icons.skip_previous,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      pause();
                                      fr.setBackSkip(widget.code);
                                    },
                                  ),
                                  SizedBox(
                                    width: width * 0.1,
                                  ),
                                  IconButton(
                                    icon: const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Icon(
                                        Icons.stop,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      pause();
                                      fr.setPause(widget.code);
                                    },
                                  ),
                                  SizedBox(
                                    width: width * 0.1,
                                  ),
                                  IconButton(
                                    icon: const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Icon(
                                        Icons.skip_next,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      pause();
                                      fr.setSelection(widget.code);
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      resume();
                                      fr.setResume(widget.code);
                                    },
                                  )
                                ],
                              );
                            }
                          }
                          return Container();
                        }
                      })
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> pause() async {
    final sr = context.read<SpotifyRequests>();

    try {
      SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      if (e.message != '') {
        sr.getUserId();
        sr.getAuthToken();
        sr.connectToSpotify();
        pause();
      }
    } on MissingPluginException {
      setStatus('not implemented');
    } on Exception catch (e) {
      pause();
      rethrow;
    }
  }

  Future<void> resume() async {
    final sr = context.read<SpotifyRequests>();
    try {
      await SpotifySdk.resume().onError((error, stackTrace) {
        print(error.toString());

        if (error.toString() == '_logException') {
          sr.connectToSpotify();
          sr.getAuthToken();
          resume();
        }
      });
    } on PlatformException catch (e) {
      displayToastMessage(context, e.message!, alertColor);
      if (e.message != '') {
        sr.getUserId();
        sr.getAuthToken();
        sr.connectToSpotify();
        pause();
      }
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }
}

class AdminPlayerEnded extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  User loggedUser;
  FirebaseFirestore db;
  String code;

  AdminPlayerEnded(
      {super.key,
      required this.loggedUser,
      required this.code,
      required this.db});

  @override
  _AdminPlayerEnded createState() => _AdminPlayerEnded();
}

class _AdminPlayerEnded extends State<AdminPlayerEnded>
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
        SizedBox(
          height: height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('parties')
                      .doc(widget.code)
                      .collection('members')
                      .doc(widget.loggedUser.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    bool spotifyPlaylist =
                        snapshot.data!.get('playlistSpotify');
                    if (spotifyPlaylist) {
                      return const SizedBox(
                        height: 40,
                        child: Text(
                            "Playlist of the party already added to Spotify!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      );
                    } else {
                      return SizedBox(
                        height: height * 0.05,
                        width: width * 0.70,
                        child: RoundedLoadingButton(
                          onPressed: () {
                            _handleCreatePlaylist(context);
                          },
                          controller: partyController,
                          successColor: mainGreen,
                          elevation: 0,
                          borderRadius: 25,
                          color: mainGreen,
                          child: Wrap(
                            children: const [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                CD.spotify,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Get the Spotify Playlist of the Party!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }

  void _handleCreatePlaylist(BuildContext context) async {
    final sr = context.read<SpotifyRequests>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    sr.createPlaylist('DjParty_${widget.code}', sr.userId);

    Future.delayed(const Duration(seconds: 1), () {
      sr.addSongsToPlaylist(widget.code);
    });

    await fr.addPlaylist(widget.loggedUser.uid, widget.code);

    displayToastMessage(
        context, 'Playlist name  DjParty_${widget.code} created!', mainGreen);
  }
}
