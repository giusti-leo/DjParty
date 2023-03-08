import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Track.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class SpotifyRequests extends ChangeNotifier {
  final String endpoint = "https://api.spotify.com/v1/search";
  final String addEndpoint =
      "https://api.spotify.com/v1/playlists/6fdrai0JDoaEVlvUPrfy7t/tracks";
  final String queueEndpoint = "https://api.spotify.com/v1/me/player/queue";
  final String checkEndpoint = "https://api.spotify.com/v1/me/player";
  final String clientID = 'a502045e3c4b47d6b9bcfded418afd32';

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

  String? _myToken;
  String? get myToken => _myToken;

  bool? _loading;
  bool? get loading => _loading;

  bool? _connected;
  bool? get connected => _connected;

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
    _myToken = '$authenticationToken';
    return authenticationToken;
  }

  Future<bool> connectToSpotify() async {
    bool _loading = false;
    try {
      _loading = true;
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientID, redirectUrl: 'test-1-login://callback');
      if (result) {
        _connected = true;
      } else {
        _connected = false;
      }
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      _loading = false;
      return _loading;
    } on PlatformException catch (e) {
      _loading = false;
      setStatus(e.code, message: e.message);
      return _loading;
    } on MissingPluginException {
      _loading = false;
      setStatus('not implemented');
      return _loading;
    }
  }

  Future<http.Response> addItemToPlaylist(String uri) async {
    return http.post(
      Uri.parse(addEndpoint + "?uris=" + uri),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken!
      },
    );
  }

  Future<http.Response> addItemToSpotifyQueue(String uri) async {
    return http.post(
      Uri.parse(queueEndpoint + "?uri=" + uri),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken!
      },
    );
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

  Future<bool> checkDiffMs() async {
    bool checked = false;
    var response = await http.get(
      Uri.parse(checkEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + myToken!
      },
    );
    final playerJson = json.decode(response.body);
    //var playerList = playerJson.toList();
    if (playerJson["item"]["duration_ms"] - playerJson["progress_ms"] <=
        10000) {
      checked = true;
      //"spotify:track:2qSAO6IlPb5HpoySjTJsn7";
      addItemToSpotifyQueue('spotify:track:2qSAO6IlPb5HpoySjTJsn7');
    } else {
      checked = false;
      checkDiffMs();
    }
    return checked;
  }
}
