import 'package:flutter/material.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List _tracks = [];
  String myToken = "";
  String input = "";
  String currentUri = "";
  var artistList = [];
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

  Future<List<dynamic>> GetTracks(String input, String myToken) async {
    var response = await http.get(Uri.parse(
        endpoint + "?q=" + input + "&type=track" + "&access_token=" + myToken));
    final tracksJson = json.decode(response.body)['tracks'];
    var trackList = tracksJson['items'].toList();

    return trackList;
  }

  Future _updateTracks(String input, String myToken) async {
    List<dynamic> tracks = await GetTracks(input, myToken);
    setState(() {
      _tracks = tracks;
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color.fromARGB(228, 53, 191, 101),
                secondary: const Color.fromARGB(228, 53, 191, 101))),
        home: Scaffold(
            backgroundColor: Color.fromARGB(255, 35, 34, 34),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
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
                      _tracks = await _updateTracks(input, myToken),
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: _tracks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final track = _tracks[index];
                        var artistList = track['artists'].toList();
                        var imageList = track["album"]["images"].toList();
                        return GestureDetector(
                          onTapDown: (details) => _getTapPosition(details),
                          onLongPress: () {
                            currentUri = track["uri"];
                            _showContextMenu(context);
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10.0),
                            title: Text(track["name"],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: myColor,
                                )),
                            tileColor: selectedIndex == index
                                ? Color.fromARGB(228, 53, 191, 101)
                                : null,
                            subtitle: Text(printArtists(artistList),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color.fromARGB(255, 134, 132, 132),
                                )),
                            leading: Image.network(
                              imageList[1]["url"],
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
      artistList[i] = artistList[i]["name"];
    }
    result = artistList.join(" , ");
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

  void _showContextMenu(BuildContext context) async {
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
              child: Text('Add To Party Playlist'),
              onPressed: () => _addItemToPlaylist(),
            ),
          ),
          PopupMenuItem(
            value: 'favorites',
            child: TextButton(
              child: Text('Add To Party Queue'),
              onPressed: () {
                //_addItemToQueue();
                firestoreUpload(currentUri, "91oyCAW3O8MSt5uXNxBSWhIdfG92", 0);
                checkDiffMs();
              },
            ),
          ),
        ]);
  }

  Future<http.Response> _addItemToPlaylist() async {
    return http.post(
      Uri.parse(addEndpoint + "?uris=" + currentUri),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
    );
  }

  Future<http.Response> _addItemToQueue() async {
    return http.post(
      Uri.parse(queueEndpoint + "?uri=" + currentUri),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken
      },
    );
  }

  Future<void> firestoreUpload(String uri, String id, int votes) async {
    Map<String, dynamic> track = {'uri': uri, 'id': id, 'votes': votes};
    List list = [track];
    final docRef = db.collection("parties").doc("tq09O");
    await docRef.update({'queue': FieldValue.arrayUnion(list)});
  }

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
      _addItemToQueue();
    } else {
      checkDiffMs();
    }
  }
}

class Track {
  final String? uri;
  final String? id;
  final int? votes;

  Track({
    this.uri,
    this.id,
    this.votes,
  });

  factory Track.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Track(
      uri: data?['uri'],
      id: data?['id'],
      votes: data?['votes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uri != null) "uri": uri,
      if (id != null) "id": id,
      if (votes != null) "votes": votes,
    };
  }
}
