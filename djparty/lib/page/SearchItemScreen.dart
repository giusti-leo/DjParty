import 'package:djparty/entities/Track.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchItemScreen extends StatefulWidget {
  static String routeName = 'SearchItemScreen';
  final String code;
  const SearchItemScreen({
    Key? key,
    required this.code,
  }) : super(key: key);

  @override
  State<SearchItemScreen> createState() => _SearchItemScreen();
}

class _SearchItemScreen extends State<SearchItemScreen> {
  var db = FirebaseFirestore.instance;
  String endpoint = "https://api.spotify.com/v1/search";
  String addEndpoint =
      "https://api.spotify.com/v1/playlists/6fdrai0JDoaEVlvUPrfy7t/tracks";
  String queueEndpoint = "https://api.spotify.com/v1/me/player/queue";
  String checkEndpoint = "https://api.spotify.com/v1/me/player";
  Offset _tapPosition = Offset.zero;
  int selectedIndex = 100;
  List<Track> _tracks = [];
  String myToken = "";
  String input = "";

  var myColor = Colors.white;
  bool isCalled = false;
  //List<bool> isSelected = [];
  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  Future getData() async {
    final sp = context.read<SignInProvider>();

    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<List<dynamic>> GetTracks(String input, String myToken) async {
    var response = await http.get(Uri.parse(
        endpoint + "?q=" + input + "&type=track" + "&access_token=" + myToken));
    final tracksJson = json.decode(response.body)['tracks'];
    var trackList = tracksJson['items'].toList();

    return trackList;
  }

  Future _updateTracks(String input, String myToken, String user) async {
    List<dynamic> tracks = await GetTracks(input, myToken);
    List<Track> tmp = [];
    for (var element in tracks) {
      tmp.add(Track.getTrackFromSpotify(element, user));
    }

    setState(() {
      _tracks = tmp;
    });
  }

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
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

    final sp = context.read<SignInProvider>();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color.fromARGB(255, 35, 34, 34),
            body: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'Search for a track',
                      hintStyle: TextStyle(color: Colors.grey)),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  onChanged: (input) async =>
                      _tracks = await _updateTracks(input, myToken, sp.uid!),
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: _tracks.length,
                      itemBuilder: (BuildContext context, int index) {
                        Track track = _tracks[index];
                        return GestureDetector(
                          onTapDown: (details) => _getTapPosition(details),
                          onLongPress: () {
                            _showContextMenu(context, track);
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10.0),
                            title: Text(track.name!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: myColor,
                                )),
                            tileColor: selectedIndex == index
                                ? Color.fromARGB(228, 53, 191, 101)
                                : null,
                            subtitle: Text(printArtists(track.artists!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color.fromARGB(255, 134, 132, 132),
                                )),
                            leading: Image.network(
                              track.images!,
                              fit: BoxFit.cover,
                              height: 60,
                              width: 60,
                            ),
                          ),
                        );
                      }),
                )
              ],
            )));
  }

  String printArtists(List artistList) {
    String result = "";
    for (int i = 0; i < artistList.length; i++) {
      result += artistList[i];
      if (i < artistList.length - 1) {
        result += " , ";
      }
    }
    return result;
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
    setStatus('Got a token: $authenticationToken');
    myToken = '$authenticationToken';
    return authenticationToken;
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

  bool toggleSelection(bool selected) {
    setState(() {
      if (selected) {
        myColor = Colors.white;
        selected = false;
      } else {
        myColor = Color.fromARGB(228, 53, 191, 101);
        selected = true;
      }
    });
    return selected;
  }

  void _showContextMenu(BuildContext context, Track currentTrack) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    final result = await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: [
          PopupMenuItem(
            value: 'favorites',
            child: TextButton(
                child: Text('Add To Party Queue'),
                onPressed: () => _handleAddSongToQueue(currentTrack)),
          ),
        ]);
  }

  Future _handleAddSongToQueue(Track currentTrack) async {
    //connectToSpotify();
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    fp.checkPartyExists(code: widget.code).then((value) async {
      if (value == false) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        return;
      } else {
        fp.isPartyEnded().then((value) {
          if (value == true) {
            showInSnackBar(
                context,
                'You cannot add a new song when the Party is not on',
                Colors.red);
            return;
          } else {
            fp.songExists(currentTrack).then(
              (value) {
                if (fp.hasError) {
                  showInSnackBar(context, fp.errorCode.toString(), Colors.red);
                  return;
                } else {
                  if (value == false) {
                    fp.addSongToFirebase(currentTrack).then(
                      (value) {
                        if (fp.hasError) {
                          showInSnackBar(
                              context, fp.errorCode.toString(), Colors.red);
                        } else {
                          displayToastMessage(
                              context, 'Song Added', Colors.green);
                        }
                      },
                    );
                  } else {
                    displayToastMessage(
                        context, 'Song already present!', Colors.green);
                  }
                }
              },
            );
          }
        });
      }
    });
  }
/*
  Future<http.Response> _addItemToPlaylist() async {
    return http.post(
      Uri.parse(addEndpoint + "?uris=" + currentTrack.uri!),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
    );
  }

  Future<http.Response> _addItemToSpotifyQueue() async {
    return http.post(
      Uri.parse(queueEndpoint + "?uri=" + currentTrack.uri!),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
    );
  }*/

  Future<void> firestoreUpload(String uri, String) async {}

  Future<void> checkDiffMs() async {
    var response = await http.get(
      Uri.parse(checkEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
    );
    final playerJson = json.decode(response.body);
    //var playerList = playerJson.toList();
    if (playerJson["item"]["duration_ms"] - playerJson["progress_ms"] <=
        10000) {
      //currentUri = "spotify:track:2qSAO6IlPb5HpoySjTJsn7";
      //_addItemToQueue();
    } else {
      checkDiffMs();
    }
  }
}
