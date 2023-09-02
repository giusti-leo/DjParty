import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUp(() {});

  test("addItemToQueue", () async {
    SpotifyRequests sr = SpotifyRequests();
    http.Response response =
        await sr.addItemToSpotifyQueue("spotify:track:2cfhFcqpEoM65MNc5cVZse");
    expect(response is http.Response, true);
  });

  test("connectToSpotify", () async {
    SpotifyRequests sr = SpotifyRequests();
    bool response = await sr.connectToSpotify();
    expect(response, false);
  });

  test("addItemToSpotifyPlaylist", () async {
    SpotifyRequests sr = SpotifyRequests();
    http.Response response =
        await sr.addItemToPlaylist("spotify:track:2cfhFcqpEoM65MNc5cVZse");
    expect(response is http.Response, true);
  });
}
