import 'dart:async';
import 'dart:math';
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
import 'package:djparty/page/VotingPage.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/Icons/c_d_icons.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:provider/provider.dart';
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
    with TickerProviderStateMixin {
  dynamic isPaused = true;
  bool error = false;
  bool voting = false;
  bool changed = false;
  bool countdown = false;
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  late DateTime _nextVotingPhase;

  int nextTrackIndex = 1;
  String nextTrackUri = "";

  int _interval = 0;
  int _votingTime = 0;
  bool _votingStatus = false;
  int endCountdown = 0;
  late LinearTimerController timerController1 = LinearTimerController(this);

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

    if (sp.uid == fr.admin) {
      sr.connectToSpotify();
      sr.getAuthToken();
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
    voting = false;
    changed = false;
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 4, vsync: this);
    final fr = context.read<FirebaseRequests>();
    final sp = context.read<SignInProvider>();
    final sr = context.read<SpotifyRequests>();

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(228, 53, 191, 101),
              secondary: const Color.fromARGB(255, 35, 34, 34))),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 35, 34, 34),
          title: Text(
            fr.partyName!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: (sp.uid == fr.admin)
              ? RoundedLoadingButton(
                  onPressed: () {
                    _handleEndParty(context);
                    pause();
                  },
                  controller: partyController,
                  successColor: const Color.fromRGBO(30, 215, 96, 0.9),
                  width: 30,
                  elevation: 0,
                  borderRadius: 25,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
                  child: Wrap(
                    //alignment: WrapAlignment.center,
                    children: const [
                      SizedBox(
                        width: 25,
                      ),
                      Text("End Party",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : GestureDetector(
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onTap: () {
                    _handleStepBack();
                  },
                ),
          actions: (sp.uid == fr.admin)
              ? [
                  IconButton(
                    onPressed: () {
                      nextScreen(context, const PartySettings());
                    },
                    icon: const Icon(
                      Icons.settings,
                    ),
                  )
                ]
              : [],
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
                  indicator: CircleTabIndicator(
                      color: Color.fromRGBO(30, 215, 96, 0.9), radius: 4),
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
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Color.fromARGB(158, 61, 219, 71),
                                  backgroundColor:
                                      Color.fromARGB(128, 52, 74, 61),
                                  strokeWidth: 10,
                                ));
                              }
                              //ci sono canzoni nella coda
                              if (snapshot.hasData && snapshot.data!.size > 0) {
                                // 'If there are songs in the Queue at the end of the Voting phase, Music will start'
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
    );
  }

  Future _addTrack() async {
    final fr = context.read<FirebaseRequests>();
    var db = FirebaseFirestore.instance.collection('parties').doc(fr.partyCode);
    String trackUri = '';
    bool done = false;
    await FirebaseFirestore.instance
        .collection('parties')
        .doc(fr.partyCode)
        .collection('queue')
        .orderBy('votes', descending: true)
        .get()
        .then((snapshot) async {
      if (snapshot.size > 0) {
        for (var el in snapshot.docs) {
          Track track = Track.getTrackFromFirestore(el);
          if (track.inQueue && !done) {
            trackUri = track.uri;
            db.update({
              "status": 'R',
              "songCurrentlyPlayed": track.uri,
            });
            db.collection('queue').doc(track.uri).update(
                {'inQueue': false, 'Streamings': FieldValue.increment(1)});
            db.collection('members').doc(track.admin).update({
              'points': FieldValue.increment(2),
            });

            for (var element in track.likes) {
              await db.collection('members').doc(element).update({
                'points': FieldValue.increment(1),
              });
            }

            done = true;
          }
        }

        if (!done) {
          Random random = Random();
          int randomNumber = random.nextInt(snapshot.size);
          var snapDoc = snapshot.docs[randomNumber];
          Track track = Track.getTrackFromFirestore(snapDoc);
          await db
              .collection('queue')
              .doc(track.uri)
              .update({'Streamings': FieldValue.increment(1)});
          await db.update({
            "status": 'R',
            "songCurrentlyPlayed": track.uri,
          });
          trackUri = track.uri;
          done = true;
        }
      } else {
        return;
      }
    });

    play(trackUri);
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
      if (value == true) {
        partyController.success();
        Future.delayed(const Duration(milliseconds: 1000));
        fr.setPartyEnded(fr.partyCode!).then((value) {
          if (sp.hasError == true) {
            showInSnackBar(context, sp.errorCode.toString(), Colors.red);
            partyController.reset();
            return;
          }
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
        color: const Color.fromARGB(255, 45, 44, 44),
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
            color: Colors.green,
            backgroundColor: Colors.grey[200],
            controller: timerController1,
            onTimerEnd: () {
              _setSelection();
              Future.delayed(const Duration(milliseconds: 1000));
              //_playNextTrack();
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

  Future<void> play(String uri) async {
    try {
      await SpotifySdk.play(spotifyUri: uri);
    } on PlatformException catch (e) {
      showInSnackBar(context, e.message!, Colors.red);
    } on MissingPluginException {
      showInSnackBar(context, 'not implemented', Colors.red);
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
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(30, 215, 96, 0.9),
                  ));
            }
            return Text("00:0${time.min}:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(30, 215, 96, 0.9),
                ));
          }

          if (time.min == null) {
            if (time.sec! / 10 < 1) {
              return Text("00:00:0${time.sec}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(30, 215, 96, 0.9),
                  ));
            }
            return Text("00:00:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(30, 215, 96, 0.9),
                ));
          }
          if (time.sec! / 10 < 1) {
            return Text("00:${time.min}:0${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(30, 215, 96, 0.9),
                ));
          }
          return Text("00:${time.min}:${time.sec}",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(30, 215, 96, 0.9),
              ));
        }
        if (time.hours! / 10 < 1) {
          if (time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("0${time.hours}:${time.min}:0${time.sec}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(30, 215, 96, 0.9),
                  ));
            }
            return Text("0${time.hours}:0${time.min}:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(30, 215, 96, 0.9),
                ));
          }
          return Text("0${time.hours}:${time.min}:${time.sec}",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(30, 215, 96, 0.9),
              ));
        }

        return Text("${time.hours}:${time.min}:${time.sec}",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(30, 215, 96, 0.9),
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
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    bool tmpStatus = !_votingStatus;

    DateTime _newNextVotingPhase = (_votingStatus)
        ? _nextVotingPhase.add(Duration(minutes: _interval))
        : _nextVotingPhase.add(Duration(minutes: _votingTime));

    await fr.changeStatus(tmpStatus, _newNextVotingPhase).then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), Colors.red);
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
