import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:djparty/entities/Party.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/PartySettings.dart';
import 'package:djparty/page/QueueSearch.dart';
import 'package:djparty/page/admin/AdminPlayer.dart';
import 'package:djparty/page/admin/AdminRanking.dart';
import 'package:djparty/services/Connectivity.dart';
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
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wakelock/wakelock.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AdminTabPage extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  User loggedUser;
  FirebaseFirestore db;
  String code;

  AdminTabPage(
      {super.key,
      required this.homeHeigth,
      required this.loggedUser,
      required this.code,
      required this.db});

  final double homeHeigth;

  @override
  _AdminTabPage createState() => _AdminTabPage();
}

class _AdminTabPage extends State<AdminTabPage>
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  File? file;

  int nextTrackIndex = 1;
  String nextTrackUri = "";
  bool ended = false;
  bool stopped = true;
  bool offline = false;

  bool spotifyAlert = false;
  bool updateDone = true;
  String partyTitle = "";

  int endCountdown = 10000;
  late TabController tabController;
  final RoundedLoadingButtonController exitController =
      RoundedLoadingButtonController();
  late LinearTimerController timerController1;

  final TextEditingController controllerVotingTimer = TextEditingController();

  final TextEditingController controllerDistanceTimer = TextEditingController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Party party = Party('code', 'name', 'admin');

  Future getData() async {
    final FirebaseRequests firebaseRequests = FirebaseRequests(db: widget.db);
    final sr = context.read<SpotifyRequests>();

    //getParty();

    sr.getUserId();
    sr.getAuthToken();
    sr.connectToSpotify();
    setParty();

    Wakelock.enable();
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
    WidgetsBinding.instance.addObserver(this);
    getData();
    timerController1 = LinearTimerController(this);

    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final FirebaseRequests firebaseRequests = FirebaseRequests(db: widget.db);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await firebaseRequests.setPartyEnded(firebaseRequests.partyCode!);
      }
    });

    timerController1.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isBackground = state == AppLifecycleState.paused;
    final isDetached = state == AppLifecycleState.detached;
    final isInactive = state == AppLifecycleState.inactive;
    final isResumed = state == AppLifecycleState.resumed;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final FirebaseRequests fr = FirebaseRequests(db: widget.db);

        if (isBackground || isDetached || isInactive) {
          pause();

          widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('MusicStatus')
              .get()
              .then((value) {
            MusicStatus musicStatus;
            musicStatus = MusicStatus.getPartyFromFirestore(value.data());
            if (musicStatus.running!) {
              fr.setBackgrounded(widget.code);
              timerController1.stop();
            }
          });
        }

        widget.db
            .collection('parties')
            .doc(widget.code)
            .collection('Party')
            .doc('PartyStatus')
            .get()
            .then((value) async {
          PartyStatus partyStatus =
              PartyStatus.getPartyFromFirestore(value.data());
          if (isResumed && partyStatus.isStarted! && !partyStatus.isEnded!) {
            await Future.delayed(const Duration(milliseconds: 1000))
                .then((value) async {
              fr.setSelection(widget.code);
              timerController1.reset();
            });
          }
        });
      }
    });
  }

  void showSettingAlert(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    fr.getPartyDataFromFirestore(widget.code);

    final width = MediaQuery.of(context).size.width;

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
              "Settings",
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: widget.homeHeigth * 0.6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: widget.homeHeigth * 0.05,
                    ),
                    const Center(
                      child: Text('Voting Timer',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: widget.homeHeigth * 0.02,
                    ),
                    TextField(
                      controller: controllerVotingTimer,
                      decoration: const InputDecoration(
                          labelText: "Select a Voting Timer"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    SizedBox(
                      height: widget.homeHeigth * 0.05,
                    ),
                    const Center(
                      child: Text('Interval between Votings',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: widget.homeHeigth * 0.02,
                    ),
                    TextField(
                      controller: controllerDistanceTimer,
                      decoration: const InputDecoration(
                          labelText: "Select an Interval Timer"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    SizedBox(
                      height: widget.homeHeigth * 0.05,
                    ),
                    RoundedLoadingButton(
                      onPressed: () {
                        _handleUpdate();
                        Navigator.of(context).pop();
                      },
                      controller: submitController,
                      successColor: mainGreen,
                      width: width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: mainGreen,
                      child: Wrap(
                        children: const [
                          Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                        ],
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

  Future _handleUpdate() async {
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    await ip.checkInternetConnection();

    _currentTimer = int.parse(controllerVotingTimer.text);
    _currentInterval = int.parse(controllerDistanceTimer.text);

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", alertColor);
      submitController.reset();
      return;
    }

    fr
        .updatePartySettings(widget.code, _currentTimer, _currentInterval)
        .then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
        submitController.reset();
        return;
      }
      fr.getPartyDataFromFirestore(widget.code).then((value) {
        if (fr.hasError) {
          showInSnackBar(context, fr.errorCode.toString(), alertColor);
          submitController.reset();
          return;
        }
        submitController.success();
      });
    });
  }

  Future<bool> _onWillPop() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    await widget.db
        .collection('parties')
        .doc(widget.code)
        .collection('Party')
        .doc('PartyStatus')
        .get()
        .then((value) {
      PartyStatus pStatus = PartyStatus.getPartyFromFirestore(value.data()!);
      if ((pStatus.isStarted! && !pStatus.isEnded!)) {
        return false;
      }
      return true;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    //setParty();

    return WillPopScope(
        onWillPop: _onWillPop,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(primary: mainGreen, secondary: backGround)),
          home: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: backGround,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: backGround,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    party.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              leading: Column(
                children: [
                  Expanded(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await widget.db
                            .collection('parties')
                            .doc(widget.code)
                            .collection('Party')
                            .doc('PartyStatus')
                            .get()
                            .then((value) {
                          PartyStatus pStatus =
                              PartyStatus.getPartyFromFirestore(value.data()!);
                          if (!(pStatus.isStarted! && !pStatus.isEnded!)) {
                            _handleStepBack();
                          } else {
                            displayToastMessage(
                                context,
                                'You have to stop the party, first!',
                                Colors.red);
                          }
                        });
                      },
                    ),
                  ),
                ],
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
                    PopupMenuItem(
                        value: 2,
                        // row with 2 children
                        child: TextButton(
                          onPressed: () async {
                            await widget.db
                                .collection('parties')
                                .doc(widget.code)
                                .collection('Party')
                                .doc('PartyStatus')
                                .get()
                                .then((value) {
                              PartyStatus pStatus =
                                  PartyStatus.getPartyFromFirestore(
                                      value.data()!);
                              if (!(pStatus.isStarted! && !pStatus.isEnded!)) {
                                nextScreen(
                                    context,
                                    PartySettings(
                                      loggedUser: widget.loggedUser,
                                      code: widget.code,
                                      db: widget.db,
                                    ));
                              } else {
                                showSettingAlert(context);
                              }
                            });
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
                  ],
                  offset: const Offset(0, 100),
                  color: Colors.white,
                  elevation: 1,
                ),
              ],
            ),
            body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 600) {
                return SizedBox(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.78,
                        child: StreamBuilder(
                            stream: widget.db
                                .collection('parties')
                                .doc(widget.code)
                                .collection('Party')
                                .doc('PartyStatus')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
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
                              partyStatus =
                                  PartyStatus.getPartyFromFirestore(partySnap);

                              if (!partyStatus.isStarted!) {
                                return Column(children: [
                                  TabBar(
                                      controller: tabController,
                                      isScrollable: true,
                                      labelPadding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.grey,
                                      indicator: CircleTabIndicator(
                                          color: mainGreen, radius: 4),
                                      tabs: const [
                                        Tab(text: "Party"),
                                        Tab(text: "Player"),
                                        Tab(text: "Queue"),
                                      ]),
                                  SizedBox(
                                    width: double.maxFinite,
                                    height: constraints.maxHeight - 58,
                                    child: TabBarView(
                                      controller: tabController,
                                      children: [
                                        AdminRankingNotStarted(
                                          db: widget.db,
                                          code: widget.code,
                                        ),
                                        const AdminPlayerNotStarted(),
                                        QueueSearch(
                                          loggedUser: widget.loggedUser,
                                          db: widget.db,
                                          code: widget.code,
                                        )
                                      ],
                                    ),
                                  ),
                                ]);
                              } else if (partyStatus.isStarted! &&
                                  !partyStatus.isEnded!) {
                                return Column(children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: TabBar(
                                        controller: tabController,
                                        isScrollable: true,
                                        labelPadding: const EdgeInsets.only(
                                            left: 20, right: 20),
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
                                        children: [
                                          AdminRankingStarted(
                                            db: widget.db,
                                            code: widget.code,
                                          ),
                                          AdminPlayerSongRunning(
                                            tabController: tabController,
                                            db: widget.db,
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
                              } else {
                                timerController1.reset();
                                return Column(children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: TabBar(
                                        controller: tabController,
                                        isScrollable: false,
                                        labelPadding: const EdgeInsets.only(
                                            left: 20, right: 20),
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
                                      children: [
                                        AdminRankingEnded(
                                          db: widget.db,
                                          code: widget.code,
                                        ),
                                        AdminPlayerEnded(
                                          loggedUser: widget.loggedUser,
                                          db: widget.db,
                                          code: widget.code,
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
                              }
                            }),
                      ),
                      // Handle disconnection to Spotify
                      StreamBuilder(
                          stream: SpotifySdk.subscribeConnectionStatus(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            if (snapshot.data!.connected == true) {
                              return Container();
                            } else {
                              final sr = context.read<SpotifyRequests>();

                              sr.getUserId();
                              sr.getAuthToken();
                              sr.connectToSpotify();
                              return Container();
                            }
                          }),
                      // ROUTINE TO UPDATE SONG WHEN SONG ENDS
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
                            final partySnap = snapshot.data!.data();
                            MusicStatus musicStatus;
                            musicStatus =
                                MusicStatus.getPartyFromFirestore(partySnap);

                            return FutureBuilder(
                                future: widget.db
                                    .collection('parties')
                                    .doc(widget.code)
                                    .collection('Party')
                                    .doc('PartyStatus')
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  final partySnap = snapshot.data!.data();
                                  PartyStatus partyStatus =
                                      PartyStatus.getPartyFromFirestore(
                                          partySnap);

                                  if (!partyStatus.isBackgrounded!) {
                                    if (musicStatus.firstVoting! == true &&
                                        musicStatus.songs! == true &&
                                        musicStatus.selected! == false &&
                                        musicStatus.running! == false &&
                                        musicStatus.backSkip! == false) {
                                      _addTrack();
                                      return Container();
                                    } else if (musicStatus.backSkip! == true) {
                                      _addPreviousTrack();
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                  return Container();
                                });
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

                            votingStatus =
                                VotingStatus.getPartyFromFirestore(partySnap);
                            if (votingStatus.countdown == false) {
                              int t = 0;
                              if (votingStatus.voting!) {
                                t = votingStatus.votingTime!;
                              } else {
                                t = votingStatus.timer!;
                              }
                              fr.setCountdown(t, widget.code);
                            }
                            return Container();
                          }),
                      StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 25)),
                          builder: (context, snapshot) {
                            fr.setPing(widget.code);
                            return Container();
                          }),
                      StreamBuilder(
                          stream: widget.db
                              .collection('parties')
                              .doc(widget.code)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            if (snapshot.data!.get('offline') != null) {
                              if (snapshot.data!.get('offline')) {
                                widget.db
                                    .collection('parties')
                                    .doc(widget.code)
                                    .collection('Party')
                                    .doc('Voting')
                                    .get()
                                    .then((value) {
                                  VotingStatus votingStatus =
                                      VotingStatus.getPartyFromFirestore(
                                          value.data());

                                  if (votingStatus.nextVotingPhase!
                                          .millisecondsSinceEpoch <
                                      Timestamp.now().millisecondsSinceEpoch) {
                                    int t = votingStatus.votingTime!;
                                    fr.setCountdown(t, widget.code);
                                  }
                                });

                                widget.db
                                    .collection('parties')
                                    .doc(widget.code)
                                    .collection('Party')
                                    .doc('Song')
                                    .get()
                                    .then((value) {
                                  MusicStatus song =
                                      MusicStatus.getPartyFromFirestore(
                                          value.data());

                                  if (song.running == true &&
                                      timerController1.value == 0) {
                                    fr.setSelection(widget.code);
                                  }
                                });

                                fr.setPartyOnline(widget.code);
                              }
                            }
                            return Container();
                          }),
                      StreamProvider<ConnectivityStatus>(
                        create: (context) =>
                            ConnectivityService().connectionController.stream,
                        initialData: ConnectivityStatus.Online,
                        builder: (context, child) {
                          var connectionStatus =
                              Provider.of<ConnectivityStatus>(context);
                          if (connectionStatus == ConnectivityStatus.Online) {
                            /// Online logic
                            if (offline) {
                              fr.setPartyOffline;
                              offline = false;
                            }
                          } else {
                            /// Offline logic
                            offline = true;
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.78,
                          child: StreamBuilder(
                              stream: widget.db
                                  .collection('parties')
                                  .doc(widget.code)
                                  .collection('Party')
                                  .doc('PartyStatus')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
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
                                partyStatus = PartyStatus.getPartyFromFirestore(
                                    partySnap);

                                if (!partyStatus.isStarted!) {
                                  return Column(children: [
                                    Row(
                                      children: [
                                        Align(
                                            alignment: Alignment.center,
                                            child: RotatedBox(
                                              quarterTurns: 1,
                                              child: TabBar(
                                                  controller: tabController,
                                                  isScrollable: true,
                                                  labelPadding:
                                                      const EdgeInsets.only(
                                                          left: 20, right: 20),
                                                  labelColor: Colors.white,
                                                  unselectedLabelColor:
                                                      Colors.grey,
                                                  indicator: CircleTabIndicator(
                                                      color: mainGreen,
                                                      radius: 4),
                                                  tabs: const [
                                                    Tab(text: "Party"),
                                                    Tab(text: "Player"),
                                                    Tab(text: "Queue"),
                                                  ]),
                                            )),
                                        Flexible(
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            height: constraints.maxHeight - 58,
                                            child: TabBarView(
                                              controller: tabController,
                                              children: [
                                                AdminRankingNotStarted(
                                                  db: widget.db,
                                                  code: widget.code,
                                                ),
                                                const AdminPlayerNotStarted(),
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
                                } else if (partyStatus.isStarted! &&
                                    !partyStatus.isEnded!) {
                                  return Column(children: [
                                    Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: TabBar(
                                                controller: tabController,
                                                isScrollable: true,
                                                labelPadding:
                                                    const EdgeInsets.only(
                                                        left: 20, right: 20),
                                                labelColor: Colors.white,
                                                unselectedLabelColor:
                                                    Colors.grey,
                                                indicator: CircleTabIndicator(
                                                    color: mainGreen,
                                                    radius: 4),
                                                tabs: const [
                                                  Tab(text: "Party"),
                                                  Tab(text: "Player"),
                                                  Tab(text: "Queue"),
                                                ]),
                                          ),
                                        ),
                                        Flexible(
                                          child: SizedBox(
                                              width: double.maxFinite,
                                              height:
                                                  constraints.maxHeight - 58,
                                              child: TabBarView(
                                                controller: tabController,
                                                children: [
                                                  AdminRankingStarted(
                                                    db: widget.db,
                                                    code: widget.code,
                                                  ),
                                                  AdminPlayerSongRunning(
                                                    tabController:
                                                        tabController,
                                                    db: widget.db,
                                                    code: widget.code,
                                                  ),
                                                  QueueSearch(
                                                    loggedUser:
                                                        widget.loggedUser,
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
                                        Align(
                                          alignment: Alignment.center,
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: TabBar(
                                                controller: tabController,
                                                isScrollable: false,
                                                labelPadding:
                                                    const EdgeInsets.only(
                                                        left: 20, right: 20),
                                                labelColor: Colors.white,
                                                unselectedLabelColor:
                                                    Colors.grey,
                                                indicator: CircleTabIndicator(
                                                    color: mainGreen,
                                                    radius: 4),
                                                tabs: const [
                                                  Tab(text: "Party"),
                                                  Tab(text: "Player"),
                                                  Tab(text: "Queue"),
                                                ]),
                                          ),
                                        ),
                                        Flexible(
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            height: constraints.maxHeight - 58,
                                            child: TabBarView(
                                              controller: tabController,
                                              children: [
                                                AdminRankingEnded(
                                                  db: widget.db,
                                                  code: widget.code,
                                                ),
                                                AdminPlayerEnded(
                                                  loggedUser: widget.loggedUser,
                                                  db: widget.db,
                                                  code: widget.code,
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
                              }),
                        ),
                        // Handle disconnection to Spotify
                        StreamBuilder(
                            stream: SpotifySdk.subscribeConnectionStatus(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              if (snapshot.data!.connected == true) {
                                return Container();
                              } else {
                                final sr = context.read<SpotifyRequests>();

                                sr.getUserId();
                                sr.getAuthToken();
                                sr.connectToSpotify();
                                return Container();
                              }
                            }),
                        // ROUTINE TO UPDATE SONG WHEN SONG ENDS
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
                              final partySnap = snapshot.data!.data();
                              MusicStatus musicStatus;
                              musicStatus =
                                  MusicStatus.getPartyFromFirestore(partySnap);

                              return FutureBuilder(
                                  future: widget.db
                                      .collection('parties')
                                      .doc(widget.code)
                                      .collection('Party')
                                      .doc('PartyStatus')
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    final partySnap = snapshot.data!.data();
                                    PartyStatus partyStatus =
                                        PartyStatus.getPartyFromFirestore(
                                            partySnap);

                                    if (!partyStatus.isBackgrounded!) {
                                      if (musicStatus.firstVoting! == true &&
                                          musicStatus.songs! == true &&
                                          musicStatus.selected! == false &&
                                          musicStatus.running! == false &&
                                          musicStatus.backSkip! == false) {
                                        _addTrack();
                                        return Container();
                                      } else if (musicStatus.backSkip! ==
                                          true) {
                                        _addPreviousTrack();
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                    return Container();
                                  });
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

                              votingStatus =
                                  VotingStatus.getPartyFromFirestore(partySnap);
                              if (votingStatus.countdown == false) {
                                int t = 0;
                                if (votingStatus.voting!) {
                                  t = votingStatus.votingTime!;
                                } else {
                                  t = votingStatus.timer!;
                                }
                                fr.setCountdown(t, widget.code);
                              }
                              return Container();
                            }),
                        StreamBuilder(
                            stream:
                                Stream.periodic(const Duration(seconds: 25)),
                            builder: (context, snapshot) {
                              fr.setPing(widget.code);
                              return Container();
                            }),
                        StreamBuilder(
                            stream: widget.db
                                .collection('parties')
                                .doc(widget.code)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              if (snapshot.data!.get('offline') != null) {
                                if (snapshot.data!.get('offline')) {
                                  widget.db
                                      .collection('parties')
                                      .doc(widget.code)
                                      .collection('Party')
                                      .doc('Voting')
                                      .get()
                                      .then((value) {
                                    VotingStatus votingStatus =
                                        VotingStatus.getPartyFromFirestore(
                                            value.data());

                                    if (votingStatus.nextVotingPhase!
                                            .millisecondsSinceEpoch <
                                        Timestamp.now()
                                            .millisecondsSinceEpoch) {
                                      int t = votingStatus.votingTime!;
                                      fr.setCountdown(t, widget.code);
                                    }
                                  });

                                  widget.db
                                      .collection('parties')
                                      .doc(widget.code)
                                      .collection('Party')
                                      .doc('Song')
                                      .get()
                                      .then((value) {
                                    MusicStatus song =
                                        MusicStatus.getPartyFromFirestore(
                                            value.data());

                                    if (song.running == true &&
                                        timerController1.value == 0) {
                                      fr.setSelection(widget.code);
                                    }
                                  });

                                  fr.setPartyOnline(widget.code);
                                }
                              }
                              return Container();
                            }),
                        StreamProvider<ConnectivityStatus>(
                          create: (context) =>
                              ConnectivityService().connectionController.stream,
                          initialData: ConnectivityStatus.Online,
                          builder: (context, child) {
                            var connectionStatus =
                                Provider.of<ConnectivityStatus>(context);
                            if (connectionStatus == ConnectivityStatus.Online) {
                              /// Online logic
                              if (offline) {
                                fr.setPartyOffline;
                                offline = false;
                              }
                            } else {
                              /// Offline logic
                              offline = true;
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
            bottomNavigationBar: _buildBottomBar(context),
          ),
        ));
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
        text:
            "Scan this Qr-Code to join my DjParty! Or insert this code: $string",
      );

      Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      displayToastMessage(context, e.toString(), alertColor);
      return;
    }
  }

  Future _addTrack() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    var db = FirebaseFirestore.instance.collection('parties').doc(widget.code);
    String trackUri = '';

    Song previousSong = Song(
        [], '', '', '', 0, Timestamp.now(), [], '', '', '', 0, Timestamp.now());

    widget.db
        .collection('parties')
        .doc(widget.code)
        .collection('Party')
        .doc('Song')
        .get()
        .then((value) {
      previousSong = Song.getPartyFromFirestore(value);
    });

    widget.db
        .collection('parties')
        .doc(widget.code)
        .collection('queue')
        .where('inQueue', isEqualTo: true)
        .orderBy('likes', descending: true)
        .limit(1)
        .get()
        .then((value) {
      if (value.size > 0) {
        var el = value.docs[0];
        Track track = Track.getTrackFromFirestore(el);
        trackUri = track.uri;
        final batch = FirebaseFirestore.instance.batch();

        if (previousSong.previousUri == '') {
          var pathSong = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('Song');
          batch.set(pathSong, {
            "songCurrentlyPlayed": track.uri,
            "image": track.images,
            "name": track.name,
            "trackDuration": track.duration,
            "artist": track.artists,
            "recs": FieldValue.serverTimestamp(),
            "previousSong": track.uri,
            "previousImage": track.images,
            "previousName": track.name,
            "previousTrackDuration": track.duration,
            "previousArtist": track.artists,
            "previousRecs": FieldValue.serverTimestamp(),
          });
        } else {
          var pathSong = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('Song');
          batch.update(pathSong, {
            "songCurrentlyPlayed": track.uri,
            "image": track.images,
            "name": track.name,
            "trackDuration": track.duration,
            "artist": track.artists,
            "recs": FieldValue.serverTimestamp(),
            "previousSong": previousSong.uri,
            "previousImage": previousSong.images,
            "previousName": previousSong.name,
            "previousTrackDuration": previousSong.duration,
            "previousArtist": previousSong.artists,
            "previousRecs": FieldValue.serverTimestamp(),
          });
        }

        var pathMusicStatus = widget.db
            .collection('parties')
            .doc(widget.code)
            .collection('Party')
            .doc('MusicStatus');
        batch.update(pathMusicStatus, {
          'selected': true,
          "songsReproduced": FieldValue.increment(1),
          'running': false,
          'pause': false,
          'resume': false
        });

        var pathParty = widget.db
            .collection('parties')
            .doc(widget.code)
            .collection('queue')
            .doc(track.uri);
        batch.update(pathParty, {
          'inQueue': false,
          'lastStreaming': Timestamp.now(),
          'Streamings': FieldValue.increment(1)
        });

        for (var element in track.likes) {
          var pathUserPoint = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('members')
              .doc(element);
          batch.update(pathUserPoint, {
            'points': FieldValue.increment(1),
          });
        }

        batch.commit();
      } else {
        widget.db
            .collection('parties')
            .doc(widget.code)
            .collection('queue')
            .get()
            .then((snapshot) {
          Random random = Random();
          int randomNumber = random.nextInt(snapshot.size);
          var snapDoc = snapshot.docs[randomNumber];
          Track track = Track.getTrackFromFirestore(snapDoc);
          trackUri = track.uri;
          final batch = FirebaseFirestore.instance.batch();

          var pathSong = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('Song');
          batch.update(pathSong, {
            "songCurrentlyPlayed": track.uri,
            "image": track.images,
            "name": track.name,
            "trackDuration": track.duration,
            "artist": track.artists,
            "recs": FieldValue.serverTimestamp(),
            "previousSong": previousSong.uri,
            "previousImage": previousSong.images,
            "previousName": previousSong.name,
            "previousTrackDuration": previousSong.duration,
            "previousArtist": previousSong.artists,
            "previousRecs": FieldValue.serverTimestamp(),
          });

          var pathMusicStatus = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('Party')
              .doc('MusicStatus');
          batch.update(pathMusicStatus, {
            'selected': true,
            'songsReproduced': FieldValue.increment(1),
            'running': false,
            'pause': false,
            'resume': false
          });

          var pathParty = widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('queue')
              .doc(track.uri);
          batch.update(pathParty, {
            'inQueue': false,
            'lastStreaming': Timestamp.now(),
            'Streamings': FieldValue.increment(1)
          });

          batch.commit();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => play(trackUri));
  }

  Future _addPreviousTrack() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    var db = FirebaseFirestore.instance.collection('parties').doc(widget.code);
    String trackUri = '';

    Song previousSong = Song(
        [], '', '', '', 0, Timestamp.now(), [], '', '', '', 0, Timestamp.now());
    final batch = FirebaseFirestore.instance.batch();

    widget.db
        .collection('parties')
        .doc(widget.code)
        .collection('Party')
        .doc('Song')
        .get()
        .then((value) async {
      previousSong = Song.getPartyFromFirestore(value);

      var pathSong = widget.db
          .collection('parties')
          .doc(widget.code)
          .collection('Party')
          .doc('Song');

      batch.update(pathSong, {
        "songCurrentlyPlayed": previousSong.previousUri,
        "image": previousSong.previousImages,
        "name": previousSong.previousName,
        "trackDuration": previousSong.previousDuration,
        "artist": previousSong.previousArtists,
        "recs": FieldValue.serverTimestamp(),
        "previousSong": previousSong.uri,
        "previousImage": previousSong.images,
        "previousName": previousSong.name,
        "previousTrackDuration": previousSong.duration,
        "previousArtist": previousSong.artists,
        "previousRecs": FieldValue.serverTimestamp(),
      });

      var pathMusicStatus = widget.db
          .collection('parties')
          .doc(widget.code)
          .collection('Party')
          .doc('MusicStatus');
      batch.update(pathMusicStatus, {
        'selected': true,
        "songsReproduced": FieldValue.increment(1),
        'running': false,
        'backSkip': false,
        'pause': false,
        'resume': false
      });

      var pathParty = widget.db
          .collection('parties')
          .doc(widget.code)
          .collection('queue')
          .doc(previousSong.previousUri);
      batch.update(pathParty, {
        'inQueue': false,
        'lastStreaming': Timestamp.now(),
        'Streamings': FieldValue.increment(1)
      });

      await batch.commit();
    });

    Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => play(previousSong.previousUri));
  }

  Widget _buildBottomBar(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return SizedBox(
      height: 70,
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
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
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
                return Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
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
      Expanded(
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
              if (snapshot.data == null) {
                return Container();
              }

              Song song = Song.getPartyFromFirestore(snapshot.data);

              if (song.tmp != null) {
                if ((Timestamp.now().millisecondsSinceEpoch -
                            song.tmp!.millisecondsSinceEpoch) <
                        3000 &&
                    song.name != '') {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      fr.setRunning(widget.code);
                      timerController1.reset();

                      timerController1.start();
                    }
                  });
                }
              }
              return Container();
            }),
      ),
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
                            // only if admin
                            fr.setSelection(widget.code);
                            pause();
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
      print(e.message!);
      if (e.message == '') {
        sr.getUserId();
        sr.getAuthToken();
        sr.connectToSpotify();
      }
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }

  Future<void> play(String uri) async {
    final sr = context.read<SpotifyRequests>();
    try {
      await SpotifySdk.play(spotifyUri: uri);
    } on PlatformException catch (e) {
      displayToastMessage(context, e.message!, alertColor);
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }

  Future<void> restart() async {
    final sr = context.read<SpotifyRequests>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    String uri = '';

    try {
      await widget.db
          .collection('parties')
          .doc(widget.code)
          .collection('Party')
          .doc('Song')
          .get()
          .then((value) {
        var partySnap = value.data();
        Song song = Song.getPartyFromFirestore(partySnap);
        uri = song.uri;
      });
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
      print(e.message!);
      if (e.message != '') {
        sr.getUserId();
        sr.getAuthToken();
        sr.connectToSpotify();
        restart();
      }
    } on MissingPluginException {
      displayToastMessage(context, 'not implemented', alertColor);
    }
  }

  Widget _countdown(VotingStatus votingStatus, BuildContext context) {
    return CountdownTimer(
      endTime: votingStatus.nextVotingPhase!.millisecondsSinceEpoch - 1000,
      widgetBuilder: (_, time) {
        if (time == null) {
          return const Text('');
        }
        if (time.hours == null) {
          if (time.min != null && time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("00:0${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }

          if (time.min == null) {
            if (time.sec! / 10 < 1) {
              return Text("00:00:0${time.sec}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("00:00:${time.sec}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          if (time.sec! / 10 < 1) {
            return Text("00:${time.min}:0${time.sec}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("00:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }
        if (time.hours! / 10 < 1) {
          if (time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("0${time.hours}:${time.min}:0${time.sec}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: mainGreen,
                  ));
            }
            return Text("0${time.hours}:0${time.min}:${time.sec}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: mainGreen,
                ));
          }
          return Text("0${time.hours}:${time.min}:${time.sec}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ));
        }

        return Text("${time.hours}:${time.min}:${time.sec}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: mainGreen,
            ));
      },
      onEnd: () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleEndCountdown(votingStatus.voting!);
          }
        });
      },
    );
  }

  Future _handleEndCountdown(bool tmpStatus) async {
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      return;
    }

    await fr.changeVoting(widget.code, !tmpStatus).then((value) async {
      if (fr.hasError) {
        displayToastMessage(context, fr.errorCode.toString(), alertColor);
        return;
      }
    });
  }

  _handleStepBack() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(
          context, HomePage(loggedUser: widget.loggedUser, db: widget.db));
    });
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
