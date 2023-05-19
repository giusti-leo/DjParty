import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:djparty/entities/Party.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/PartySettings.dart';
import 'package:djparty/page/RankingPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/spotifyPlayer.dart';
import 'package:djparty/page/Queue.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/Icons/c_d_icons.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wakelock/wakelock.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SpotifyTabController extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  const SpotifyTabController({Key? key}) : super(key: key);

  @override
  _SpotifyTabController createState() => _SpotifyTabController();
}

class _SpotifyTabController extends State<SpotifyTabController>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  dynamic isPaused = true;
  bool error = false;
  bool voting = false;
  bool changed = false;
  bool countdown = false;
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  late DateTime _nextVotingPhase;

  final key = GlobalKey();
  File? file;

  int nextTrackIndex = 1;
  String nextTrackUri = "";
  String partyID = '';
  bool ended = false;

  bool spotifyAlert = false;

  int _interval = 0;
  int _votingTime = 0;
  bool _votingStatus = false;
  int endCountdown = 0;
  late LinearTimerController timerController1 = LinearTimerController(this);
  final RoundedLoadingButtonController exitController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  int _computeCountdown() {
    DateTime tmpNow = DateTime.now();
    return tmpNow.millisecondsSinceEpoch +
        _nextVotingPhase.difference(tmpNow).inMilliseconds;
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();

    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
    sr.getUserId();
    sr.getAuthToken();

    partyID = fr.partyCode!;

    if (sp.uid == fr.admin) {
      sr.connectToSpotify();
      Wakelock.enable();
    }

    await FirebaseFirestore.instance
        .collection('parties')
        .doc(fr.partyCode)
        .get()
        .then((value) {
      setState(() {
        voting = value.get('votingStatus');
      });
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    voting = false;
    changed = false;
    getData();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isBackground = state == AppLifecycleState.paused;
    final isDetached = state == AppLifecycleState.detached;
    final isInactive = state == AppLifecycleState.inactive;
    final isResumed = state == AppLifecycleState.resumed;

    if (isBackground || isDetached || isInactive) {
      pause();
      timerController1.stop();
    }
    if (isResumed) {
      resume();
      timerController1.start();
    }
  }

  void showSpotifyAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            title: const Text(
              "Warning",
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 250,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "DJParty can not work while Spotify app is opened. Please close it!",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          spotifyAlert = true;
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: const Text(
                          "Close",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showDataAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            title: const Text(
              "Warning",
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 250,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "No party can't continue without its admin. If you exit the party wiil end.",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          pause();
                          _adminEndParty(context);
                          _handleStepBack();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: const Text(
                          "End the party",
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: const Text(
                          "Ignore",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 4, vsync: this);
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();
    final sr = context.read<SpotifyRequests>();

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    Future<bool> _onWillPop() async {
      fr.getDataFromSharedPreferences();
      if (fr.isEnded == true) {
        return true;
      }
      return false; //<-- SEE HERE
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: backGround)),
        home: Scaffold(
          backgroundColor: backGround,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: backGround,
            title: Text(
              fr.partyName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: Expanded(
              child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (sp.uid! != fr.admin) {
                      _handleStepBack();
                    } else {
                      fr.getDataFromSharedPreferences();
                      if (fr.isStarted! && (!fr.isEnded! && !ended)) {
                        showDataAlert(context);
                      } else {
                        _handleStepBack();
                      }
                    }
                  }),
            ),
            actions: (fr.admin == sp.uid)
                ? [
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        // PopupMenuItem 1
                        PopupMenuItem(
                            value: 1,
                            // row with 2 children
                            child: TextButton(
                              onPressed: () {
                                handleShare(fr.partyCode!);

                                Navigator.of(context).pop();
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.share),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Share",
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              ),
                            )),
                        (!fr.isStarted!)
                            ? PopupMenuItem(
                                value: 2,
                                // row with 2 children
                                child: TextButton(
                                  onPressed: () {
                                    nextScreen(context, const PartySettings());
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.settings),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "Settings",
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ],
                                  ),
                                ))
                            : PopupMenuItem(
                                value: 2,
                                // row with two children
                                child: TextButton(
                                  onPressed: () {
                                    pause();
                                    _handleEndParty(context);
                                    Navigator.of(context).pop();
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.stop),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "End party",
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ],
                                  ),
                                )),
                      ],
                      offset: const Offset(0, 100),
                      color: Colors.white,
                      elevation: 1,
                    ),
                  ]
                : [
                    PopupMenuButton<int>(
                        itemBuilder: (context) => [
                              // PopupMenuItem 1
                              PopupMenuItem(
                                  value: 1,
                                  // row with 2 children
                                  child: TextButton(
                                    onPressed: () {
                                      handleShare(fr.partyCode!);
                                      Navigator.of(context).pop();
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.settings),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Share",
                                          style: TextStyle(color: Colors.black),
                                        )
                                      ],
                                    ),
                                  )),
                            ])
                  ],
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(children: [
              Align(
                alignment: Alignment.center,
                child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.only(left: 20, right: 20),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: CircleTabIndicator(color: mainGreen, radius: 4),
                    tabs: const [
                      Tab(text: "Player"),
                      Tab(text: "Search"),
                      Tab(text: "Queue"),
                      Tab(text: "Ranking"),
                    ]),
              ),
              SizedBox(
                width: double.maxFinite,
                height: constraints.maxHeight - 58,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    const SpotifyPlayer(),
                    const SearchItemScreen(),
                    Queue(
                      voting: voting,
                    ),
                    const RankingPage(),
                  ],
                ),
              ),
              SizedBox(
                height: 1,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('parties')
                        .doc(fr.partyCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: mainGreen,
                          backgroundColor: backGround,
                          strokeWidth: 10,
                        ));
                      }
                      final partySnap = snapshot.data!.data();
                      Party party;
                      party = Party.getPartyFromFirestore(partySnap);

                      if (party.isStarted && !party.isEnded) {
                        if (party.admin == sp.uid && party.status == 'S') {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('parties')
                                  .doc(fr.partyCode)
                                  .collection('queue')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    color: mainGreen,
                                    backgroundColor: backGround,
                                    strokeWidth: 10,
                                  ));
                                }
                                if (snapshot.hasData &&
                                    snapshot.data!.size > 0) {
                                  _addTrack();
                                }
                                return Container();
                              });
                        }
                      }
                      return Container();
                    }),
              ),
            ]);
          }),
          bottomNavigationBar: _buildBottomBar(context),
        ),
      ),
    );
  }

  Future handleShare(String string) async {
    try {
      var image = await QrPainter(
        data: string,
        version: 1,
        gapless: false,
        color: const Color(0x00000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImage(300);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final appDir = await getApplicationDocumentsDirectory();
      var datetime = DateTime.now();
      file = await File('${appDir.path}/$datetime.png').create();
      await file?.writeAsBytes(pngBytes);

      await Share.shareFiles(
        [file!.path],
        mimeTypes: ["image/png"],
        text: "Scan this Qr-Code to join my SpotiParty!" +
            " Or insert this code: $string",
      );

      Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      displayToastMessage(context, e.toString(), alertColor);
      return;
    }
  }

  Future _addTrack() async {
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();

    var db = FirebaseFirestore.instance.collection('parties').doc(fr.partyCode);
    String trackUri = '';

    await FirebaseFirestore.instance
        .collection('parties')
        .doc(fr.partyCode)
        .collection('queue')
        .where('inQueue', isEqualTo: true)
        .orderBy('likes', descending: true)
        .limit(1)
        .get()
        .then((value) async {
      if (value.size > 0) {
        var el = value.docs[0];
        Track track = Track.getTrackFromFirestore(el);
        trackUri = track.uri;
        await db.update({
          "status": 'R',
          "songCurrentlyPlayed": track.uri,
        }).then((value) async {
          await db.collection('queue').doc(track.uri).update({
            'inQueue': false,
            'lastStreaming': Timestamp.now(),
            'Streamings': FieldValue.increment(1)
          }).then((value) {
            db.collection('members').doc(track.admin).update({
              'points': FieldValue.increment(2),
            }).then((value) {
              for (var element in track.likes) {
                db.collection('members').doc(element).update({
                  'points': FieldValue.increment(1),
                });
              }
            });
          });
        });
      } else {
        FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .collection('queue')
            .get()
            .then((snapshot) async {
          Random random = Random();
          int randomNumber = random.nextInt(snapshot.size);
          var snapDoc = snapshot.docs[randomNumber];
          Track track = Track.getTrackFromFirestore(snapDoc);
          trackUri = track.uri;
          await db.collection('queue').doc(track.uri).update({
            'Streamings': FieldValue.increment(1),
            'lastStreaming': Timestamp.now(),
            'inQueue': false,
          }).then((value) async {
            await db.update({
              "status": 'R',
              "songCurrentlyPlayed": track.uri,
            });
          });
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => play(trackUri));
  }

  Future _adminEndParty(BuildContext context) async {
    final CollectionReference partyCollection =
        FirebaseFirestore.instance.collection("parties");

    await partyCollection.doc(partyID).update({
      'isEnded': true,
    }).onError((error, stackTrace) {
      displayToastMessage(context, error.toString(), alertColor);
      return;
    });
    ended = true;
    displayToastMessage(context, 'Party ended correctly', mainGreen);
  }

  Future _handleEndParty(BuildContext context) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();
    var db = FirebaseFirestore.instance
        .collection('parties')
        .doc(fr.partyCode)
        .collection('queue')
        .orderBy("Timestamp");

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      partyController.reset();
      return;
    }

    fr.checkPartyExists(code: fr.partyCode!).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        partyController.reset();
        return;
      }
      if (value == true) {
        partyController.success();
        Future.delayed(const Duration(milliseconds: 1000));
        fr.setPartyEnded(fr.partyCode!).then((value) {
          if (sp.hasError == true) {
            displayToastMessage(context, sp.errorCode.toString(), alertColor);
            partyController.reset();
            return;
          }
          fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
            if (sp.hasError == true) {
              displayToastMessage(context, sp.errorCode.toString(), alertColor);
              partyController.reset();
              return;
            }
            fr.saveDataToSharedPreferences().then((value) {
              if (sp.hasError == true) {
                displayToastMessage(
                    context, sp.errorCode.toString(), alertColor);
                partyController.reset();
                return;
              }
              displayToastMessage(context, 'Party ended correctly', mainGreen);
            });
          });
        });
      }
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();

    return SizedBox(
        height: 55,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parties')
                .doc(fr.partyCode)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
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
                if (!(snapshot.data.get('isStarted') &&
                    !snapshot.data.get('isEnded'))) {
                  return const SizedBox();
                } else {
                  countdown = true;

                  _nextVotingPhase =
                      (snapshot.data!.get("nextVotingPhase") as Timestamp)
                          .toDate();

                  _interval = snapshot.data!.get('timer');
                  _votingTime = snapshot.data!.get('votingTime');
                  _votingStatus = snapshot.data!.get('votingStatus');

                  endCountdown = _computeCountdown();

                  endCountdown =
                      (sp.uid == fr.admin) ? endCountdown : endCountdown + 1000;
                  return _bottomAppBar(context);
                }
              }
            }));
  }

  Widget _bottomAppBar(BuildContext context) {
    return SizedBox(
      height: 55,
      child: BottomAppBar(
        elevation: 8.0,
        notchMargin: 8.0,
        color: backGround,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _linearTimerWidget(context),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: Text(
                    !_votingStatus
                        ? "Next voting in :  "
                        : "Voting ends in :  ",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
              _countdown(context),
            ])
          ],
        ),
      ),
    );
  }

  Widget _linearTimerWidget(BuildContext context) {
    return SizedBox(
      height: 5,
      child: StreamBuilder<PlayerState>(
        stream: SpotifySdk.subscribePlayerState(),
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          if (snapshot.data?.track == null ||
              snapshot.data!.track?.duration == null ||
              snapshot.data == null) {
            return Center(
              child: Container(),
            );
          }
          var track = snapshot.data?.track;
          var playerState = snapshot.data;
          int trackDuration = track!.duration;

          if (playerState == null) {
            return Center(
              child: Container(),
            );
          }

          if (playerState.isPaused == true) {
            isPaused = true;
            timerController1.stop();
          } else {
            isPaused = false;
            timerController1.start();
          }

          return LinearTimer(
            duration: Duration(milliseconds: trackDuration - 2000),
            color: mainGreen,
            backgroundColor: Colors.grey[200],
            controller: timerController1,
            onTimerEnd: () {
              _setSelection();
              Future.delayed(const Duration(milliseconds: 1000));
              timerController1.reset();
            },
          );
        },
      ),
    );
  }

  Future _setSelection() async {
    final fr = context.read<FirebaseRequests>();
    var db = FirebaseFirestore.instance.collection('parties').doc(fr.partyCode);
    await db
        .update({"status": 'S', 'songsReproduced': FieldValue.increment(1)});
  }

  Future _playNextTrack() async {
    final fr = context.read<FirebaseRequests>();
    var db = FirebaseFirestore.instance.collection('parties').doc(fr.partyCode);
    var queue = db.collection('queue').orderBy("timestamp");
    await queue.get().then(((snapshot) {
      var SnapDoc = snapshot.docs[nextTrackIndex];
      nextTrackUri = SnapDoc["uri"];
      db.update({"songCurrentlyPlayed": nextTrackUri});
      play(nextTrackUri);
    }));
    nextTrackIndex++;
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

  Future<void> play(String uri) async {
    final sr = context.read<SpotifyRequests>();
    try {
      await SpotifySdk.play(spotifyUri: uri).onError((error, stackTrace) {
        print(error.toString());

        if (error.toString() == '_logException') {
          sr.connectToSpotify();
          sr.getAuthToken();
          play(uri);
        }
      });
    } on PlatformException catch (e) {
      displayToastMessage(context, e.message!, alertColor);
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }

  Widget _countdown(BuildContext context) {
    return CountdownTimer(
      endTime: endCountdown,
      widgetBuilder: (_, time) {
        if (time == null) {
          return const Text('');
        }
        if (time.hours == null) {
          if (time.min != null && time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("00:0${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }

          if (time.min == null) {
            if (time.sec! / 10 < 1) {
              return Text("00:00:0${time.sec}",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:00:${time.sec}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          if (time.sec! / 10 < 1) {
            return Text("00:${time.min}:0${time.sec}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("00:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }
        if (time.hours! / 10 < 1) {
          if (time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("0${time.hours}:${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("0${time.hours}:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("0${time.hours}:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }

        return Text("${time.hours}:${time.min}:${time.sec}",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: mainGreen,
            ));
      },
      onEnd: () async {
        await _handleEndCountdown();
      },
    );
  }

  Future _handleEndCountdown() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    if (sp.uid != fr.admin) {
      return;
    }

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      return;
    }

    bool tmpStatus = !_votingStatus;

    DateTime _newNextVotingPhase = (_votingStatus)
        ? _nextVotingPhase.add(Duration(minutes: _interval))
        : _nextVotingPhase.add(Duration(minutes: _votingTime));

    await fr.changeStatus(tmpStatus, _newNextVotingPhase).then((value) {
      if (fr.hasError) {
        displayToastMessage(context, fr.errorCode.toString(), alertColor);
        return;
      }
    });

    voting = tmpStatus;
  }

  _handleStepBack() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const HomePage());
    });
  }
}

Future<void> pause() async {
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
}

class CircleTabIndicator extends Decoration {
  final Color color;
  double radius;

  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final double radius;
  late Color color;

  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    late Paint paint;
    paint = Paint()..color = color;
    paint = paint..isAntiAlias = true;
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, paint);
  }
}
