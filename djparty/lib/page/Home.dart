import 'dart:ui';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/Icons/spotify_icons.dart';
import 'package:djparty/entities/Entities.dart';
import 'package:djparty/main.dart';
import 'package:djparty/page/HomePage.dart';
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
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
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
  ZoomDrawerController drawerController;

  Home({super.key, required this.drawerController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  String myToken = "";
  Stream<QuerySnapshot>? parties;

  final RoundedLoadingButtonController partyController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController exitController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController shareController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController deleteController =
      RoundedLoadingButtonController();

  final key = GlobalKey();
  File? file;

  Future getData() async {
    final sp = context.read<SignInProvider>();
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
    partyController.reset();
    exitController.reset();
    shareController.reset();
    getData();
    super.initState();
  }

  streamParties() {
    bool expandFlag = false;
    final sp = context.read<SignInProvider>();
    final width = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: parties,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasData == false) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(158, 61, 219, 71),
              backgroundColor: Color.fromARGB(128, 52, 74, 61),
              strokeWidth: 10,
            ));
          }
          return snapshot.data.docs.length > 0
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var tmp = snapshot.data.docs[index]['startDate'];
                    return Padding(
                        padding: const EdgeInsets.all(5),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: width * 0.08,
                                          ),
                                          (snapshot.data.docs[index]['admin']
                                                      .toString() ==
                                                  sp.uid)
                                              ? Expanded(
                                                  child: AnimatedButton(
                                                    text: 'Delete',
                                                    pressEvent: () {
                                                      AwesomeDialog(
                                                          context: context,
                                                          dialogType: DialogType
                                                              .question,
                                                          animType:
                                                              AnimType.topSlide,
                                                          showCloseIcon: true,
                                                          title: "Warning",
                                                          desc:
                                                              "Are you sure to delete the party?",
                                                          btnOk:
                                                              RoundedLoadingButton(
                                                            controller:
                                                                exitController,
                                                            successColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    30,
                                                                    215,
                                                                    96,
                                                                    0.9),
                                                            width: width * 0.25,
                                                            height: 37,
                                                            elevation: 0,
                                                            borderRadius: 25,
                                                            color: const Color
                                                                    .fromRGBO(
                                                                30,
                                                                215,
                                                                96,
                                                                0.9),
                                                            onPressed: () {
                                                              handleExitPartyAdmin(
                                                                  snapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          'code']
                                                                      .toString());
                                                            },
                                                            child: Wrap(
                                                              children: const [
                                                                Center(
                                                                  child: Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          dismissOnTouchOutside:
                                                              true,
                                                          btnCancelOnPress: () => Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => Home(
                                                                      drawerController:
                                                                          widget
                                                                              .drawerController)))).show();
                                                    },
                                                    width: width * 0.25,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    color: const Color.fromRGBO(
                                                        30, 215, 96, 0.9),
                                                  ),
                                                )
                                              : Expanded(
                                                  child: AnimatedButton(
                                                      text: 'Exit',
                                                      pressEvent: () {
                                                        AwesomeDialog(
                                                            context: context,
                                                            dialogType:
                                                                DialogType
                                                                    .question,
                                                            animType: AnimType
                                                                .topSlide,
                                                            showCloseIcon: true,
                                                            title: "Warning",
                                                            desc:
                                                                "Are you sure to exit the party?",
                                                            btnOk:
                                                                RoundedLoadingButton(
                                                              controller:
                                                                  exitController,
                                                              successColor:
                                                                  const Color
                                                                          .fromRGBO(
                                                                      30,
                                                                      215,
                                                                      96,
                                                                      0.9),
                                                              width:
                                                                  width * 0.25,
                                                              height: 37,
                                                              elevation: 0,
                                                              borderRadius: 25,
                                                              color: const Color
                                                                      .fromRGBO(
                                                                  30,
                                                                  215,
                                                                  96,
                                                                  0.9),
                                                              onPressed: () {
                                                                handleExitNormalUser(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                        ['code']
                                                                    .toString());
                                                              },
                                                              child: Wrap(
                                                                children: const [
                                                                  Center(
                                                                    child: Text(
                                                                        "Exit",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w500)),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            btnCancelOnPress:
                                                                () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => Home(
                                                                          drawerController:
                                                                              widget.drawerController)));
                                                            });
                                                      }),
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
                                            successColor: const Color.fromRGBO(
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
                                                              FontWeight.w500)),
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
                                            successColor: const Color.fromRGBO(
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
                                                              FontWeight.w500)),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.08,
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
              : const Center(
                  child: CircularProgressIndicator(
                  color: const Color.fromRGBO(30, 215, 96, 0.9),
                  backgroundColor: Color.fromARGB(128, 52, 74, 61),
                  strokeWidth: 10,
                ));
        });
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(228, 53, 191, 101),
              secondary: const Color.fromARGB(255, 35, 34, 34))),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 35, 34, 34),
        appBar: AppBar(
          leading: InkWell(
              child: Icon(Icons.menu),
              onTap: (() => widget.drawerController.toggle!())),
          backgroundColor: const Color.fromARGB(255, 35, 34, 34),
          title: const Text(
            'DjParty',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                nextScreen(context, GeneratorScreen());
              },
              icon: const Icon(
                Icons.create,
              ),
            ),
            IconButton(
              onPressed: () {
                nextScreen(context, InsertCode());
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: () {
                nextScreen(context, const ScannerScreen());
              },
              icon: const Icon(
                Icons.qr_code,
              ),
            )
          ],
        ),
        body: Stack(children: <Widget>[
          streamParties(),
        ]),
      ),
    );
  }
  /*
      SizedBox(
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
                  backgroundColor: const Color.fromARGB(228, 53, 191, 101),
                  elevation: 0.1,
                  onPressed: () {
                    //Navigator.pushNamed(context, Home.routeName);
                  },
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                  )),
            ),
            SizedBox(
              width: size.width,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
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
    ));
  }*/

  handleAfterLogout() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      Navigator.pop(context);
    });
  }

  /*
  handleGeneratorScreen() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreen(context, GeneratorScreen());
    });
    
  }

  handleInsertScreen() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      nextScreen(context, const InsertCode());
    });
  }*/

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
          handlePassToLobby();
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

  handlePassToLobby() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreen(context, const SpotifyTabController());
    });
  }

  Future handleExitPartyAdmin(String code) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();

    await ip.checkInternetConnection();
    Future<List<dynamic>> list;

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
      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
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
                  fp.adminExitParty(sp.uid!, code).then((value) {
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
                }
                if (fp.getIsStarted()) {
                  exitController.reset();
                  showInSnackBar(context,
                      'Please, stop the party before deleting', Colors.red);
                  return;
                } else {
                  fp.getPartecipants(code).then((value) async {
                    print(value);
                    value.forEach((element) async {
                      String elem = element.toString();
                      await fp.checkUserExists(elem).then((value) {
                        if (fp.hasError == true) {
                          showInSnackBar(
                              context, sp.errorCode.toString(), Colors.red);
                          exitController.reset();
                        }
                        if (value == true) {
                          fp.userExitFromParty(elem, code).then((value) {
                            if (fp.hasError == true) {
                              showInSnackBar(
                                  context, sp.errorCode.toString(), Colors.red);
                              exitController.reset();
                            }

                            exitController.success();
                            Future.delayed(const Duration(milliseconds: 500));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home(
                                        drawerController:
                                            widget.drawerController)));
                            displayToastMessage(
                                context, 'Party Deleted', Colors.green);
                          });
                        }
                      });
                    });
                    await fp.deleteParty(code).then((value) {
                      if (fp.hasError == true) {
                        showInSnackBar(
                            context, sp.errorCode.toString(), Colors.red);
                        exitController.reset();
                        return;
                      }
                    });
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
      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
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
            await fp.userIsInTheParty(sp.uid.toString()).then((value) async {
              if (fp.hasError) {
                showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                exitController.reset();
                return;
              }
              await fp.userExitParty(sp.uid.toString(), code).then((value) {
                if (fp.hasError) {
                  showInSnackBar(context, sp.errorCode.toString(), Colors.red);
                  exitController.reset();
                  return;
                }
                exitController.success();
                Future.delayed(const Duration(milliseconds: 500));
                displayToastMessage(
                    context, 'You left the party', Colors.green);
                exitController.reset();
              });
            });
          });
        });
      });
    });
  }
}
