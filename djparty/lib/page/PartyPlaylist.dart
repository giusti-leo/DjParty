import 'package:flutter/material.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/PlaylistPage.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PartyPlaylist extends StatefulWidget {
  static String routeName = 'PartyPlaylist';
  const PartyPlaylist({Key? key}) : super(key: key);

  @override
  State<PartyPlaylist> createState() => _PartyPlaylist();
}

class _PartyPlaylist extends State<PartyPlaylist> {
  final TextEditingController textController = TextEditingController();
  String endpoint =
      "https://api.spotify.com/v1/users/5ystmjllzk2mi1ja1r3jp3x26/playlists";
  String myToken = "";
  String input = "";
  bool isCreated = false;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Spotify.spotify,
                color: mainGreen,
              ),
              onPressed: (getAuthToken),
            ),
            buildTextField(context),
          ],
        ));
  }

  Widget buildTextField(BuildContext context) => SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        controller: textController,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: 'Playlist Name',
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: mainGreen,
            ),
          ),
          suffixIcon: IconButton(
              color: mainGreen,
              icon: const Icon(Icons.done, size: 30),
              onPressed: () {
                input = textController.text;
                _createPartyPlaylist(input, myToken);
                isCreated = true;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PlaylistPage(isCreated: isCreated)));
              }),
        ),
      ));

  Future<String> getAuthToken() async {
    var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: 'a502045e3c4b47d6b9bcfded418afd32',
        redirectUrl: 'test-1-login://callback',
        scope: 'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing');
    myToken = '$authenticationToken';
    print(myToken);
    return authenticationToken;
  }

  Future<http.Response> _createPartyPlaylist(
      String input, String myToken) async {
    return http.post(
      Uri.parse(endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
      body: jsonEncode(<String, String>{
        'name': input,
      }),
    );
  }
}
