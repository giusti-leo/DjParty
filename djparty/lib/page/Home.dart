import 'dart:ui';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:djparty/entities/Entities.dart';
import 'package:djparty/main.dart';
import 'package:djparty/page/InsertCode.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/PartyPage.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'package:djparty/page/SpotifyTabController.dart';
import 'package:djparty/page/spotifyPlayer.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:djparty/page/UserProfile.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

List parties = [];

class Home extends StatefulWidget {
  static String routeName = 'home';
  const Home({super.key});
  final bool _connected = false;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<Widget> itemsData = [];
  bool _loading = false;
  bool _connected = false;
  String myToken = "";
  Stream<QuerySnapshot>? parties;

  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();

  final RoundedLoadingButtonController exitController =
      RoundedLoadingButtonController();

  final RoundedLoadingButtonController shareController =
      RoundedLoadingButtonController();

  final key = GlobalKey();
  File? file;

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

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    sp.getDataFromSharedPreferences();

    fr.getParties(uid: uid).then((val) {
      setState(() {
        parties = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  streamParties() {
    bool expandFlag = false;
    final sp = context.read<SignInProvider>();
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: const Color.fromARGB(228, 53, 191, 101))),
        home: StreamBuilder(
          stream: parties,
          builder: (context, AsyncSnapshot snapshot) {
            return snapshot.hasData && snapshot.data.docs.length > 0
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var tmp = snapshot.data.docs[index]['startDate'];
                      return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Card(
                            color: const Color.fromARGB(255, 215, 208, 208),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ExpansionTile(
                              trailing:
                                  (snapshot.data.docs[index]['admin'] == uid)
                                      ? const Icon(Icons.emoji_people)
                                      : const Icon(Icons.people),
                              title: Text(
                                snapshot.data.docs[index]['PartyName'],
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              subtitle: Text(
                                "${tmp.toDate().day} / ${tmp.toDate().month} / ${tmp.toDate().year}",
                                style: const TextStyle(
                                    color: Colors.blueGrey, fontSize: 14),
                              ),
                              children: [
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Party Code : ' +
                                              snapshot.data.docs[index]['code'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Row(
                                          children: const [
                                            Divider(height: 32),
                                          ],
                                        ),
                                        /*
                                    Center(
                                      child: RepaintBoundary(
                                        key: Key(index),
                                        child: QrImage(
                                          data: snapshot.data.docs[index]
                                              ['code'],
                                          size: 200,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),*/
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            (snapshot.data.docs[index]['admin']
                                                        .toString() ==
                                                    sp.uid)
                                                ? RoundedLoadingButton(
                                                    onPressed: () {
                                                      handleExitPartyAdmin(
                                                          snapshot
                                                              .data
                                                              .docs[index]
                                                                  ['code']
                                                              .toString());
                                                    },
                                                    controller: exitController,
                                                    successColor:
                                                        const Color.fromRGBO(
                                                            30, 215, 96, 0.9),
                                                    width: width * 0.25,
                                                    elevation: 0,
                                                    borderRadius: 25,
                                                    color: const Color.fromRGBO(
                                                        30, 215, 96, 0.9),
                                                    child: Wrap(
                                                      children: const [
                                                        Center(
                                                          child: Text(
                                                              "Delete Party",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : RoundedLoadingButton(
                                                    onPressed: () {
                                                      handleExitNormalUser(
                                                          snapshot
                                                              .data
                                                              .docs[index]
                                                                  ['code']
                                                              .toString());
                                                    },
                                                    controller: partyController,
                                                    successColor:
                                                        const Color.fromRGBO(
                                                            30, 215, 96, 0.9),
                                                    width: width * 0.25,
                                                    elevation: 0,
                                                    borderRadius: 25,
                                                    color: const Color.fromRGBO(
                                                        30, 215, 96, 0.9),
                                                    child: Wrap(
                                                      children: const [
                                                        Center(
                                                          child: Text(
                                                              "Remove Party",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                            SizedBox(
                                              width: width * .08,
                                            ),
                                            RoundedLoadingButton(
                                              onPressed: () async {
                                                handleShare(
                                                  snapshot
                                                      .data.docs[index]['code']
                                                      .toString(),
                                                );
                                              },
                                              controller: shareController,
                                              successColor:
                                                  const Color.fromRGBO(
                                                      30, 215, 96, 0.9),
                                              width: width * 0.25,
                                              elevation: 0,
                                              borderRadius: 25,
                                              color: const Color.fromRGBO(
                                                  30, 215, 96, 0.9),
                                              child: Wrap(
                                                children: const [
                                                  Center(
                                                    child: Text("Share",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .08,
                                            ),
                                            RoundedLoadingButton(
                                              onPressed: () {
                                                handleJoinLobby(snapshot
                                                    .data.docs[index]['code']
                                                    .toString());
                                              },
                                              controller: partyController,
                                              successColor:
                                                  const Color.fromRGBO(
                                                      30, 215, 96, 0.9),
                                              width: width * 0.25,
                                              elevation: 0,
                                              borderRadius: 25,
                                              color: const Color.fromRGBO(
                                                  30, 215, 96, 0.9),
                                              child: Wrap(
                                                children: const [
                                                  Center(
                                                    child: Text("Join Party",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: const [
                                            Divider(height: 16),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                              /*
                                  onLongPress: (() async {
                                    if (snapshot.data.docs[index]['admin'] ==
                                        uid) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: TextButton(
                                                  child: Text(
                                                    'Delete ' +
                                                        snapshot.data
                                                                .docs[index]
                                                                .data()[
                                                            'PartyName'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () {
                                                    //you are the admin
                                                    handleExitPartyAdmin(
                                                        snapshot
                                                            .data.docs[index]
                                                            .data()['code']
                                                            .toString());

                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: TextButton(
                                                  child: Text(
                                                    'Exit from ' +
                                                        snapshot.data
                                                                .docs[index]
                                                            ['PartyName'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () {
                                                    // exit from a party
                                                    // you are not the admin

                                                    handleExitNormalUser(
                                                        snapshot.data
                                                            .docs[index]['code']
                                                            .toString());
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ));
                                    }
                                  }),*/
                              onExpansionChanged: (bool expdandFlag) {
                                setState(() {
                                  expandFlag = !expandFlag;
                                });
                                /*Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PartyPage(
                                      code: snapshot.data.docs[index]['code']
                                          .toString(),
                                      name: snapshot
                                          .data.docs[index]['PartyName']
                                          .toString(),
                                    )));*/
                              },
                            ),
                          ));
                    })
                : Container(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      "No party yet",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  );
          },
        ));
  }

/*  Future handleEnterInLobby(String code) async {
    connectToSpotify();
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      partyController.reset();
      return;
    }

    fp.checkPartyExists(code: code).then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        partyController.reset();
        return;
      }
      if (value == true) {
        fp.isPartyStarted().then((value) {
          if (sp.hasError == true) {
            showInSnackBar(context, sp.errorCode.toString(), Colors.red);
            partyController.reset();
            return;
          }

          fp.setPartyStarted(code).then((value) {
            if (sp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              partyController.reset();
              return;
            }
            fp.getPartyDataFromFirestore(code).then((value) {
              if (sp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                partyController.reset();
                return;
              }
              fp.saveDataToSharedPreferences().then((value) {
                partyController.success();
                handlePassToLobby(code: code);
              });
            });
          });
        });
      }
    });
  }
  
  */

  Widget qrImage(String string, GlobalKey key) {
    return RepaintBoundary(
      key: key,
      child: QrImage(
        data: string,
        size: 200,
        backgroundColor: Colors.white,
      ),
    );
  }

  Future handleShare(String string) async {
    try {
      var image = await QrPainter(
        data: string,
        version: 1,
        gapless: false,
        color: const Color(0x00000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImage(300);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final appDir = await getApplicationDocumentsDirectory();
      var datetime = DateTime.now();
      file = await File('${appDir.path}/$datetime.png').create();
      await file?.writeAsBytes(pngBytes);

      await Share.shareFiles(
        [file!.path],
        mimeTypes: ["image/png"],
        text: "Scan this Qr-Code to join my SpotiParty!" +
            " Or insert this code: $string",
      );
      shareController.success();

      Future.delayed(const Duration(milliseconds: 1000));
      shareController.reset();
    } catch (e) {
      showInSnackBar(context, e.toString(), Colors.red);
      shareController.reset();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final sp = context.watch<SignInProvider>();

    final ip = context.watch<InternetProvider>();
    final fr = context.watch<FirebaseRequests>();

    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromARGB(159, 46, 46, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(228, 53, 191, 101),
        title: const Text(
          'Home',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
            decoration: const BoxDecoration(
              color: const Color.fromARGB(228, 53, 191, 101),
            ),
            child: sp.uid == null
                ? const Center(
                    child: Text(
                      'No username',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                : buildDrawer(sp)),
        ListTile(
          leading: const Icon(
            Icons.home,
            color: Colors.black,
          ),
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black),
            selectionColor: Colors.black,
          ),
          onTap: () {
            nextScreen(context, UserProfile());
          },
        ),
        ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: const Text(
              'Logout',
              selectionColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              {
                sp.userSignOut();
                handleAfterLogout();
              }
            }),
        StreamBuilder<ConnectionStatus>(
          stream: SpotifySdk.subscribeConnectionStatus(),
          builder: (context, snapshot) {
            _connected = false;
            var data = snapshot.data;
            if (data != null) {
              _connected = data.connected;
            }
            return Column(children: [
              ListTile(
                leading: const Icon(
                  Spotify.spotify,
                  color: Colors.black,
                ),
                title: const Text(
                  'Connect to Spotify',
                  style: TextStyle(color: Colors.black),
                  selectionColor: Colors.black,
                ),
                onTap: (connectToSpotify),
              ),
              ListTile(
                leading: const Icon(
                  Spotify.spotify,
                  color: Colors.black,
                ),
                title: const Text(
                  'Get Token',
                  style: TextStyle(color: Colors.black),
                  selectionColor: Colors.black,
                ),
                onTap: (getAuthToken),
              )
            ]);
          },
        ),
      ])),
      body: Stack(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          streamParties(),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: 80,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: BNBCustomPainter(),
                    size: Size(size.width, 80),
                  ),
                  Center(
                    heightFactor: 0.6,
                    child: FloatingActionButton(
                        backgroundColor:
                            const Color.fromARGB(228, 53, 191, 101),
                        elevation: 0.1,
                        onPressed: () {
                          //Navigator.pushNamed(context, Home.routeName);
                        },
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                        )),
                  ),
                  Container(
                    width: size.width,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              //                            Navigator.pushNamed(
                              //                          context, GeneratorScreen.routeName);
                              //                        nextScreen(context, GeneratorScreen());
                              handleGeneratorScreen();
                            },
                            child: const Text(
                              'Create a party',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                        Container(
                          width: size.width * 0.15,
                        ),
                        TextButton(
                            onPressed: () {
                              nextScreen(context, const InsertCode());
                            },
                            child: const Text(
                              'Join a party',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  handleAfterLogout() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const Login());
    });
  }

  handleAfterUserProfile() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreen(context, UserProfile());
    });
  }

  handleGeneratorScreen() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreen(context, GeneratorScreen());
    });
  }

  Future handleJoinLobby(String code) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      partyController.reset();
      return;
    }

    fp.checkPartyExists(code: code).then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        partyController.reset();
        return;
      }
      //if (value == true) {
      // fp.isPartyStarted().then((value) {
      //   if (sp.hasError == true) {
      //     showInSnackBar(context, sp.errorCode.toString(), Colors.red);
      //     partyController.reset();
      //     return;
      //   }

      //   if (value == true) {
      fp.getPartyDataFromFirestore(code).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          partyController.reset();
          return;
        }
        fp.saveDataToSharedPreferences().then((value) {
          partyController.success();
          handlePassToLobby(code: code);
        });
        //});
        //});
      });
    });
    // else {
    //     displayToastMessage(
    //         context, 'Wait the Admin starts the party', Colors.red);
    // }

    //       fp.setPartyStarted(code).then((value) {
    //         if (sp.hasError == true) {
    //           showInSnackBar(context, sp.errorCode.toString(), Colors.red);
    //           partyController.reset();
    //           return;
    //         }
    //         fp.getPartyDataFromFirestore(code).then((value) {
    //           if (sp.hasError == true) {
    //             showInSnackBar(context, sp.errorCode.toString(), Colors.red);
    //             partyController.reset();
    //             return;
    //           }
    //           fp.saveDataToSharedPreferences().then((value) {
    //             partyController.success();
    //             handlePassToLobby();
    //           });
    //         });
    //       });
    //     });
    //   }
    // });
  }

  handlePassToLobby({required String code}) {
    connectToSpotify();
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreen(context, SpotifyTabController(code: code));
    });
    print('1');
  }

  Future handleExitPartyAdmin(String code) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      exitController.reset();

      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        exitController.reset();

        return;
      }

      if (value == false) {
        showInSnackBar(context, 'User Does Not Exist', Colors.red);
        exitController.reset();

        return;
      }

      await sp.getUserDataFromFirestore(sp.uid).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          exitController.reset();

          return;
        }

        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: code).then((value) async {
            if (fp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              exitController.reset();
              return;
            }
            if (value == false) {
              showInSnackBar(context, 'Party Does Not Exist', Colors.red);
              exitController.reset();

              return;
            }

            await fp.getPartyDataFromFirestore(code).then((value) {
              if (fp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                exitController.reset();

                return;
              }

              fp.saveDataToSharedPreferences().then((value) {
                if (fp.getIsEnded()) {
                  fp.exit(sp.uid!).then((value) {
                    if (sp.hasError == true) {
                      showInSnackBar(
                          context, sp.errorCode.toString(), Colors.red);
                      exitController.reset();

                      return;
                    }

                    fp.remove(sp.uid).then((value) {
                      if (sp.hasError == true) {
                        showInSnackBar(
                            context, sp.errorCode.toString(), Colors.red);
                        exitController.reset();

                        return;
                      }
                      exitController.success();
                      Future.delayed(const Duration(milliseconds: 500));
                      displayToastMessage(context,
                          'You are no longer part of the party', Colors.green);
                      return;
                    });
                  });
                }

                if (fp.getIsStarted()) {
                  exitController.reset();

                  showInSnackBar(context,
                      'Please, stop the party before deleting', Colors.red);
                  return;
                } else {
                  fp.delete(sp.uid!).then((value) {
                    if (fp.hasError == true) {
                      showInSnackBar(
                          context, sp.errorCode.toString(), Colors.red);
                      exitController.reset();
                    }
                    exitController.success();

                    Future.delayed(const Duration(milliseconds: 500));
                    displayToastMessage(context, 'Party Deleted', Colors.green);
                    exitController.reset();
                  });
                }
              });
            });
          });
        });
      });
    });
  }

  Future handleExitNormalUser(String code) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      exitController.reset();

      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        exitController.reset();

        return;
      }

      await sp.getUserDataFromFirestore(sp.uid).then((value) {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          exitController.reset();

          return;
        }

        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: code).then((value) async {
            if (fp.hasError == true) {
              showInSnackBar(context, sp.errorCode.toString(), Colors.red);
              exitController.reset();

              return;
            }

            await fp.getPartyDataFromFirestore(code).then((value) {
              if (fp.hasError == true) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                exitController.reset();

                return;
              }

              fp.saveDataToSharedPreferences().then((value) {
                fp.exit(sp.uid!).then((value) {
                  if (sp.hasError == true) {
                    showInSnackBar(
                        context, sp.errorCode.toString(), Colors.red);
                    exitController.reset();

                    return;
                  }
                  fp.remove(sp.uid).then((value) {
                    if (sp.hasError == true) {
                      showInSnackBar(
                          context, sp.errorCode.toString(), Colors.red);
                      exitController.reset();

                      return;
                    }
                    exitController.success();
                    Future.delayed(const Duration(milliseconds: 500));
                    displayToastMessage(context,
                        'You are no longer part of the party', Colors.green);
                    exitController.reset();
                  });
                });
              });
            });
          });
        });
      });
    });

    // check if exist
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
    myToken = '$authenticationToken';
    print(myToken);
    return authenticationToken;
  }

  Future<void> connectToSpotify() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: 'a502045e3c4b47d6b9bcfded418afd32',
          redirectUrl: 'test-1-login://callback');
      if (result) {
        _connected = true;
      } else {
        _connected = false;
      }
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
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

  Widget buildDrawer(SignInProvider sp) => Column(
        children: [
          (sp.imageUrl != '')
              ? ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 40,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage("${sp.imageUrl}"),
                      radius: 50,
                    ),
                  ),
                )
              : ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      maxRadius: 40,
                      child: CircleAvatar(
                          backgroundColor: Color(sp.image!),
                          child: Text(
                            sp.init.toString().toUpperCase(),
                            style: TextStyle(
                              color: Color(sp.initColor!),
                              fontSize: 20,
                            ),
                          )))),
          ListTile(
            leading: Text(
              sp.name!.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          )
        ],
      );
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = const Color.fromARGB(228, 53, 191, 101)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
