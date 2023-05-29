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

class GuestRankingNotStarted extends StatefulWidget {
  const GuestRankingNotStarted({super.key});

  @override
  State<GuestRankingNotStarted> createState() => _GuestRankingNotStarted();
}

class _GuestRankingNotStarted extends State<GuestRankingNotStarted> {
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
        ],
      ),
    );
  }
}

class GuestRankingStarted extends StatefulWidget {
  const GuestRankingStarted({super.key});

  @override
  State<GuestRankingStarted> createState() => _GuestRankingStarted();
}

class _GuestRankingStarted extends State<GuestRankingStarted> {
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
      child: Column(children: [
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
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.025,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: NetworkImage(
                                                          '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.022,
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.025,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.022,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
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
      ]),
    );
  }
}

class GuestRankingEnded extends StatefulWidget {
  const GuestRankingEnded({super.key});

  @override
  State<GuestRankingEnded> createState() => _GuestRankingEnded();
}

class _GuestRankingEnded extends State<GuestRankingEnded> {
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
      child: Column(children: [
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
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.025,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: NetworkImage(
                                                          '${currentUser.imageUrl}'),
                                                      maxRadius: height * 0.022,
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    maxRadius: height * 0.025,
                                                    child: CircleAvatar(
                                                        maxRadius:
                                                            height * 0.022,
                                                        backgroundColor: Color(
                                                            currentUser.image!),
                                                        child: Text(
                                                          currentUser
                                                              .username![0]
                                                              .toUpperCase(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
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
      ]),
    );
  }
}
