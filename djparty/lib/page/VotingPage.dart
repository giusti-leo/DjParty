import 'package:djparty/page/SpotifyTabController.dart';
import 'package:flutter/material.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:djparty/page/SpotifyTabController.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class VotingPage extends StatefulWidget {
  static String routeName = 'VotingPage';
  final String code;
  const VotingPage({Key? key, required this.code}) : super(key: key);
  @override
  State<VotingPage> createState() => _VotingPage();
}

class _VotingPage extends State<VotingPage> {
  final TextEditingController textController = TextEditingController();
  String endpoint = "https://api.spotify.com/v1/me/player/queue";
  String myToken = "";
  String input = "";
  List _tracks = [];
  bool isCalled = false;

  final _votedTracks = Set<String>();
  List<double> votingIndex = List.filled(100, 0);
  List<int> votes = List.filled(100, 0);

  Future<List<dynamic>> GetTracks() async {
    var response = await http.get(Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + myToken
        });
    final tracksJson = json.decode(response.body);
    var trackList = tracksJson['queue'].toList();
    _tracks = trackList;

    return trackList;
  }

  Future _updateTracks() async {
    List<dynamic> tracks = await GetTracks();
    setState(() {
      _tracks = tracks;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCalled == false) {
      setState(() {
        getAuthToken();
      });
      isCalled = true;
    }
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 35, 34, 34),
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 35, 34, 34),
      //   title: const Text(
      //     'Voting Time!',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   //centerTitle: true,
      // ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
              shrinkWrap: false,
              itemCount: _tracks.length,
              itemBuilder: (BuildContext context, int index) {
                final track = _tracks[index];
                var artistList = track["artists"].toList();
                var imageList = track["album"]["images"].toList();
                return _buildRow(track["name"], artistList[0]["name"],
                    imageList[1]["url"], index);
              }),
        )
      ]),
      bottomNavigationBar:
          SizedBox(height: 55, child: _buildBottomBar(context)),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    void goToTabPage() {
      nextScreenReplace(
          context,
          SpotifyTabController(
            code: widget.code,
          ));
    }

    int endTime = DateTime.now().millisecondsSinceEpoch + 10000;
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
            const Text("Voting ends in: ",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            CountdownTimer(
              endTime: endTime,
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
              onEnd: goToTabPage,
            ),
          ])
        ],
      ),
    );
  }

  Widget _buildRow(String title, String subtitle, dynamic image, int index) {
    final alreadySaved = _votedTracks.contains(title);

    return Column(children: [
      ListTile(
          contentPadding: const EdgeInsets.all(10.0),
          title: Text(title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
          subtitle: Text(subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 134, 132, 132),
              )),
          leading: Image.network(
            image,
            fit: BoxFit.cover,
            height: 60,
            width: 60,
          ),
          trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
              color: alreadySaved
                  ? const Color.fromARGB(228, 53, 191, 101)
                  : Colors.grey),
          onTap: () {
            setState(() {
              if (alreadySaved) {
                votingIndex[index] = votingIndex[index] - 1;
                _votedTracks.remove(title);
              } else {
                votingIndex[index] = votingIndex[index] + 1;
                _votedTracks.add(title);
              }
            });
          }),
      Text(
        'votes: ' + votingIndex[index].round().toString(),
        style: const TextStyle(color: Colors.white),
      ),
      // FAProgressBar(
      //   currentValue: votingIndex[index],
      //   backgroundColor: Color.fromARGB(255, 35, 34, 34),
      //   progressColor: Color.fromARGB(228, 53, 191, 101),
      //   //displayText: ' votes',
      //   maxValue: 100,
      // ),
      const Divider(
        color: Colors.white24,
        height: 1,
      )
    ]);
  }

  Future<String> getAuthToken() async {
    var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: 'a502045e3c4b47d6b9bcfded418afd32',
        redirectUrl: 'test-1-login://callback',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing,'
            'playlist-modify-private,'
            'user-read-playback-state');
    myToken = '$authenticationToken';
    _updateTracks();
    print(myToken);
    return authenticationToken;
  }
}
