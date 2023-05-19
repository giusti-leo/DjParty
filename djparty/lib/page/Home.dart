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

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);
  Color alertColor = Colors.red;

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
    final heigth = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: parties,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.docs == null ||
              snapshot.data.docs.length == 0) {
            return Center(
                child: RichText(
              text: TextSpan(
                text: 'Hello ',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                      text: '${sp.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const TextSpan(
                      text: '! Create or join a party',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.white)),
                ],
              ),
            ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: mainGreen,
              backgroundColor: backGround,
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
                              "${tmp.toDate().day}/${tmp.toDate().month}/${tmp.toDate().year}",
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 12),
                            ),
                            children: [
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Party Code : ${snapshot.data.docs[index]['code']}',
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
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          RoundedLoadingButton(
                                            controller: exitController,
                                            successColor: mainGreen,
                                            color: mainGreen,
                                            onPressed: () {
                                              exitController.reset();
                                              if (snapshot.data.docs[index]
                                                      ['admin'] ==
                                                  sp.uid) {
                                                showAdminAlert(
                                                    context,
                                                    snapshot.data.docs[index]
                                                        ['code']);
                                              } else {
                                                showNormalUserAlert(
                                                    context,
                                                    snapshot.data.docs[index]
                                                        ['code']);
                                              }
                                            },
                                            width: width * 0.22,
                                            elevation: 0,
                                            borderRadius: 25,
                                            child: Wrap(
                                              children: const [
                                                Center(
                                                  child: Text("Exit",
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
                                            onPressed: () async {
                                              handleShare(
                                                snapshot
                                                    .data.docs[index]['code']
                                                    .toString(),
                                              );
                                            },
                                            controller: shareController,
                                            successColor: mainGreen,
                                            width: width * 0.22,
                                            elevation: 0,
                                            borderRadius: 25,
                                            color: mainGreen,
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
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: width * 0.08,
                                              )
                                            ],
                                          ),
                                          RoundedLoadingButton(
                                            onPressed: () {
                                              handleJoinLobby(snapshot
                                                  .data.docs[index]['code']
                                                  .toString());
                                            },
                                            controller: partyController,
                                            successColor: mainGreen,
                                            width: width * 0.22,
                                            elevation: 0,
                                            borderRadius: 25,
                                            color: mainGreen,
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
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: const [
                                          Divider(height: 32),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                            onExpansionChanged: (bool expdandFlag) {
                              setState(() {
                                expandFlag = !expandFlag;
                              });
                            },
                          ),
                        ));
                  })
              : Center(
                  child: CircularProgressIndicator(
                  color: mainGreen,
                  backgroundColor: backGround,
                  strokeWidth: 10,
                ));
        });
  }

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
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(primary: mainGreen, secondary: backGround)),
      home: Scaffold(
        backgroundColor: backGround,
        appBar: AppBar(
          backgroundColor: backGround,
          leading: InkWell(
              child: Icon(Icons.menu),
              onTap: (() => widget.drawerController.toggle!())),
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
                Icons.add_box_outlined,
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
        body: Stack(
          children: <Widget>[
            streamParties(),
          ],
        ),
      ),
    );
  }

  handleAfterLogout() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      Navigator.pop(context);
    });
  }

  void showNormalUserAlert(BuildContext context, String party) {
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
            content: Container(
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
                        "You can exit and join back whenever you want. Are you sure to exit the party?",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          handleExitNormalUser(party);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: const Text(
                          "Exit",
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

  void showAdminAlert(BuildContext context, String party) {
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
            content: Container(
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
                        "You are the admin of the party. Are you sure to definitely delete the party?",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          handleExitPartyAdmin(party);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          // fixedSize: Size(250, 50),
                        ),
                        child: const Text(
                          "Delete",
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

  Future handleJoinLobby(String code) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fp = context.read<FirebaseRequests>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      partyController.reset();
      return;
    }

    fp.checkPartyExists(code: code).then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        partyController.reset();
        return;
      }
      fp.getPartyDataFromFirestore(code).then((value) {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          partyController.reset();
          return;
        }
        fp.saveDataToSharedPreferences().then((value) {
          partyController.success();
          handlePassToLobby();
        });
      });
    });
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
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      exitController.reset();
      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        exitController.reset();
        return;
      }
      if (value == false) {
        displayToastMessage(context, 'User Does Not Exist', alertColor);
        exitController.reset();
        return;
      }
      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          exitController.reset();
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: code).then((value) async {
            if (fp.hasError == true) {
              displayToastMessage(context, sp.errorCode.toString(), alertColor);
              exitController.reset();
              return;
            }
            if (value == false) {
              displayToastMessage(context, 'Party Does Not Exist', alertColor);
              exitController.reset();
              return;
            }
            await fp.getPartyDataFromFirestore(code).then((value) {
              if (fp.hasError == true) {
                displayToastMessage(
                    context, sp.errorCode.toString(), alertColor);
                exitController.reset();
                return;
              }
              fp.saveDataToSharedPreferences().then((value) {
                if (fp.isEnded!) {
                  fp.adminExitParty(sp.uid!, code).then((value) {
                    if (sp.hasError == true) {
                      displayToastMessage(
                          context, sp.errorCode.toString(), alertColor);
                      exitController.reset();
                      return;
                    }

                    exitController.success();
                    Future.delayed(const Duration(milliseconds: 500));
                    displayToastMessage(context,
                        'You are no longer part of the party', mainGreen);
                    return;
                  });
                }
                if (fp.isStarted! & !fp.isEnded!) {
                  exitController.reset();
                  displayToastMessage(context,
                      'Please, stop the party before deleting', alertColor);
                  return;
                } else {
                  fp.adminExitParty(sp.uid!, code).then((value) {
                    if (sp.hasError == true) {
                      displayToastMessage(
                          context, sp.errorCode.toString(), alertColor);
                      exitController.reset();
                      return;
                    }

                    exitController.success();
                    Future.delayed(const Duration(milliseconds: 500));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home(
                                drawerController: widget.drawerController)));
                    displayToastMessage(context, 'Party Deleted', mainGreen);
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
      displayToastMessage(
          context, "Check your Internet connection", alertColor);
      exitController.reset();
      return;
    }

    await sp.checkUserExists().then((value) async {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), alertColor);
        exitController.reset();
        return;
      }
      await sp.getUserDataFromFirestore(sp.uid!).then((value) {
        if (sp.hasError == true) {
          displayToastMessage(context, sp.errorCode.toString(), alertColor);
          exitController.reset();
          return;
        }
        sp.saveDataToSharedPreferences().then((value) async {
          await fp.checkPartyExists(code: code).then((value) async {
            if (fp.hasError == true) {
              displayToastMessage(context, sp.errorCode.toString(), alertColor);
              exitController.reset();
              return;
            }
            await fp.userIsInTheParty(sp.uid.toString()).then((value) async {
              if (fp.hasError) {
                displayToastMessage(
                    context, sp.errorCode.toString(), alertColor);
                exitController.reset();
                return;
              }
              await fp.userExitParty(sp.uid.toString(), code).then((value) {
                if (fp.hasError) {
                  displayToastMessage(
                      context, sp.errorCode.toString(), alertColor);
                  exitController.reset();
                  return;
                }
                exitController.success();
                Future.delayed(const Duration(milliseconds: 500));
                displayToastMessage(context, 'You left the party', mainGreen);
                exitController.reset();
              });
            });
          });
        });
      });
    });
  }
}
