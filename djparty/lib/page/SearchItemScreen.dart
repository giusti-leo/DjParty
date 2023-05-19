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

import 'package:djparty/services/SpotifyRequests.dart';

class SearchItemScreen extends StatefulWidget {
  static String routeName = 'SearchItemScreen';
  const SearchItemScreen({Key? key}) : super(key: key);

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
  String input = "";
  bool _insert = false;
  var myColor = Colors.white;
  bool isCalled = false;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  final Logger _logger = Logger(
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
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();

    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<List<dynamic>> GetTracks(String input, String? myToken) async {
    var response = await http.get(
        Uri.parse("$endpoint?q=$input&type=track&access_token=${myToken!}"));
    final tracksJson = json.decode(response.body)['tracks'];
    var trackList = tracksJson['items'].toList();

    return trackList;
  }

  Future _updateTracks(String input, String? myToken, String user) async {
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
    final sp = context.read<SignInProvider>();
    final sr = context.read<SpotifyRequests>();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: mainGreen)),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: backGround,
            body: Column(
              children: [
                TextField(
                  readOnly: _insert,
                  decoration: const InputDecoration(
                      hintText: 'Search for a track',
                      hintStyle: TextStyle(color: Colors.grey)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  onChanged: (input) async =>
                      _tracks = await _updateTracks(input, sr.myToken, sp.uid!),
                  onTap: () => setState(() {
                    _insert = false;
                  }),
                ),
                const SizedBox(
                  height: 10,
                ),
                _tracks.toString() != '[]'
                    ? Expanded(
                        child: ListView.builder(
                            shrinkWrap: false,
                            itemCount: _tracks.length,
                            itemBuilder: (BuildContext context, int index) {
                              Track track = _tracks[index];
                              return GestureDetector(
                                onTapDown: (details) {
                                  _getTapPosition(details);
                                  setState(() {
                                    selectedIndex = 100;
                                    _insert = true;
                                  });
                                },
                                onPanCancel: () => setState(() {
                                  selectedIndex = 100;
                                  _insert = true;
                                }),
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    _insert = true;
                                  });
                                  _showContextMenu(context, track);
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      title: Text(track.name!,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: myColor,
                                          )),
                                      tileColor: selectedIndex == index
                                          ? mainGreen
                                          : null,
                                      subtitle:
                                          Text(printArtists(track.artists!),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: Color.fromARGB(
                                                    255, 134, 132, 132),
                                              )),
                                      leading: Image.network(
                                        track.images!,
                                        fit: BoxFit.cover,
                                        height: 60,
                                        width: 60,
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 1,
                                    )
                                  ],
                                ),
                              );
                            }),
                      )
                    : Container()
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

  bool toggleSelection(bool selected) {
    setState(() {
      if (selected) {
        myColor = Colors.white;
        selected = false;
      } else {
        myColor = mainGreen;
        selected = true;
      }
    });
    return selected;
  }

  void _showContextMenu(BuildContext context, Track currentTrack) async {
    final RenderObject? overlay =
        Overlay.of(context)!.context.findRenderObject();
    await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: [
          PopupMenuItem(
            value: 'favorites',
            child: TextButton(
                child: const Text('Add To Party Queue'),
                onPressed: () {
                  _handleAddSongToQueue(currentTrack);
                  setState(() {
                    _insert = true;
                    selectedIndex = 100;
                  });
                  Navigator.pop(context);
                }),
          ),
        ]);
  }

  Future _handleAddSongToQueue(Track currentTrack) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      return;
    }

    fr.checkPartyExists(code: fr.partyCode!).then((value) async {
      if (value == false) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        return;
      } else {
        fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
          if (value == true) {
            displayToastMessage(
                context,
                'You cannot add a new song when the Party is not on',
                alertColor);
            return;
          }
          fr.saveDataToSharedPreferences().then((value) {
            fr.songExists(currentTrack).then(
              (value) {
                if (fr.hasError) {
                  displayToastMessage(
                      context, fr.errorCode.toString(), alertColor);
                  return;
                } else {
                  if (fr.isEnded!) {
                    displayToastMessage(
                        context, 'Sorry, the party is ended!', alertColor);
                  } else {
                    if (value == false) {
                      fr.addSongToFirebase(currentTrack).then(
                        (value) {
                          if (fr.hasError) {
                            displayToastMessage(
                                context, fr.errorCode.toString(), alertColor);
                          } else {
                            displayToastMessage(
                                context, 'Song added', mainGreen);
                          }
                        },
                      );
                    } else {
                      displayToastMessage(
                          context, 'Song already present!', mainGreen);
                    }
                  }
                }
              },
            );
          });
        });
      }
    });
  }
}
