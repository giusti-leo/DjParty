import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/User.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:logger/logger.dart';

class AdminRankingNotStarted extends StatefulWidget {
  String code;
  FirebaseFirestore db;
  AdminRankingNotStarted({super.key, required this.code, required this.db});

  @override
  State<AdminRankingNotStarted> createState() => _AdminRankingNotStarted();
}

class _AdminRankingNotStarted extends State<AdminRankingNotStarted> {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Stream<QuerySnapshot>? ranking;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    fr.getRanking(code: widget.code).then((val) {
      setState(() {
        ranking = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .001),
          SizedBox(
              height: isMobile
                  ? MediaQuery.of(context).size.height * .5
                  : MediaQuery.of(context).size.height * .65,
              child: rankingBuilder(context)),
          SizedBox(height: MediaQuery.of(context).size.height * .001),
          SizedBox(
            width: MediaQuery.of(context).size.height * .3,
            height: MediaQuery.of(context).size.height * .05,
            child: RoundedLoadingButton(
              onPressed: () {
                setState(() {
                  _handleStartParty(context);
                });
              },
              controller: partyController,
              successColor: mainGreen,
              width: 50,
              elevation: 0,
              borderRadius: 25,
              color: mainGreen,
              child: Wrap(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    FontAwesomeIcons.music,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text("Start the Party",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget rankingBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('parties')
            .doc(widget.code)
            .collection('members')
            .orderBy('points', descending: true)
            .limit(50)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
              strokeWidth: 10,
            ));
          }
          return (snapshot.data.docs.length > 0)
              ? (isMobile)
                  ? ListView.builder(
                      itemBuilder: ((context, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: NotStartedRankingRow(currentUser));
                      }),
                      itemCount: snapshot.data.docs.length)
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4),
                      itemBuilder: (_, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Card(
                              elevation: 10,
                              color: const Color.fromARGB(255, 215, 208, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (currentUser.imageUrl != '')
                                            ? (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                            : (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )))
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ))),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                          currentUser.username.toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ));
                      },
                      itemCount: snapshot.data.docs.length)
              : const Text(
                  'Server problems',
                  style: TextStyle(color: Colors.white),
                );
        });
  }

  Future _handleStartParty(BuildContext context) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      partyController.reset();
      return;
    }

    fr.checkPartyExists(code: widget.code).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        partyController.reset();
        return;
      }
      fr.getPartyDataFromFirestore(widget.code).then((value) {
        fr.saveDataToSharedPreferences().then((value) {
          fr.setPartyStarted(widget.code).then((value) {
            if (sp.hasError == true) {
              displayToastMessage(context, sp.errorCode.toString(), alertColor);
              partyController.reset();
              return;
            }

            partyController.success();
          });
        });
      });
    });
  }
}

class NotStartedRankingRow extends StatelessWidget {
  final User currentUser;

