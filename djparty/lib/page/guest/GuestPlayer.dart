import 'package:djparty/Icons/c_d_icons.dart';
import 'dart:math';
import 'package:djparty/entities/Track.dart';
import 'package:djparty/entities/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:djparty/entities/Party.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:djparty/Icons/SizedIconButton.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/Home.dart';
import 'package:update_notification/screens/update_notification.dart';
import 'package:quickalert/quickalert.dart';

class GuestPlayerNotStarted extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const GuestPlayerNotStarted({Key? key}) : super(key: key);

  @override
  _GuestPlayerNotStarted createState() => _GuestPlayerNotStarted();
}

class _GuestPlayerNotStarted extends State<GuestPlayerNotStarted>
    with TickerProviderStateMixin {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  bool isPaused = false;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _adminLobby(context));
  }

  Widget _adminLobby(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(children: [
      SizedBox(
        height: height * 0.052,
      ),
      SizedBox(
        height: height * 0.6,
        child: Center(
            child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 400,
                height: 400,
                colorBlendMode: BlendMode.hardLight,
              ),
            ),
            const Center(
              child: Text(
                'Songs in the Queue will be reproduced\nwhen the party will start.\nWait the admin starts the party!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )),
      )
    ]);
  }
}

class GuestPlayerSongRunning extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const GuestPlayerSongRunning({Key? key}) : super(key: key);

  @override
  _GuestPlayerSongRunning createState() => _GuestPlayerSongRunning();
}

class _GuestPlayerSongRunning extends State<GuestPlayerSongRunning>
    with TickerProviderStateMixin {
  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(children: [
        SizedBox(
          height: height * 0.052,
        ),
        Expanded(
          child: _playerWidget(context),
        ),
      ]),
    );
  }

  Widget _playerWidget(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('parties')
          .doc(fr.partyCode)
          .collection('Party')
          .doc('Song')
          .snapshots(),
      builder: (context, AsyncSnapshot snap) {
        if (!snap.hasData) {
          return Container();
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: mainGreen,
            backgroundColor: backGround,
            strokeWidth: 10,
          ));
        }

        final songSnap = snap.data!.data();
        Song song;
        song = Song.getPartyFromFirestore(songSnap);

        return Column(
          children: [
            const SizedBox(height: 50),
            (song.uri != '')
                ? SizedBox(
                    width: 250, height: 250, child: Image.network(song.images))
                : SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 400,
                      height: 400,
                      colorBlendMode: BlendMode.hardLight,
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            (song.uri != '')
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text(
                          song.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          song.artists.first,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                        Text(
                          'No Music in reprodution',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ]),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }
}

class GuestPlayerEnded extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';

  const GuestPlayerEnded({Key? key}) : super(key: key);

  @override
  _GuestPlayerEnded createState() => _GuestPlayerEnded();
}

class _GuestPlayerEnded extends State<GuestPlayerEnded>
    with TickerProviderStateMixin {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    final sr = context.read<SpotifyRequests>();

    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
    sr.getUserId();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _endParty(context));
  }

  Widget _endParty(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    bool pressed = false;

    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: height * 0.052,
        ),
        SizedBox(
          height: height * 0.70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (pressed) {
                    displayToastMessage(context,
                        'Playlist ${fr.partyName} already added!', mainGreen);
                  } else {
                    _handleCreatePlaylist(context);
                    pressed = true;
                  }
                },
                child: Wrap(
                  children: const [
                    Icon(
                      CD.spotify,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text("Get the Spotify Playlist of the Party!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleCreatePlaylist(BuildContext context) {
    final sr = context.read<SpotifyRequests>();
    final fr = context.read<FirebaseRequests>();
    sr.createPlaylist(fr.partyName!, sr.userId!);

    Future.delayed(const Duration(seconds: 1), () {
      sr.addSongsToPlaylist(fr.partyCode!);
    });

    displayToastMessage(
        context, 'Playlist ${fr.partyName} created!', mainGreen);
  }
}
