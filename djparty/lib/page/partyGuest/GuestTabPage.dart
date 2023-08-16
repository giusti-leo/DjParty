import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:djparty/entities/Party.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/page/lobby/HomePage.dart';
import 'package:djparty/page/party/QueueSearch.dart';
import 'package:djparty/page/partyGuest/GuestPlayer.dart';
import 'package:djparty/page/partyGuest/GuestRanking.dart';
import 'package:djparty/utils/Spotify.dart';
import 'package:djparty/utils/TabPageWidgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GuestTabPage extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  User loggedUser;
  FirebaseFirestore db;
  String code;

  GuestTabPage(
      {super.key,
      required this.homeHeigth,
      required this.loggedUser,
      required this.code,
      required this.db});

  final double homeHeigth;

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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  String partyTitle = 'title';

  Party party = Party('code', 'name', 'admin', 'reason');
  Future getData() async {
    final FirebaseRequests firebaseRequests = FirebaseRequests(db: widget.db);
    final sr = context.read<SpotifyRequests>();

    firebaseRequests.getPartyDataFromFirestore(widget.code);

    sr.getUserId();
    sr.getAuthToken();
    sr.connectToSpotify();
    setParty();
  }

  void setParty() async {
    var collection = widget.db.collection('parties');
    // userUid is the current authenticated user
    var docSnapshot = await collection.doc(widget.code).get();

    Map<String, dynamic> data = docSnapshot.data()!;

    party.code.replaceAll('code', data['code']);
    party.name = data['partyName'];
    party.admin = data['admin'];
    setState(() {
      partyTitle = data['partyName'];
    });
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
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: mainGreen, secondary: backGround)),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: backGround,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backGround,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                partyTitle,
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
                        handleShare(widget.code);
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        children: [
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
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: [
              (isMobile)
                  ? mobileLayoutBuilder(context, constraints)
                  : tabletLayoutBuilder(context, constraints),
              // Handle disconnection to Spotify
              getConnection(),
              checkPing()
            ],
          );
        }),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget tabletLayoutBuilder(BuildContext context, BoxConstraints constraints) {
    return StreamBuilder(
        stream: widget.db
            .collection('parties')
            .doc(widget.code)
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
            return Column(children: [
              Row(
                children: [
                  tabletStructTabs(tabController),
                  Flexible(
                    child: SizedBox(
                      width: double.maxFinite,
                      height: constraints.maxHeight - 58,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          GuestRankingNotStarted(
                            db: widget.db,
                            code: widget.code,
                          ),
                          const GuestPlayerNotStarted(),
                          QueueSearch(
                            loggedUser: widget.loggedUser,
                            db: widget.db,
                            code: widget.code,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ]);
          } else if (partyStatus.isStarted! && !partyStatus.isEnded!) {
            return Column(children: [
              Row(
                children: [
                  tabletStructTabs(tabController),
                  Flexible(
                    child: SizedBox(
                        width: double.maxFinite,
                        height: constraints.maxHeight - 58,
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            GuestRankingStarted(
                              db: widget.db,
                              code: widget.code,
                            ),
                            GuestPlayerSongRunning(
                              code: widget.code,
                            ),
                            QueueSearch(
                              loggedUser: widget.loggedUser,
                              db: widget.db,
                              code: widget.code,
                            )
                          ],
                        )),
                  ),
                ],
              )
            ]);
          } else {
            timerController1.reset();
            return Column(children: [
              Row(
                children: [
                  tabletStructTabs(tabController),
                  Flexible(
                    child: SizedBox(
                      width: double.maxFinite,
                      height: constraints.maxHeight - 58,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          GuestRankingEnded(
                            db: widget.db,
                            code: widget.code,
                          ),
                          GuestPlayerEnded(
                            code: widget.code,
                            db: widget.db,
                          ),
                          SongLists(
                            loggedUser: widget.loggedUser,
                            db: widget.db,
                            code: widget.code,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ]);
          }
        });
  }

  Widget mobileLayoutBuilder(BuildContext context, BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight - 58,
      child: StreamBuilder(
          stream: widget.db
              .collection('parties')
              .doc(widget.code)
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
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(children: [
                  mobileStructTabs(tabController),
                  SizedBox(
                    height: constraints.maxHeight - 58,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        GuestRankingNotStarted(
                          db: widget.db,
                          code: widget.code,
                        ),
                        const GuestPlayerNotStarted(),
                        QueueSearch(
                          loggedUser: widget.loggedUser,
                          db: widget.db,
                          code: widget.code,
                        )
                      ],
                    ),
                  ),
                ]);
              });
            } else if (partyStatus.isStarted! && !partyStatus.isEnded!) {
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(children: [
                  mobileStructTabs(tabController),
                  SizedBox(
                      width: double.maxFinite,
                      height: constraints.maxHeight - 58,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          GuestRankingStarted(
                            db: widget.db,
                            code: widget.code,
                          ),
                          GuestPlayerSongRunning(
                            code: widget.code,
                          ),
                          QueueSearch(
                            loggedUser: widget.loggedUser,
                            db: widget.db,
                            code: widget.code,
                          )
                        ],
                      )),
                ]);
              });
            } else {
              timerController1.reset();

              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(children: [
                  mobileStructTabs(tabController),
                  SizedBox(
                    width: double.maxFinite,
                    height: constraints.maxHeight - 58,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        GuestRankingEnded(
                          db: widget.db,
                          code: widget.code,
                        ),
                        GuestPlayerEnded(
                          code: widget.code,
                          db: widget.db,
                        ),
                        SongLists(
                          loggedUser: widget.loggedUser,
                          db: widget.db,
                          code: widget.code,
                        )
                      ],
                    ),
                  ),
                ]);
              });
            }
          }),
    );
  }

  Widget checkPing() {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 70)),
        builder: (context, snapshot) {
          widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('PartyStatus')
              .get()
              .then((value) async {
            if (value.data()!['isStarted'] && !value.data()!['isEnded']) {
              await widget.db
                  .collection('parties')
                  .doc(widget.code)
                  .get()
                  .then((value) {
                Timestamp tmp = value.data()!['ping'];

                print('Ping:' + tmp.toDate().toString());

                print('Now:' + Timestamp.now().toDate().toString());

                if (Timestamp.now().millisecondsSinceEpoch -
                        tmp.millisecondsSinceEpoch >
                    120000) {
                  print('Stop');
                  fr.setPartyEnded(widget.code);
                }
              });
            }
          });

          return Container();
        });
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
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return SizedBox(
      height: 50,
      child: StreamBuilder(
          stream: widget.db
              .collection('parties')
              .doc(widget.code)
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

              if (party.isEnded!) {
                return const Column(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Party status : ended',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.circle_rounded,
                          color: Colors.red,
                        )
                      ],
                    ),
                  ],
                );
              } else if (!party.isStarted!) {
                return const Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      Text('Party status : not started',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.circle_rounded,
                        color: Colors.red,
                      )
                    ],
                  )
                ]);
              } else {
                return _buildActiveBottomBar(context);
              }
            }
          }),
    );
  }

  Widget _buildActiveBottomBar(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return Column(children: [
      Expanded(child: _linearTimerWidget(context)),
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
            }

            MusicStatus musicStatus =
                MusicStatus.getPartyFromFirestore(snapshot.data!.data());

            //for all users -->
            if (musicStatus.backSkip! == true) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  timerController1.stop();
                  timerController1.reset();
                }
              });
            } else if (musicStatus.pause! == true) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  timerController1.stop();
                }
              });
            } else if (musicStatus.resume! == true) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  timerController1.start();
                }
              });
            } else if (musicStatus.running! == true) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  timerController1.reset();
                  timerController1.start();
                }
              });
            }
            return Container();
          }),
      StreamBuilder(
          stream: widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('Voting')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final partySnap = snapshot.data!.data();

            VotingStatus votingStatus;

            votingStatus = VotingStatus.getPartyFromFirestore(partySnap);
            if (votingStatus.timer != null) {
              if (votingStatus.countdown == true) {
                return SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 30,
                            ),
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
              }
              return Container();
            } else {
              return Container();
            }
          }),
    ]);
  }

  Widget _linearTimerWidget(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    final width = MediaQuery.of(context).size.width;

    int timer = 100000;

    return SizedBox(
        child: StreamBuilder(
            stream: widget.db
                .collection('parties')
                .doc(widget.code)
                .collection('Party')
                .doc('Song')
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final partySnap = snapshot.data;
              Song song = Song.getPartyFromFirestore(partySnap);
              if (song.tmp != null) {
                if (song.duration! > 5000) {
                  timer = song.duration!;
                }

                return Column(children: [
                  SizedBox(
                    height: 3,
                    width: width * 0.8,
                    child: LinearTimer(
                      duration: Duration(milliseconds: timer),
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
              }
              return Container();
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
      nextScreenReplace(
          context, HomePage(loggedUser: widget.loggedUser, db: widget.db));
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