  NotStartedRankingRow(this.currentUser, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Card(
      elevation: 20,
      color: const Color.fromARGB(255, 215, 208, 208),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.5,
                child: Row(children: [
                  SizedBox(width: width * 0.02),
                  (currentUser.imageUrl != '')
                      ? (height < width)
                          ? CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.02,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: CachedNetworkImageProvider(
                                    '${currentUser.imageUrl}'),
                                maxRadius: height * 0.018,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.02,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: CachedNetworkImageProvider(
                                    '${currentUser.imageUrl}'),
                                maxRadius: height * 0.018,
                              ),
                            )
                      : (height < width)
                          ? CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.02,
                              child: CircleAvatar(
                                  maxRadius: height * 0.018,
                                  backgroundColor: Color(currentUser.image!),
                                  child: Text(
                                    currentUser.username![0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontStyle: FontStyle.italic),
                                  )))
                          : CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: height * 0.02,
                              child: CircleAvatar(
                                  maxRadius: height * 0.018,
                                  backgroundColor: Color(currentUser.image!),
                                  child: Text(
                                    currentUser.username![0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontStyle: FontStyle.italic),
                                  ))),
                  const Text(
                    '   ',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    currentUser.username.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

class AdminRankingStarted extends StatefulWidget {
  String code;
  FirebaseFirestore db;

  AdminRankingStarted({super.key, required this.code, required this.db});

  @override
  State<AdminRankingStarted> createState() => _AdminRankingStarted();
}

class _AdminRankingStarted extends State<AdminRankingStarted> {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  bool isPaused = false;

  Stream<QuerySnapshot>? ranking;

  Future getData() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    fr.getRanking(code: widget.code).then((val) {
      setState(() {
        ranking = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(height: height * 0.05),
          SizedBox(
            height: height * 0.45,
            child: rankingBuilder(context),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.height * .3,
            height: MediaQuery.of(context).size.height * .05,
            child: RoundedLoadingButton(
              onPressed: () {
                showDataAlert(context);
              },
              controller: partyController,
              successColor: mainGreen,
              width: width * 0.80,
              elevation: 0,
              borderRadius: 25,
              color: mainGreen,
              child: Wrap(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    FontAwesomeIcons.music,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text("End the Party",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    width: 15,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget rankingBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('parties')
            .doc(widget.code)
            .collection('members')
            .orderBy('points', descending: true)
            .limit(50)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
              strokeWidth: 10,
            ));
          }
          return (snapshot.data.docs.length > 0)
              ? (isMobile)
                  ? ListView.builder(
                      itemBuilder: ((context, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Card(
                              elevation: 20,
                              color: const Color.fromARGB(255, 215, 208, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.5,
                                        child: Row(children: [
                                          SizedBox(width: width * 0.02),
                                          (currentUser.imageUrl != '')
                                              ? CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  maxRadius: height * 0.025,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            '${currentUser.imageUrl}'),
                                                    maxRadius: height * 0.022,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  maxRadius: height * 0.025,
                                                  child: CircleAvatar(
                                                      maxRadius: height * 0.022,
                                                      backgroundColor: Color(
                                                          currentUser.image!),
                                                      child: Text(
                                                        currentUser.username![0]
                                                            .toUpperCase(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 40,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ))),
                                          const Text(
                                            '   ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            currentUser.username.toString(),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ]),
                                      ),
                                      SizedBox(
                                        width: width * 0.2,
                                        child: Row(children: [
                                          SizedBox(
                                            width: width * 0.015,
                                          ),
                                          Text(
                                            ' Score: ${currentUser.points}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          // SizedBox(
                                          //   width: width * 0.015,
                                          // ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ));
                      }),
                      itemCount: snapshot.data.docs.length)
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4),
                      itemBuilder: (_, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Card(
                              elevation: 10,
                              color: const Color.fromARGB(255, 215, 208, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (currentUser.imageUrl != '')
                                            ? (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                            : (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )))
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ))),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                          currentUser.username.toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          ' Score:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                          '${currentUser.points}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ]),
                                ],
                              ),
                            ));
                      },
                      itemCount: snapshot.data.docs.length)
              : const Text(
                  'Server problems',
                  style: TextStyle(color: Colors.white),
                );
        });
  }

  Future _adminEndParty(BuildContext context) async {
    await widget.db
        .collection('parties')
        .doc(widget.code)
        .collection('Party')
        .doc('PartyStatus')
        .update({'isEnded': true, 'endTime': DateTime.now()}).onError(
            (error, stackTrace) {
      displayToastMessage(context, error.toString(), alertColor);
      return;
    });
    displayToastMessage(context, 'Party ended correctly', mainGreen);
  }

  void showDataAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            title: const Text(
              "Warning",
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 250,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Are you sure to end the party?",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _adminEndParty(context);

                          Navigator.of(context).pop();
                          pause();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: const Text(
                          "Yes",
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          partyController.reset();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: const Text(
                          "Ignore",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}

class StartedRankingRow extends StatelessWidget {
  final User currentUser;

  StartedRankingRow(this.currentUser, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Card(
      elevation: 20,
      color: const Color.fromARGB(255, 215, 208, 208),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.5,
                child: Row(children: [
                  SizedBox(width: width * 0.02),
                  (currentUser.imageUrl != '')
                      ? CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: height * 0.025,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: CachedNetworkImageProvider(
                                '${currentUser.imageUrl}'),
                            maxRadius: height * 0.022,
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: height * 0.025,
                          child: CircleAvatar(
                              maxRadius: height * 0.022,
                              backgroundColor: Color(currentUser.image!),
                              child: Text(
                                currentUser.username![0].toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 40,
                                    fontStyle: FontStyle.italic),
                              ))),
                  const Text(
                    '   ',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    currentUser.username.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ]),
              ),
              SizedBox(
                width: width * 0.2,
                child: Row(children: [
                  SizedBox(
                    width: width * 0.015,
                  ),
                  Text(
                    ' Score: ${currentUser.points}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  // SizedBox(
                  //   width: width * 0.015,
                  // ),
                ]),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

class AdminRankingEnded extends StatefulWidget {
  String code;
  FirebaseFirestore db;
  AdminRankingEnded({super.key, required this.code, required this.db});

  @override
  State<AdminRankingEnded> createState() => _AdminRankingEnded();
}

class _AdminRankingEnded extends State<AdminRankingEnded> {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  bool isPaused = false;

  Stream<QuerySnapshot>? ranking;

  Future getData() async {
    final FirebaseRequests fr = FirebaseRequests(db: widget.db);

    fr.getRanking(code: widget.code).then((val) {
      setState(() {
        ranking = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.052,
          ),
          SizedBox(height: height * 0.55, child: rankingBuilder(context)),
        ],
      ),
    );
  }

  Widget rankingBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('parties')
            .doc(widget.code)
            .collection('members')
            .orderBy('points', descending: true)
            .limit(50)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
              strokeWidth: 10,
            ));
          }
          return (snapshot.data.docs.length > 0)
              ? (isMobile)
                  ? ListView.builder(
                      itemBuilder: ((context, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Card(
                              elevation: 20,
                              color: const Color.fromARGB(255, 215, 208, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.5,
                                        child: Row(children: [
                                          SizedBox(width: width * 0.02),
                                          (currentUser.imageUrl != '')
                                              ? CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  maxRadius: height * 0.025,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            '${currentUser.imageUrl}'),
                                                    maxRadius: height * 0.022,
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  maxRadius: height * 0.025,
                                                  child: CircleAvatar(
                                                      maxRadius: height * 0.022,
                                                      backgroundColor: Color(
                                                          currentUser.image!),
                                                      child: Text(
                                                        currentUser.username![0]
                                                            .toUpperCase(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 40,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ))),
                                          const Text(
                                            '   ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            currentUser.username.toString(),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ]),
                                      ),
                                      SizedBox(
                                        width: width * 0.2,
                                        child: Row(children: [
                                          Text(
                                            ' Score: ${currentUser.points}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            width: width * 0.015,
                                          ),
                                        ]),
                                      ),
                                      SizedBox(
                                          width: width * 0.1,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${index + 1}°',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                SizedBox(
                                                  width: width * 0.05,
                                                ),
                                              ])),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ));
                      }),
                      itemCount: snapshot.data.docs.length)
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4),
                      itemBuilder: (_, index) {
                        final user = snapshot.data.docs[index];
                        User currentUser = User.getTrackFromFirestore(user);
                        return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Card(
                              elevation: 10,
                              color: const Color.fromARGB(255, 215, 208, 208),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (currentUser.imageUrl != '')
                                            ? (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.018,
                                                    ),
                                                  )
                                            : (height < width)
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )))
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.02,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.018,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 40,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ))),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                          currentUser.username.toString(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          ' Score:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                          '${currentUser.points}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ]),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              height: height * 0.1,
                                            ),
                                            Text(
                                              '${index + 1}°',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ]),
                                    ],
                                  )
                                ],
                              ),
                            ));
                      },
                      itemCount: snapshot.data.docs.length)
              : const Text(
                  'Server problems',
                  style: TextStyle(color: Colors.white),
                );
        });
  }
}
