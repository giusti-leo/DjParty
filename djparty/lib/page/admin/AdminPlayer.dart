import 'dart:ffi';

import 'package:djparty/Icons/c_d_icons.dart';
import 'dart:math';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/admin/AdminTabPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:djparty/entities/Party.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:djparty/Icons/SizedIconButton.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/Home.dart';
import 'package:update_notification/screens/update_notification.dart';
import 'package:quickalert/quickalert.dart';

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
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
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

    return Column(
      children: [
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

  AdminPlayerSongRunning({Key? key, required this.tabController})
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
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
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
        final sr = context.read<SpotifyRequests>();

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
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('parties')
          .doc(fr.partyCode)
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
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('parties')
                          .doc(fr.partyCode)
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

                                      fr.setBackSkip(fr.partyCode!);
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
                                      fr.setPause(fr.partyCode!);
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
                                      fr.setSelection(fr.partyCode!);
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
                                      fr.setResume(fr.partyCode!);
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
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }
}

class AdminPlayerEnded extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const AdminPlayerEnded({Key? key}) : super(key: key);

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
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();

    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
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
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

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
                      .doc(fr.partyCode!)
                      .collection('members')
                      .doc(sp.uid)
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
                        height: 40,
                        child: RoundedLoadingButton(
                          onPressed: () {
                            _handleCreatePlaylist(context);
                          },
                          controller: partyController,
                          successColor: mainGreen,
                          width: width * 0.80,
                          elevation: 0,
                          borderRadius: 25,
                          color: mainGreen,
                          child: Wrap(
                            children: const [
                              Icon(
                                CD.spotify,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text("Get the Spotify Playlist of the Party!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
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
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();

    sr.createPlaylist(fr.partyName!, sr.userId!);

    Future.delayed(const Duration(seconds: 1), () {
      sr.addSongsToPlaylist(fr.partyCode!);
    });

    await fr.addPlaylist(sp.uid!, fr.partyCode!);

    displayToastMessage(
        context, 'Playlist ${fr.partyName} created!', mainGreen);
  }
}
