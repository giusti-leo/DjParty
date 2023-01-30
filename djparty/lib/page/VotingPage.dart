import 'package:flutter/material.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VotingPage extends StatefulWidget {
  static String routeName = 'VotingPage';
  const VotingPage({Key? key}) : super(key: key);
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

  Future<List<dynamic>> GetTracks() async {
    var response = await http.get(Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + myToken
        });
    final tracksJson = json.decode(response.body);
    var trackList = tracksJson['queue'].toList();
    print(trackList);
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
    final alreadySaved = _votedTracks.contains(String);
    if (isCalled == false) {
      setState(() {
        getAuthToken();
      });
      isCalled = true;
    }
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(228, 53, 191, 101),
          title: const Text(
            'Voting Time!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(children: [
          // IconButton(
          //   icon: const Icon(
          //     Spotify.spotify,
          //     color: Color.fromARGB(228, 53, 191, 101),
          //   ),
          //   onPressed: () {
          //     getAuthToken();
          //   },
          // ),
          // ElevatedButton(
          //     onPressed: () {
          //       _updateTracks();
          //     },
          //     child: const Text('Get Tracks')),
          Expanded(
            child: ListView.builder(
                shrinkWrap: false,
                itemCount: _tracks.length,
                itemBuilder: (BuildContext context, int index) {
                  final track = _tracks[index];
                  var artistList = track["artists"].toList();
                  return _buildRow(track["name"], artistList[0]["name"]);
                }),
          )
        ]));
  }

  Widget _buildRow(String title, String subtitle) {
    final alreadySaved = _votedTracks.contains(title);

    return ListTile(
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
        trailing: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
            color:
                alreadySaved ? Color.fromARGB(228, 53, 191, 101) : Colors.grey),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              _votedTracks.remove(title);
            } else {
              _votedTracks.add(title);
            }
          });
        });
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
