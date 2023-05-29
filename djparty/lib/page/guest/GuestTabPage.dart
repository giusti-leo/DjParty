import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:djparty/entities/Party.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/PartySettings.dart';
import 'package:djparty/page/QueueSearch.dart';
import 'package:djparty/page/RankingPage.dart';
import 'package:djparty/page/admin/AdminPlayer.dart';
import 'package:djparty/page/guest/GuestPlayer.dart';
import 'package:djparty/page/guest/GuestRanking.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
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

class GuestTabPage extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  const GuestTabPage({Key? key}) : super(key: key);

  @override
  _GuestTabPage createState() => _GuestTabPage();
}

class _GuestTabPage extends State<GuestTabPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  dynamic isPaused = true;
  bool error = false;
  bool voting = false;
  bool changed = false;
  bool countdown = false;
  bool visibility = false;

  bool tmpStatus = false;

  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController submitController =
      RoundedLoadingButtonController();

  double goingTimer = 0;
  double endingTimer = 0;

  int _currentTimer = 1;
  int _currentInterval = 1;

  final key = GlobalKey();
  File? file;

  int nextTrackIndex = 1;
  String nextTrackUri = "";
  bool ended = false;
  bool stopped = true;

  bool spotifyAlert = false;
  bool updateDone = true;

  int endCountdown = 10000;
  late TabController tabController;
  final RoundedLoadingButtonController exitController =
      RoundedLoadingButtonController();
  late LinearTimerController timerController1 = LinearTimerController(this);

  final TextEditingController controllerVotingTimer = TextEditingController();

  final TextEditingController controllerDistanceTimer = TextEditingController();

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
    sr.getAuthToken();
    sr.connectToSpotify();
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timerController1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    final fr = context.read<FirebaseRequests>();

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
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
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fr.partyName!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
          leading: Expanded(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () {
                _handleStepBack();
              },
            ),
          ),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 1,
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
              ],
              offset: const Offset(0, 100),
              color: Colors.white,
              elevation: 1,
            ),
          ],
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .collection('Party')
                    .doc('PartyStatus')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: mainGreen,
                      backgroundColor: backGround,
                      strokeWidth: 10,
                    ));
                  }

                  final partySnap = snapshot.data!.data();
                  PartyStatus partyStatus;
                  partyStatus = PartyStatus.getPartyFromFirestore(partySnap);

                  if (!partyStatus.isStarted!) {
                    return LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Column(children: [
                        Align(
                            alignment: Alignment.center,
                            child: TabBar(
                                controller: tabController,
                                isScrollable: true,
                                labelPadding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                indicator: CircleTabIndicator(
                                    color: mainGreen, radius: 4),
                                tabs: const [
                                  Tab(text: "Party"),
                                  Tab(text: "Player"),
                                  Tab(text: "Queue"),
                                ])),
                        SizedBox(
                          width: double.maxFinite,
                          height: constraints.maxHeight - 58,
                          child: TabBarView(
                            controller: tabController,
                            children: const [
                              GuestRankingNotStarted(),
                              GuestPlayerNotStarted(),
                              QueueSearch()
                            ],
                          ),
                        ),
                      ]);
                    });
                  } else if (partyStatus.isStarted! && !partyStatus.isEnded!) {
                    return LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Column(children: [
                        Align(
                          alignment: Alignment.center,
                          child: TabBar(
                              controller: tabController,
                              isScrollable: true,
                              labelPadding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                              indicator: CircleTabIndicator(
                                  color: mainGreen, radius: 4),
                              tabs: const [
                                Tab(text: "Party"),
                                Tab(text: "Player"),
                                Tab(text: "Queue"),
                              ]),
                        ),
                        SizedBox(
                            width: double.maxFinite,
                            height: constraints.maxHeight - 58,
                            child: TabBarView(
                              controller: tabController,
                              children: const [
                                GuestRankingStarted(),
                                GuestPlayerSongRunning(),
                                QueueSearch()
                              ],
                            )),
                      ]);
                    });
                  } else {
                    return LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Column(children: [
                        Align(
                          alignment: Alignment.center,
                          child: TabBar(
                              controller: tabController,
                              isScrollable: true,
                              labelPadding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                              indicator: CircleTabIndicator(
                                  color: mainGreen, radius: 4),
                              tabs: const [
                                Tab(text: "Party"),
                                Tab(text: "Player"),
                                Tab(text: "Queue"),
                              ]),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: constraints.maxHeight - 58,
                          child: TabBarView(
                            controller: tabController,
                            children: const [
                              GuestRankingEnded(),
                              GuestPlayerEnded(),
                              SongLists()
                            ],
                          ),
                        ),
                      ]);
                    });
                  }
                }),
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
                  }
                  final partySnap = snapshot.data!.data();
                  MusicStatus musicStatus;
                  musicStatus = MusicStatus.getPartyFromFirestore(partySnap);

                  return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('parties')
                          .doc(fr.partyCode)
                          .collection('Party')
                          .doc('PartyStatus')
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        final partySnap = snapshot.data!.data();
                        PartyStatus partyStatus =
                            PartyStatus.getPartyFromFirestore(partySnap);

                        if (!partyStatus.isBackgrounded!) {
                          if (musicStatus.pause == true &&
                              musicStatus.resume! == false) {
                            timerController1.stop();
                          } else if (musicStatus.pause == false &&
                              musicStatus.resume! == true) {
                            timerController1.start();
                          } else if (musicStatus.running == true &&
                              !musicStatus.selected! &&
                              !musicStatus.resume! &&
                              !musicStatus.pause!) {
                            Future.delayed(const Duration(milliseconds: 1000))
                                .then((value) =>
                                    timerController1.start(restart: true));
                          }
                        } else {
                          return Container();
                        }
                        return Container();
                      });
                }),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
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
        text: "Scan this Qr-Code to join my DjParty!" +
            " Or insert this code: $string",
      );

      Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      displayToastMessage(context, e.toString(), alertColor);
      return;
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final fr = context.read<FirebaseRequests>();

    return SizedBox(
        height: 70,
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('parties')
                        .doc(fr.partyCode)
                        .collection('Party')
                        .doc('MusicStatus')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      final partySnap = snapshot.data!.data();
                      MusicStatus musicStatus =
                          MusicStatus.getPartyFromFirestore(partySnap);

                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('parties')
                              .doc(fr.partyCode)
                              .collection('Party')
                              .doc('PartyStatus')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            final partySnap = snapshot.data!.data();
                            PartyStatus partyStatus =
                                PartyStatus.getPartyFromFirestore(partySnap);

                            if (partyStatus.isStarted! &&
                                !partyStatus.isEnded!) {
                              if (musicStatus.running!) {
                                return _linearTimerWidget(context);
                              } else if (!musicStatus.pause! &&
                                  musicStatus.resume!) {
                                timerController1.stop();
                                return Container();
                              } else if (musicStatus.pause! &&
                                  !musicStatus.resume!) {
                                timerController1.start();
                                return Container();
                              } else if (partyStatus.isBackgrounded!) {
                                timerController1.stop();
                              } else if (!partyStatus.isBackgrounded!) {
                                timerController1.start(restart: true);
                              }
                              return Container();
                            }
                            if (partyStatus.isEnded!) {
                              timerController1.reset();
                            }
                            return Container();
                          });
                    })),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('parties')
                      .doc(fr.partyCode)
                      .collection('Party')
                      .doc('PartyStatus')
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else {
                      final partySnap = snapshot.data!.data();
                      PartyStatus party;

                      party = PartyStatus.getPartyFromFirestore(partySnap);
                      String status = '';
                      if (party.isEnded!) {
                        status = 'ended';
                      } else {
                        status = 'not started';
                      }
                      if (!(party.isStarted! && !party.isEnded!)) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Party status : $status',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.circle_rounded,
                                  color: Colors.red,
                                )
                              ],
                            ),
                          ],
                        );
                      } else {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('parties')
                                .doc(fr.partyCode!)
                                .collection('Party')
                                .doc('Voting')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }

                              final partySnap = snapshot.data!.data();

                              VotingStatus votingStatus;

                              votingStatus =
                                  VotingStatus.getPartyFromFirestore(partySnap);

                              if (votingStatus.countdown == true) {
                                return SizedBox(
                                  height: 10,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                !votingStatus.voting!
                                                    ? "Next voting in : "
                                                    : "Voting ends in : ",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                )),
                                            _countdown(votingStatus, context),
                                          ])
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            });
                      }
                    }
                  }),
            ),
          ],
        ));
  }

  Widget _linearTimerWidget(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
        height: 30,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parties')
                .doc(fr.partyCode)
                .collection('Party')
                .doc('Song')
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final partySnap = snapshot.data!.data();
              Song song = Song.getPartyFromFirestore(partySnap);

              return Column(children: [
                SizedBox(
                  height: 3,
                  width: width * 0.8,
                  child: LinearTimer(
                    duration: Duration(milliseconds: song.duration),
                    color: mainGreen,
                    backgroundColor: Colors.grey[800],
                    controller: timerController1,
                    onTimerEnd: () {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          timerController1.reset();
                        }
                      });
                    },
                  ),
                ),
              ]);
            }));
  }

  Widget _countdown(VotingStatus votingStatus, BuildContext context) {
    return CountdownTimer(
      endTime: votingStatus.nextVotingPhase!.millisecondsSinceEpoch,
      widgetBuilder: (_, time) {
        if (time == null) {
          return const Text('');
        }
        if (time.hours == null) {
          if (time.min != null && time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("00:0${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }

          if (time.min == null) {
            if (time.sec! / 10 < 1) {
              return Text("00:00:0${time.sec}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:00:${time.sec}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          if (time.sec! / 10 < 1) {
            return Text("00:${time.min}:0${time.sec}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("00:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }
        if (time.hours! / 10 < 1) {
          if (time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("0${time.hours}:${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("0${time.hours}:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("0${time.hours}:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }

        return Text("${time.hours}:${time.min}:${time.sec}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: mainGreen,
            ));
      },
    );
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
