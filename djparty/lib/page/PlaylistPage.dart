import 'package:flutter/material.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaylistPage extends StatefulWidget {
  static String routeName = 'PlaylistPage';
  const PlaylistPage({super.key, required this.isCreated});
  final bool isCreated;

  @override
  State<PlaylistPage> createState() => _PlaylistPage();
}

class _PlaylistPage extends State<PlaylistPage> {
  final TextEditingController textController = TextEditingController();
  String endpoint =
      "https://api.spotify.com/v1/playlists/6fdrai0JDoaEVlvUPrfy7t/tracks?fields=items(track)";
  String myToken = "";
  String input = "";
  List _tracks = [];

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future<List<dynamic>> GetTracks() async {
    var response = await http.get(Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + myToken
        });
    final tracksJson = json.decode(response.body);
    var trackList = tracksJson['items'].toList();
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
    return Scaffold(
        backgroundColor: backGround,
        appBar: AppBar(
          backgroundColor: mainGreen,
          title: const Text(
            'Party Playlist',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(children: [
          IconButton(
            icon: Icon(
              Spotify.spotify,
              color: mainGreen,
            ),
            onPressed: (getAuthToken),
          ),
          ElevatedButton(
              onPressed: () {
                _updateTracks();
              },
              child: const Text('Get Tracks')),
          Expanded(
            child: ListView.builder(
                shrinkWrap: false,
                itemCount: _tracks.length,
                itemBuilder: (BuildContext context, int index) {
                  final track = _tracks[index];
                  var artistList = track["track"]["artists"].toList();
                  return ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    title: Text(track["track"]["name"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    subtitle: Text(artistList[0]["name"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 134, 132, 132),
                        )),
                  );
                }),
          )
        ]));
  }

  Future<String> getAuthToken() async {
    var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: 'a502045e3c4b47d6b9bcfded418afd32',
        redirectUrl: 'test-1-login://callback',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing,'
            'playlist-modify-private');
    myToken = '$authenticationToken';
    print(myToken);
    return authenticationToken;
  }
}
