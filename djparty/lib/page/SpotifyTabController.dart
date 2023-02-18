import 'dart:async';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/spotifyPlayer.dart';
import 'package:djparty/page/Queue.dart';
import 'package:djparty/page/VotingPage.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/Icons/c_d_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpotifyTabController extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  final String code;
  const SpotifyTabController({Key? key, required this.code}) : super(key: key);

  @override
  _SpotifyTabController createState() => _SpotifyTabController();
}

class _SpotifyTabController extends State<SpotifyTabController>
    with TickerProviderStateMixin {
  bool error = false;
  bool voting = false;
  bool changed = false;
  bool countdown = false;

  int _startParty = 0;
  int _timer = 0;
  int _firstResearch = 0;
  int _votingTime = 0;
  int endCountdown = 100000;

  int _computeCountdown(
      int startParty, int timer, int firstResearch, int votingTime) {
    int tmp = Timestamp.now().seconds;
    int endFirstBlock = (startParty + firstResearch);
    int endVoting;
    int endTimer;
    bool inside = false;

    if (tmp <= endFirstBlock) {
      voting = false;
      endCountdown = endFirstBlock;
      inside = true;
    }
    while (!inside) {
      endVoting = endFirstBlock + votingTime;
      endTimer = endVoting + timer;

      if (tmp > endFirstBlock && tmp <= endVoting) {
        inside = true;
        endCountdown = endVoting;
        voting = true;
      }
      if (tmp > endVoting && tmp <= endTimer) {
        endCountdown = endTimer;
        voting = false;

        inside = true;
      }
    }
    return endCountdown;
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
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
    TabController tabController = TabController(length: 3, vsync: this);
    final fr = context.read<FirebaseRequests>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(228, 53, 191, 101),
              secondary: const Color.fromARGB(228, 53, 191, 101))),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 35, 34, 34),
          title: Text(
            fr.partyName!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: const [
            Icon(
              CD.cd,
              color: Color.fromARGB(228, 53, 191, 101),
            ),
            SizedBox(
              width: 30,
            ),
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
                  indicator: CircleTabIndicator(color: Colors.white, radius: 4),
                  tabs: const [
                    Tab(text: "Player"),
                    Tab(text: "Queue"),
                    Tab(text: "Search"),
                  ]),
            ),
            SizedBox(
              width: double.maxFinite,
              height: constraints.maxHeight - 50,
              child: TabBarView(
                controller: tabController,
                children: [
                  const SpotifyPlayer(),
                  Queue(
                    voting: voting,
                  ),
                  const SearchItemScreen(),
                ],
              ),
            )
          ]);
        }),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SizedBox(
        height: 55,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('parties')
                .doc(widget.code)
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
                  voting = false;
                  countdown = false;

                  return const SizedBox();
                } else {
                  countdown = true;
                  _startParty = snapshot.data!.get("startParty");
                  _timer = snapshot.data!.get('timer');
                  _firstResearch = snapshot.data!.get('firstResearch');
                  _votingTime = snapshot.data!.get('votingTime');

                  return _bottomAppBar(context);
                }
              }
            }));
  }

  Widget _bottomAppBar(BuildContext context) {
    _updateCountdown();
    return BottomAppBar(
      elevation: 8.0,
      notchMargin: 8.0,
      color: const Color.fromARGB(255, 45, 44, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text(changed ? "Next voting in : " : "Voting ends in : ",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            _countdown(context)
          ])
        ],
      ),
    );
  }

  Widget _countdown(BuildContext context) {
    return CountdownTimer(
      endTime: endCountdown * 1000,
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
                    color: Color.fromARGB(228, 53, 191, 101),
                  ));
            }
            return Text("00:0${time.min}:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(228, 53, 191, 101),
                ));
          }

          if (time.min == null) {
            if (time.sec! / 10 < 1) {
              return Text("00:00:0${time.sec}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(228, 53, 191, 101),
                  ));
            }
            return Text("00:00:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(228, 53, 191, 101),
                ));
          }
          if (time.sec! / 10 < 1) {
            return Text("00:${time.min}:0${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(228, 53, 191, 101),
                ));
          }
          return Text("00:${time.min}:${time.sec}",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(228, 53, 191, 101),
              ));
        }
        if (time.hours! / 10 < 1) {
          if (time.min! / 10 < 1) {
            if (time.sec! / 10 < 1) {
              return Text("0${time.hours}:${time.min}:0${time.sec}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(228, 53, 191, 101),
                  ));
            }
            return Text("0${time.hours}:0${time.min}:${time.sec}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(228, 53, 191, 101),
                ));
          }
          return Text("0${time.hours}:${time.min}:${time.sec}",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(228, 53, 191, 101),
              ));
        }

        return Text("${time.hours}:${time.min}:${time.sec}",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(228, 53, 191, 101),
            ));
      },
      onEnd: _updateCountdown(),
    );
  }

  _updateCountdown() {
    int newCountdown =
        _computeCountdown(_startParty, _timer, _firstResearch, _votingTime);

    endCountdown = newCountdown;
    changed = !changed;
  }
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
    late Paint _paint;
    _paint = Paint()..color = color;
    _paint = _paint..isAntiAlias = true;
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
