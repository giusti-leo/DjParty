import 'package:djparty/services/SpotifyRequests.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

Widget getConnection() {
  return StreamBuilder(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        if (snapshot.data!.connected == true) {
          return Container();
        } else {
          final sr = context.read<SpotifyRequests>();

          sr.getUserId();
          sr.getAuthToken();
          sr.connectToSpotify();
          return Container();
        }
      });
}
