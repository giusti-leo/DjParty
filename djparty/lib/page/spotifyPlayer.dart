//import 'dart:html';

import 'package:djparty/Icons/c_d_icons.dart';
import 'dart:math';
import 'package:djparty/entities/Track.dart';
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
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:provider/provider.dart';
//import 'package:linear_timer/linear_timer.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:djparty/Icons/SizedIconButton.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/Home.dart';
import 'package:update_notification/screens/update_notification.dart';
//import 'package:linear_timer/linear_timer.dart';
import 'package:quickalert/quickalert.dart';

class SpotifyPlayer extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const SpotifyPlayer({Key? key}) : super(key: key);

  @override
  _SpotifyPlayerState createState() => _SpotifyPlayerState();
}

class _SpotifyPlayerState extends State<SpotifyPlayer>
    with TickerProviderStateMixin {
  //late LinearTimerController timerController1 = LinearTimerController(this);
  bool nextSong = false;
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();
  //late LinearTimerController timerController = LinearTimerController(this);
  bool timerRunning = false;

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
  }

  String firstTrackUri = "";

  dynamic isPaused = true;
  double votingIndex = 0;
  bool _loading = false;
  bool _connected = true;
  int nextTrackIndex = 1;
  String nextTrackUri = "";
  bool changed = false;

  int trackDuration = 0;
  int timer = 0;

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

  late ImageUri? currentTrackImageUri;
  late ImageUri? image;

  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(158, 61, 219, 71),
              backgroundColor: Color.fromARGB(128, 52, 74, 61),
              strokeWidth: 10,
            ));
          }
          if (!snapshot.hasData) {
            return Container(
              alignment: Alignment.topCenter,
              child: const Text(
                "Server problems",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
            );
          } else {
            final partySnap = snapshot.data!.data();
            Party party;
            party = Party.getPartyFromFirestore(partySnap);

            if (party.isStarted && !party.isEnded) {
              if (party.status == 'R') {
                return StreamBuilder<ConnectionStatus>(
                  stream: SpotifySdk.subscribeConnectionStatus(),
                  builder: (context, snapshot) {
                    _connected = false;
                    var data = snapshot.data;
                    if (data != null) {
                      _connected = data.connected;
                    }

                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
                      body: _playerWidget(context),
                    );
                  },
                );
              } else {
                return Scaffold(
                  backgroundColor: const Color.fromARGB(255, 35, 34, 34),
                  body: Center(
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
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
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
                  )),
                );
              }
            } else if (party.isEnded) {
              return _EndParty(context);
            } else {
              if (sp.uid! == fr.admin) {
                return _adminLobby(context);
              } else {
                return _regularUserLobby(context, party.partecipantList.length);
              }
            }
          }
        });

    /*
            QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                text: 'It is Voting Time!',
                autoCloseDuration: const Duration(seconds: 3));
                */
