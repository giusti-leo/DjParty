import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/User.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'package:logger/logger.dart';

class AdminRankingNotStarted extends StatefulWidget {
  const AdminRankingNotStarted({super.key});

  @override
  State<AdminRankingNotStarted> createState() => _AdminRankingNotStarted();
}

class _AdminRankingNotStarted extends State<AdminRankingNotStarted> {
  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(height: height * 0.02),
          SizedBox(
            height: height * 0.58,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .collection('members')
                    .snapshots(),
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
                      ? ListView.builder(
                          itemBuilder: ((context, index) {
                            final user = snapshot.data.docs[index];
                            User currentUser = User.getTrackFromFirestore(user);
                            return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Card(
                                  elevation: 20,
                                  color:
                                      const Color.fromARGB(255, 215, 208, 208),
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
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: width * 0.02),
                                          SizedBox(
                                            width: width * 0.4,
                                            child: Row(children: [
                                              (currentUser.imageUrl != '')
                                                  ? CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                '${currentUser.imageUrl}'),
                                                        maxRadius:
                                                            height * 0.022,
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                          maxRadius:
                                                              height * 0.022,
                                                          backgroundColor:
                                                              Color(currentUser
                                                                  .image!),
                                                          child: Text(
                                                            currentUser
                                                                .username![0]
                                                                .toUpperCase(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 40,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ))),
                                              const Text(
                                                '   ',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                currentUser.username.toString(),
                                                style: const TextStyle(
                                                    color: Colors.black),
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
                                ));
                          }),
                          itemCount: snapshot.data.docs.length)
                      : const Text(
                          'Server problems',
                          style: TextStyle(color: Colors.white),
                        );
                }),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          SizedBox(
            height: 40,
            child: RoundedLoadingButton(
              onPressed: () {
                setState(() {
                  _handleStartParty(context);
                });
              },
              controller: partyController,
              successColor: mainGreen,
              width: width * 0.80,
              elevation: 0,
              borderRadius: 25,
              color: mainGreen,
              child: Wrap(
                children: const [
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

  Future _handleStartParty(BuildContext context) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      partyController.reset();
      return;
    }

    fr.checkPartyExists(code: fr.partyCode!).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        partyController.reset();
        return;
      }
      fr.getPartyDataFromFirestore(fr.partyCode!).then((value) {
        fr.saveDataToSharedPreferences().then((value) {
          fr.setPartyStarted(fr.partyCode!).then((value) {
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

class AdminRankingStarted extends StatefulWidget {
  const AdminRankingStarted({super.key});

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

  String partyID = '';

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();

    partyID = fr.partyCode!;
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
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(height: height * 0.02),
          SizedBox(
            height: height * 0.58,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .collection('members')
                    .snapshots(),
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
                      ? ListView.builder(
                          itemBuilder: ((context, index) {
                            final user = snapshot.data.docs[index];
                            User currentUser = User.getTrackFromFirestore(user);
                            return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Card(
                                  elevation: 20,
                                  color:
                                      const Color.fromARGB(255, 215, 208, 208),
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
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                '${currentUser.imageUrl}'),
                                                        maxRadius:
                                                            height * 0.022,
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                          maxRadius:
                                                              height * 0.022,
                                                          backgroundColor:
                                                              Color(currentUser
                                                                  .image!),
                                                          child: Text(
                                                            currentUser
                                                                .username![0]
                                                                .toUpperCase(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 40,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ))),
                                              const Text(
                                                '   ',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                currentUser.username.toString(),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ]),
                                          ),
                                          SizedBox(
                                            width: width * 0.4,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.05,
                                                  ),
                                                  Text(
                                                    ' Score: ${currentUser.points}',
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.05,
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
                                ));
                          }),
                          itemCount: snapshot.data.docs.length)
                      : const Text(
                          'Server problems',
                          style: TextStyle(color: Colors.white),
                        );
                }),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          SizedBox(
            height: 40,
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
                children: const [
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

  Future _adminEndParty(BuildContext context) async {
    final CollectionReference partyCollection =
        FirebaseFirestore.instance.collection("parties");

    await partyCollection
        .doc(partyID)
        .collection('Party')
        .doc('PartyStatus')
        .update({
      'isEnded': true,
    }).onError((error, stackTrace) {
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

class AdminRankingEnded extends StatefulWidget {
  const AdminRankingEnded({super.key});

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

  String partyID = '';

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();

    partyID = fr.partyCode!;
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
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.052,
          ),
          SizedBox(
            height: height * 0.63,
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('parties')
                    .doc(fr.partyCode)
                    .collection('members')
                    .orderBy('points')
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
                      ? ListView.builder(
                          itemBuilder: ((context, index) {
                            final user = snapshot.data.docs[index];
                            User currentUser = User.getTrackFromFirestore(user);
                            return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Card(
                                  elevation: 20,
                                  color:
                                      const Color.fromARGB(255, 215, 208, 208),
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
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                '${currentUser.imageUrl}'),
                                                        maxRadius:
                                                            height * 0.022,
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      maxRadius: height * 0.025,
                                                      child: CircleAvatar(
                                                          maxRadius:
                                                              height * 0.022,
                                                          backgroundColor:
                                                              Color(currentUser
                                                                  .image!),
                                                          child: Text(
                                                            currentUser
                                                                .username![0]
                                                                .toUpperCase(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 40,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ))),
                                              const Text(
                                                '   ',
                                                style: TextStyle(
                                                    color: Colors.black),
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
                      : const Text(
                          'Server problems',
                          style: TextStyle(color: Colors.white),
                        );
                }),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
