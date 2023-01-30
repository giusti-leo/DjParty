import 'package:flutter/material.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/spotifyPlayer.dart';
import 'package:djparty/page/Queue.dart';
import 'package:djparty/page/VotingPage.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpotifyTabController extends StatefulWidget {
  static String routeName = 'SpotifyTabController';
  const SpotifyTabController({Key? key, required this.myToken})
      : super(key: key);
  final String myToken;

  @override
  State<SpotifyTabController> createState() => _SpotifyTabController();
}

class _SpotifyTabController extends State<SpotifyTabController>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(228, 53, 191, 101),
          title: const Text(
            'Party Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              nextScreen(context, const VotingPage());
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.only(left: 20, right: 20),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator:
                        CircleTabIndicator(color: Colors.white, radius: 4),
                    tabs: const [
                      Tab(text: "Player"),
                      Tab(text: "Queue"),
                      Tab(text: "Search"),
                    ]),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              height: 550,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SpotifyPlayer(),
                  Queue(),
                  SearchItemScreen(),
                ],
              ),
            )
          ]),
        ));
  }

  // Future<String> getAuthToken() async {
  //   var authenticationToken = await SpotifySdk.getAccessToken(
  //       clientId: 'a502045e3c4b47d6b9bcfded418afd32',
  //       redirectUrl: 'test-1-login://callback',
  //       scope: 'app-remote-control, '
  //           'user-modify-playback-state, '
  //           'playlist-read-private, '
  //           'playlist-modify-public,user-read-currently-playing,'
  //           'playlist-modify-private,'
  //           'user-read-playback-state');
  //   myToken = '$authenticationToken';
  //   print(myToken);
  //   return authenticationToken;
  // }
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
