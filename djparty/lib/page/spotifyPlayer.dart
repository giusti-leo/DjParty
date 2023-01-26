import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:djparty/Icons/SizedIconButton.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/page/PartyPlaylist.dart';
import 'package:djparty/page/Home.dart';

class SpotifyPlayer extends StatefulWidget {
  static String routeName = 'SpotifyPlayer';
  const SpotifyPlayer({Key? key}) : super(key: key);

  @override
  _SpotifyPlayerState createState() => _SpotifyPlayerState();
}

class _SpotifyPlayerState extends State<SpotifyPlayer> {
  dynamic isPaused = true;
  double votingIndex = 0;
  bool _loading = false;
  bool _connected = true;

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

  late ImageUri? currentTrackImageUri;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = false;
          var data = snapshot.data;
          if (data != null) {
            _connected = data.connected;
          }
          return Scaffold(
            backgroundColor: Color.fromARGB(159, 46, 46, 46),
            appBar: AppBar(
              backgroundColor: Color.fromARGB(228, 53, 191, 101),
              title: const Text(
                'Dj Party',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              actions: [
                _connected
                    ? IconButton(
                        onPressed: disconnect,
                        icon: const Icon(Icons.exit_to_app),
                      )
                    : Container()
              ],
            ),
            body: _playerWidget(context),
            bottomNavigationBar: _buildBottomBar(context),
          );
        },
      ),
    );
  }

  Widget _playerWidget(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;
        var playerPosition = double.parse('${playerState?.playbackPosition}');
        var trackDuration = double.parse('${track?.duration}');
        double _value = 10.0;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }
        if (playerState.isPaused == true) {
          isPaused = true;
        } else {
          isPaused = false;
        }

        return Stack(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListView(padding: const EdgeInsets.all(8), children: [
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                height: 250,
                child: spotifyImageWidget(track.imageUri),
              ),
              const SizedBox(height: 20),
              _PlayPauseWidget(),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${track.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${track.artist.name}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                  ),
                ),
              ]),
              const SizedBox(
                height: 20,
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildPlayerContextWidget(),
                //_skiptoIndexWidget(),
                // Slider(
                //   value: votingIndex,
                //   max: 10,
                //   divisions: 5,
                //   label: votingIndex.round().toString(),
                //   onChanged: (double value) {
                //     setState(() {
                //       votingIndex = value;
                //     });
                //   },
                // ),
              ]),

              // Text(
              //   '${track.album.name}',
              //   style: TextStyle(
              //     color: Colors.grey,
              //     fontSize: 13,
              //   ),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Playback speed: ${playerState.playbackSpeed}'),
              //     Text(
              //         'Progress: ${playerState.playbackPosition}ms/${track.duration}ms'),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Paused: ${playerState.isPaused}'),
              //     Text('Shuffling: ${playerState.playbackOptions.isShuffling}'),
              //   ],
              // ),
              // Text('RepeatMode: ${playerState.playbackOptions.repeatMode}'),
              // Text('Image URI: ${track.imageUri.raw}'),
              // Text('Is episode? ${track.isEpisode}'),
              // Text('Is podcast? ${track.isPodcast}'),
              // _connected
              //     ? spotifyImageWidget(track.imageUri)
              //     : const Text('Connect to see an image...'),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const Divider(),
              //     const Text(
              //       'Set Shuffle and Repeat',
              //       style: TextStyle(fontSize: 16),
              //     ),
              //     Row(
              //       children: [
              //         const Text(
              //           'Repeat Mode:',
              //         ),
              //         DropdownButton<RepeatMode>(
              //           value: RepeatMode
              //               .values[playerState.playbackOptions.repeatMode.index],
              //           items: const [
              //             DropdownMenuItem(
              //               value: RepeatMode.off,
              //               child: Text('off'),
              //             ),
              //             DropdownMenuItem(
              //               value: RepeatMode.track,
              //               child: Text('track'),
              //             ),
              //             DropdownMenuItem(
              //               value: RepeatMode.context,
              //               child: Text('context'),
              //             ),
              //           ],
              //           onChanged: (repeatMode) => setRepeatMode(repeatMode!),
              //         ),
              //       ],
              //     ),
              //     Row(
              //       children: [
              //         const Text('Set shuffle: '),
              //         Switch.adaptive(
              //           value: playerState.playbackOptions.isShuffling,
              //           onChanged: (bool shuffle) => setShuffle(
              //             shuffle,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ])
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      color: Color.fromARGB(255, 45, 44, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, SearchItemScreen.routeName);
                  }),
              SizedIconButton(
                  width: 50,
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchItemScreen()));
                  }),
              SizedIconButton(
                width: 50,
                icon: Icon(Icons.playlist_play_rounded, color: Colors.white),
                onPressed: (() {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => PartyPlaylist()));
                }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _PlayPauseWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
            color: const Color.fromRGBO(30, 215, 96, 0.9),
          ),
          onPressed: skipPrevious,
        ),
        isPaused
            ? IconButton(
                iconSize: 50,
                icon: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
                ),
                onPressed: (resume))
            : IconButton(
                iconSize: 50,
                icon: const Icon(
                  Icons.pause_circle_filled_rounded,
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
                ),
                onPressed: (pause)),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: const Color.fromRGBO(30, 215, 96, 0.9),
          ),
          onPressed: skipNext,
        ),
      ],
    );
  }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'From: ${playerContext.title} (${playerContext.type})',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 50,
            ),
            // ElevatedButton(
            //     onPressed: (() => SpotifySdk.skipToIndex(
            //         spotifyUri: '${playerContext.uri}',
            //         trackIndex: votingIndex.toInt())),
            //     child: const Text('skip to voted'))
          ],
        );
      },
    );
  }

  // Widget _skiptoIndexWidget() {
  //   return StreamBuilder<PlayerContext>(
  //     stream: SpotifySdk.subscribePlayerContext(),
  //     initialData: PlayerContext('', '', '', ''),
  //     builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
  //       var playerContext2 = snapshot.data;
  //       if (playerContext2 == null) {
  //         return const Center(
  //           child: Text('Not connected'),
  //         );
  //       }

  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           ElevatedButton(
  //               onPressed: (() => SpotifySdk.skipToIndex(
  //                   spotifyUri: '${playerContext2.uri}',
  //                   trackIndex: votingIndex.toInt())),
  //               child: Text('skip to voted'))
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            setStatus(snapshot.error.toString());
            return SizedBox(
              width: ImageDimension.small.value.toDouble(),
              height: ImageDimension.small.value.toDouble(),
              child: const Center(child: Text('Error getting image')),
            );
          } else {
            return SizedBox(
              width: ImageDimension.small.value.toDouble(),
              height: ImageDimension.small.value.toDouble(),
              child: const Center(child: Text('Getting image...')),
            );
          }
        });
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    isPaused = true;
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    isPaused = false;
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}
