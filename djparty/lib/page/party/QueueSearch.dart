import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:djparty/Icons/c_d_icons.dart';
import 'package:djparty/entities/Party.dart';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:djparty/services/SpotifyRequests.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class QueueSearch extends StatefulWidget {
  static String routeName = 'SearchItemScreen';

  User loggedUser;
  FirebaseFirestore db;
  String code;

  QueueSearch(
      {super.key,
      required this.loggedUser,
      required this.code,
      required this.db});

  @override
  State<QueueSearch> createState() => _QueueSearch();
}

class _QueueSearch extends State<QueueSearch> {
  final TextEditingController textController = TextEditingController();

  String endpoint = "https://api.spotify.com/v1/search";

  Offset _tapPosition = Offset.zero;
  int selectedIndex = 100;
  List<Track> _tracks = [];
  List<Track> songs = [];

  var myColor = Colors.white;
  List<Track> queue = [];

  bool _showSearch = true;
  int queueLength = 0;

  final _formKey = GlobalKey<FormState>();

  final key = GlobalKey();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    await _getSongs(widget.code);
  }

  @override
  void initState() {
    super.initState();
    getData();

    _showSearch = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> getTracks(String input, String? myToken) async {
    var response = await http.get(
        Uri.parse("$endpoint?q=$input&type=track&access_token=${myToken!}"));
    final tracksJson = json.decode(response.body)['tracks'];
    var trackList = [];
    if (tracksJson != null) {
      trackList = tracksJson['items'].toList();
    }

    return trackList;
  }

  Future _updateTracks(String input, String? myToken, String user) async {
    List<dynamic> tracks = await getTracks(input, myToken);
    if (tracks.isNotEmpty) {
      List<Track> tmp = [];
      for (var element in tracks) {
        tmp.add(Track.getTrackFromSpotify(element, user));
      }

      setState(() {
        _tracks = tmp;
      });
    }
  }

  Future _getSongs(String code) async {
    List<Track> songsNew = [];
    int queueLen = 0;

    await widget.db
        .collection('parties')
        .doc(widget.code)
        .collection("queue")
        .where('inQueue', isEqualTo: true)
        .orderBy('votes')
        .limit(100)
        .get()
        .then((value) {
      for (var element in value.docs) {
        Track currentTrack = Track.getTrackFromFirestore(element);
        songsNew.add(currentTrack);
        queueLen = queueLen + 1;
      }
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: mainGreen)),
        home: Scaffold(
          backgroundColor: backGround,
          body: Center(
            child: SizedBox(
              width: width * 0.7,
              child: Align(
                child: ListView(
                  key: key,
                  children: [
                    SizedBox(
                      height: height * 0.05,
                    ),
                    Form(key: _formKey, child: searchBuilder(context)),
                    SizedBox(
                      height: height * 0.001,
                    ),
                    _showSearch
                        ? SizedBox(
                            height: height * 0.8,
                            child: Column(
                              children: [
                                (_tracks.toString() != '[]')
                                    ? Expanded(
                                        child: ListView.builder(
                                            itemCount: _tracks.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Track track = _tracks[index];
                                              return GestureDetector(
                                                  onTapDown: (details) {
                                                    _getTapPosition(details);
                                                    setState(() {
                                                      selectedIndex = 100;
                                                    });
                                                  },
                                                  onPanCancel: () =>
                                                      setState(() {
                                                        selectedIndex = 100;
                                                      }),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedIndex = index;
                                                    });
                                                    _showContextMenu(
                                                        context, track);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        title: Text(track.name,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: myColor,
                                                            )),
                                                        tileColor:
                                                            selectedIndex ==
                                                                    index
                                                                ? mainGreen
                                                                : null,
                                                        subtitle: Text(
                                                            printArtists(
                                                                track.artists),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      134,
                                                                      132,
                                                                      132),
                                                            )),
                                                        leading: Image.network(
                                                          track.images,
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
                                                  ));
                                            }))
                                    : Container()
                              ],
                            ))
                        : SizedBox(
                            height: height * 0.5,
                            child: FutureBuilder(
                                future: widget.db
                                    .collection('parties')
                                    .doc(widget.code)
                                    .collection('queue')
                                    .where('inQueue', isEqualTo: true)
                                    .orderBy('votes')
                                    .limit(100)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  if (snapshot.data!.docs.isNotEmpty) {
                                    songs.clear();
                                    queueLength = 0;
                                    for (var element
                                        in snapshot.data!.docs.reversed) {
                                      Track currentTrack =
                                          Track.getTrackFromFirestore(element);
                                      songs.add(currentTrack);
                                      queueLength = queueLength + 1;
                                    }
                                  }

                                  return StreamBuilder(
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
                                            VotingStatus.getPartyFromFirestore(
                                                partySnap);
                                        if (!votingStatus.voting!) {
                                          return queueListSong(context);
                                        } else {
                                          return queueVoteSong(context);
                                        }
                                      });
                                }))
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget searchBuilder(BuildContext context) {
    final sr = context.read<SpotifyRequests>();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * .7,
      child: TextField(
          textAlign: TextAlign.start,
          controller: textController,
          cursorColor: Colors.white,
          autocorrect: false,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          onChanged: (input) async {
            await _updateTracks(input, sr.myToken, widget.loggedUser.uid);
          },
          onTap: () async {
            setState(() {
              _showSearch = true;
            });
            await _getSongs(widget.code);
          },
          onEditingComplete: () async {
            await _getSongs(widget.code);
          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: 'Search a track',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            suffixIcon: (_showSearch == true)
                ? IconButton(
                    color: Colors.white,
                    icon: const Icon(
                      Icons.expand,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      setState(() {
                        _showSearch = false;
                      });
                      await _getSongs(widget.code);
                    },
                  )
                : IconButton(
                    color: Colors.white,
                    icon: const Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() {
                      _showSearch = true;
                    }),
                  ),
          )),
    );
  }

  Widget queueVoteSong(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return SizedBox(
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.db
              .collection('parties')
              .doc(widget.code)
              .collection('queue')
              .where('inQueue', isEqualTo: true)
              .orderBy('votes')
              .limit(100)
              .get()
              .then((value) {
            if (value.size > 0) {
              songs.clear();
              List<Track> newList = [];
              int queueLen = 0;
              for (var element in value.docs) {
                Track currentTrack = Track.getTrackFromFirestore(element);
                newList.add(currentTrack);
                queueLen = queueLen + 1;
              }
              setState(() {
                songs = newList;
                queueLength = queueLen;
              });
            }
          });
        },
        child: Column(children: [
          (queueLength > 0)
              ? Expanded(
                  child: ListView.builder(
                      itemCount: queueLength,
                      itemBuilder: (BuildContext context, int index) {
                        Track currentTrack = songs[index];
                        return Column(
                          children: [
                            ListTile(
                              tileColor: backGround,
                              title: Text(currentTrack.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                              subtitle: Text(currentTrack.artists[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromARGB(255, 134, 132, 132),
                                  )),
                              leading: Image.network(
                                currentTrack.images,
                                fit: BoxFit.cover,
                                height: 60,
                                width: 60,
                              ),
                              trailing: Icon(
                                  userLikeSong(currentTrack)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: userLikeSong(currentTrack)
                                      ? mainGreen
                                      : Colors.white),
                              onTap: () {
                                _handleLikeLogic(currentTrack);
                              },
                            ),
                            Text(
                              'Like: ${currentTrack.likes.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Divider(
                              color: Colors.white24,
                              height: 1,
                            ),
                          ],
                        );
                      }),
                )
              : Container()
        ]),
      ),
    );
  }

  Future _handleLikeLogic(Track track) async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      return;
    }

    if (!userLikeSong(track)) {
      _handleLikeSong(track);
    } else {
      _handleDisLikeSong(track);
    }
  }

  bool userLikeSong(Track track) {
    return (track.likes.contains(widget.loggedUser.uid));
  }

  void _handleLikeSong(Track track) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    List<String> newLikes = track.likes;
    newLikes.add(widget.loggedUser.uid);

    setState(() {
      track.likes = newLikes;
    });

    fr
        .userLikesSong(track.uri, widget.loggedUser.uid, widget.code)
        .then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
        return;
      }
    });
  }

  void _handleDisLikeSong(Track track) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    List<String> newLikes = track.likes;
    newLikes.remove(widget.loggedUser.uid);

    setState(() {
      track.likes = newLikes;
    });

    fr
        .userDoesNotLikeSong(track.uri, widget.loggedUser.uid, widget.code)
        .then((value) {
      if (fr.hasError) {
        showInSnackBar(context, fr.errorCode.toString(), alertColor);
        return;
      }
    });
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

  Widget queueListSong(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    return Scaffold(
        backgroundColor: backGround,
        body: RefreshIndicator(
          onRefresh: () async {
            await widget.db
                .collection('parties')
                .doc(widget.code)
                .collection('queue')
                .where('inQueue', isEqualTo: true)
                .orderBy('votes')
                .limit(100)
                .get()
                .then((value) {
              if (value.size > 0) {
                songs.clear();
                List<Track> newList = [];
                int queueLen = 0;
                for (var element in value.docs) {
                  Track currentTrack = Track.getTrackFromFirestore(element);
                  newList.add(currentTrack);
                  queueLen = queueLen + 1;
                }
                setState(() {
                  songs = newList;
                  queueLength = queueLen;
                });
              }
            });
          },
          child: Column(children: [
            (queueLength > 0)
                ? Expanded(
                    flex: 1,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queueLength,
                        itemBuilder: (BuildContext context, int index) {
                          Track currentTrack = songs[index];

                          return Column(
                            children: [
                              ListTile(
                                title: Text(currentTrack.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                                subtitle: Text(currentTrack.artists[0],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color.fromARGB(255, 134, 132, 132),
                                    )),
                                leading: Image.network(
                                  currentTrack.images,
                                  fit: BoxFit.cover,
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              Text(
                                'votes: ${currentTrack.likes.length}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Divider(
                                color: Colors.white24,
                                height: 1,
                              )
                            ],
                          );
                        }),
                  )
                : Container()
          ]),
        ));
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
                    selectedIndex = 100;
                  });
                  Navigator.pop(context);
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
          ),
        ]);
  }

  Future _handleAddSongToQueue(Track currentTrack) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      return;
    }

    fr.checkPartyExists(code: widget.code).then((value) async {
      if (value == false) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        return;
      } else {
        fr.getPartyDataFromFirestore(widget.code).then((value) {
          if (value == true) {
            displayToastMessage(
                context,
                'You cannot add a new song when the Party is not on',
                alertColor);
            return;
          }
          fr.songExists(currentTrack, widget.code).then(
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
                    fr
                        .addSongToFirebase(
                            currentTrack, widget.code, widget.loggedUser.uid)
                        .then(
                      (value) {
                        if (fr.hasError) {
                          displayToastMessage(
                              context, fr.errorCode.toString(), alertColor);
                        } else {
                          displayToastMessage(context, 'Song added', mainGreen);
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
      }
    });
  }
}

class SongLists extends StatefulWidget {
  static String routeName = 'SearchItemScreen';
  User loggedUser;
  FirebaseFirestore db;
  String code;

  SongLists(
      {super.key,
      required this.loggedUser,
      required this.code,
      required this.db});

  @override
  State<SongLists> createState() => _SongLists();
}

class _SongLists extends State<SongLists> {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: mainGreen, secondary: mainGreen)),
        home: Scaffold(
            backgroundColor: backGround,
            body: Column(children: [
              SizedBox(
                height: height * 0.018,
              ),
              SizedBox(
                height: height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('parties')
                            .doc(widget.code)
                            .collection('members')
                            .doc(widget.loggedUser.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }

                          bool spotifyPlaylist =
                              snapshot.data!.data()!['playlistSpotify'];

                          if (spotifyPlaylist) {
                            return const SizedBox(
                              height: 40,
                              child: Text("Playlist already added to Spotify!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                            );
                          } else {
                            return SizedBox(
                              height: height * 0.05,
                              width: width * 0.70,
                              child: RoundedLoadingButton(
                                onPressed: () {
                                  _handleCreatePlaylist(context);
                                },
                                controller: partyController,
                                successColor: mainGreen,
                                elevation: 0,
                                borderRadius: 25,
                                color: mainGreen,
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      CD.spotify,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Get the Spotify Playlist!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(flex: 1, child: fullSongList(context)),
            ])));
  }

  Widget fullSongList(BuildContext context) {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 1,
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('parties')
              .doc(widget.code)
              .collection('queue')
              .orderBy('lastStreaming')
              .limit(50)
              .get(),
          builder: (context, AsyncSnapshot snap1) {
            if (snap1.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: mainGreen,
                backgroundColor: backGround,
                strokeWidth: 10,
              ));
            }
            if (!snap1.hasData) {
              return const Center(
                  child: Text(
                'No data found',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ));
            }
            if (snap1.data.docs.toString() == '[]') {
              return Center(
                  child: RichText(
                text: TextSpan(
                  text: 'Hello ',
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(
                        text: '${widget.loggedUser.displayName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    const TextSpan(
                        text: '. No songs in your Queue!',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white)),
                  ],
                ),
              ));
            } else {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: snap1.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final track = snap1.data.docs[index];
                            Track currentTrack =
                                Track.getTrackFromFirestore(track);
                            return SizedBox(
                              child: Column(
                                children: [
                                  ListTile(
                                    tileColor: backGround,
                                    title: Text(currentTrack.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                    subtitle: Text(currentTrack.artists[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color.fromARGB(
                                              255, 134, 132, 132),
                                        )),
                                    leading: Image.network(
                                      currentTrack.images,
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.white24,
                                    height: 1,
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
                  ]));
            }
          }),
    );
  }

  void _handleCreatePlaylist(BuildContext context) async {
    final sr = context.read<SpotifyRequests>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    FirebaseFirestore.instance
        .collection('parties')
        .doc(widget.code)
        .collection('members')
        .doc(widget.loggedUser.uid)
        .get()
        .then(
      (value) async {
        if (value.data()!['playlistSpotify'] == true) {
          displayToastMessage(context,
              'Playlist DjParty_${widget.code} already created!', alertColor);
          partyController.reset();
        } else {
          sr.createPlaylist('DjParty_${widget.code}', sr.userId);

          Future.delayed(const Duration(seconds: 1), () {
            sr.addSongsToPlaylist(widget.code);
          });

          await fr.addPlaylist(widget.loggedUser.uid, widget.code);

          partyController.reset();

          displayToastMessage(context,
              'Playlist name  DjParty_${widget.code} created!', mainGreen);
        }
      },
    );
  }
}

class QueueRow extends StatelessWidget {
  final Track currentTrack;
  User loggedUser;
  FirebaseFirestore db;

  QueueRow(this.currentTrack, this.loggedUser, this.db, {Key? key})
      : super(key: key);

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                    tileColor: backGround,
                    title: Text(currentTrack.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    subtitle: Text(currentTrack.artists[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 134, 132, 132),
                        )),
                    leading: Image(
                      image: CachedNetworkImageProvider(currentTrack.images),
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                    ),
                    trailing: Icon(
                        userLikeSong(currentTrack)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: userLikeSong(currentTrack)
                            ? mainGreen
                            : Colors.white),
                    onTap: () {},
                  ),
                  Text(
                    'Like: ${currentTrack.likes.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  ),
                ],
              );
            }),
      )
    ]);
  }

  bool userLikeSong(Track track) {
    return (track.likes.contains(loggedUser.uid));
  }
}

class QueueRowNotVoting extends StatelessWidget {
  final Track currentTrack;
  User loggedUser;
  FirebaseFirestore db;

  QueueRowNotVoting(this.currentTrack, this.loggedUser, this.db, {Key? key})
      : super(key: key);

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                    title: Text(currentTrack.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    subtitle: Text(currentTrack.artists[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 134, 132, 132),
                        )),
                    leading: Image(
                      image: CachedNetworkImageProvider(currentTrack.images),
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                    ),
                  ),
                  Text(
                    'votes: ${currentTrack.likes.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  )
                ],
              );
            }),
      )
    ]);
  }

  bool userLikeSong(Track track) {
    return (track.likes.contains(loggedUser.uid));
  }
}