/*
            if (party.songsReproduced == 0) {
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .collection('queue')
                    .where('admin', isEqualTo: sp.uid!)
                    .count()
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color.fromARGB(158, 61, 219, 71),
                      backgroundColor: Color.fromARGB(128, 52, 74, 61),
                      strokeWidth: 10,
                    ));
                  }
                  //ci sono canzoni nella coda che sono state aggiunte dall'utente
                  if (snapshot.data!.count > 0) {
                    /*
                    QuickAlert.show(
                          context: context,
                          type: QuickAlertType.info,
                          text: 'Music will start when Voting ends',
                          autoCloseDuration: const Duration(seconds: 3));
                          */

                    return Container();
                  }
                  
                  //non ci sono canzoni nella coda che sono state aggiunte dall'utente
                  /*
                    QuickAlert.show(
                        context: context,
                        type: QuickAlertType.info,
                        text:
                            'Now you can vote songs in the Queue!\nYou can also add more!',
                        autoCloseDuration: const Duration(seconds: 3));*/
                  return Container();
                },
              );
            }
          }
           else {
                  //non ci sono canzoni nella coda
                  /*
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    text:
                        'No songs in the Queue.\nPlease add your songs to the Queue',
                  );*/
                  return Container();
                }*/
  }

  Widget _regularUserLobby(BuildContext context, int n) {
    String text = 'There are $n partecipants';

    return Center(
      child: Column(
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(
            height: 20,
          ),
          const Text("Wait the admin starts the party",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _EndParty(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sr = context.read<SpotifyRequests>();
    final fr = context.read<FirebaseRequests>();
    bool pressed = false;

    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        const Text(
          "The current party is ended!",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () {
            if (pressed) {
              displayToastMessage(context,
                  'Playlist ${fr.partyName} already added!', Colors.green);
            } else {
              _handleCreatePlaylist(context);
              pressed = true;
            }
          },
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
      ],
    );
  }

  Widget _adminLobby(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return (Positioned(
      bottom: 20,
      child: RoundedLoadingButton(
        onPressed: () {
          setState(() {
            _handleStartParty(context);
          });
        },
        controller: partyController,
        successColor: const Color.fromRGBO(30, 215, 96, 0.9),
        width: width * 0.80,
        elevation: 0,
        borderRadius: 25,
        color: const Color.fromRGBO(30, 215, 96, 0.9),
        child: Wrap(
          children: const [
            Icon(
              FontAwesomeIcons.music,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(
              width: 15,
            ),
            Text("Start the Party",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ));
  }

  Future _addTrack() async {
    final fr = context.read<FirebaseRequests>();
    var db = FirebaseFirestore.instance.collection('parties').doc(fr.partyCode);
    await FirebaseFirestore.instance
        .collection('parties')
        .doc(fr.partyCode)
        .collection('queue')
        .orderBy('votes', descending: true)
        .get()
        .then((snapshot) async {
      if (snapshot.size > 0) {
        var snapDoc = snapshot.docs[0];
        Track track = Track.getTrackFromFirestore(snapDoc);

        await db.update({
          "status": 'R',
          "songCurrentlyPlayed": track.uri,
          "songsReproduced": FieldValue.increment(1)
        });
        await db.collection('queue').doc(track.uri).update({'inQueue': false});
        await db.collection('members').doc(track.admin).update({
          'points': 2,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .collection('queue')
            .get()
            .then((value) async {
          Random random = new Random();
          int randomNumber = random.nextInt(snapshot.size);
          var snapDoc = snapshot.docs[randomNumber];
          Track track = Track.getTrackFromFirestore(snapDoc);
          await db.update({
            "status": 'R',
            "songCurrentlyPlayed": track.uri,
            "songsReproduced": FieldValue.increment(1)
          });
        });
      }
      play(firstTrackUri);
    });
  }

  Future _handleStartParty(BuildContext context) async {
    pause();
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      partyController.reset();
      return;
    }

    fr.checkPartyExists(code: fr.partyCode!).then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        partyController.reset();
        return;
      }
      Future.delayed(const Duration(milliseconds: 1000));
      fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
        fr.saveDataToSharedPreferences().then((value) {
          fr.setPartyStarted(fr.partyCode!).then((value) {
            if (sp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              partyController.reset();
              return;
            }
            fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
              if (sp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                partyController.reset();
                return;
              }
              fr.saveDataToSharedPreferences().then((value) {
                if (sp.hasError == true) {
                  showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                  partyController.reset();
                  return;
                }
                partyController.success();
              });
            });
          });
        });
      });
    });
  }

  Widget _playerWidget(BuildContext context) {
    final fr = context.read<FirebaseRequests>();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(158, 61, 219, 71),
              backgroundColor: Color.fromARGB(128, 52, 74, 61),
              strokeWidth: 10,
            ));
          }
          if (!snapshot.hasData) {
            return Container();
          }
          var currentSong = snapshot.data.get('songCurrentlyPlayed');
          if (currentSong == '') {
            return const Center(
                child: Text('No song selected',
                    style: TextStyle(color: Colors.white)));
          }
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('parties')
                .doc(fr.partyCode)
                .collection('queue')
                .doc(currentSong)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color.fromARGB(158, 61, 219, 71),
                  backgroundColor: Color.fromARGB(128, 52, 74, 61),
                  strokeWidth: 10,
                ));
              }
              Track track = Track.getTrackFromFirestore(snapshot.data!.data());
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 35, 34, 34),
                body: Center(
                    child: Column(
                  children: [
                    const SizedBox(height: 50),
                    SizedBox(
                        width: 250,
                        height: 250,
                        child: Image.network(track.images)),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            track.artists.first,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
              );
            },
          );
        });
  }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'From: ${playerContext.title} (${playerContext.type})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            setStatus(snapshot.error.toString());
            return SizedBox(
              width: ImageDimension.small.value.toDouble(),
              height: ImageDimension.small.value.toDouble(),
              child: const Center(child: Text('Error getting image')),
            );
          } else {
            return SizedBox(
              width: ImageDimension.small.value.toDouble(),
              height: ImageDimension.small.value.toDouble(),
              child: const Center(child: Text('Getting image...')),
            );
          }
        });
  }

  Future<void> play(String uri) async {
    try {
      await SpotifySdk.play(spotifyUri: uri);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

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

  // Future<void> resume() async {
  //   isPaused = false;
  //   try {
  //     await SpotifySdk.resume();
  //   } on PlatformException catch (e) {
  //     setStatus(e.code, message: e.message);
  //   } on MissingPluginException {
  //     setStatus('not implemented');
  //   }
  // }

  // Future<void> skipNext() async {
  //   try {
  //     await SpotifySdk.skipNext();
  //   } on PlatformException catch (e) {
  //     setStatus(e.code, message: e.message);
  //   } on MissingPluginException {
  //     setStatus('not implemented');
  //   }
  // }

  // Future<void> skipPrevious() async {
  //   try {
  //     await SpotifySdk.skipPrevious();
  //   } on PlatformException catch (e) {
  //     setStatus(e.code, message: e.message);
  //   } on MissingPluginException {
  //     setStatus('not implemented');
  //   }
  // }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}

void _handleCreatePlaylist(BuildContext context) {
  final sr = context.read<SpotifyRequests>();
  final fr = context.read<FirebaseRequests>();
  sr.createPlaylist(fr.partyName!, sr.userId!);
  //sr.getPlaylistId(sr.userId!, fr.partyName!);

  Future.delayed(const Duration(seconds: 1), () {
    sr.addSongsToPlaylist(fr.partyCode!);
  });

  displayToastMessage(
      context, 'Playlist ${fr.partyName} created!', Colors.green);
}
