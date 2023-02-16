// import 'dart:io';
// import 'dart:ui';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:djparty/page/Home.dart';
// import 'package:djparty/services/FirebaseRequests.dart';
// import 'package:djparty/services/InternetProvider.dart';
// import 'package:djparty/services/SignInProvider.dart';
// import 'package:djparty/utils/nextScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:rounded_loading_button/rounded_loading_button.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:djparty/page/spotifyPlayer.dart';

// class PartyPage extends StatefulWidget {
//   final String code, name;

//   const PartyPage({Key? key, required this.code, required this.name})
//       : super(key: key);

//   @override
//   State<PartyPage> createState() => _PartyPageState();
// }

// class _PartyPageState extends State<PartyPage> {
//   final key = GlobalKey();
//   File? file;
//   bool _expanded = false;
//   String uid = FirebaseAuth.instance.currentUser!.uid;
//   String text = '';

//   bool _isLoading = false;

//   final RoundedLoadingButtonController partyController =
//       RoundedLoadingButtonController();

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   @override
//   void on() {}

//   dataLoadFunction() async {
//     setState(() {
//       _isLoading = true; // your loader has started to load
//     });

//     // fetch you data over here
//     getData();

//     setState(() {
//       _isLoading = false; // your loder will stop to finish after the data fetch
//     });
//   }

//   Future getData() async {
//     final sp = context.read<SignInProvider>();
//     final ip = context.read<InternetProvider>();
//     final fr = context.read<FirebaseRequests>();

//     await sp.getDataFromSharedPreferences();

//     await fr.getPartyDataFromFirestore(widget.code).then((value) {
//       if (sp.hasError == true) {
//         showInSnackBar(context, sp.errorCode.toString(), Colors.red);
//         return;
//       } else {
//         fr.saveDataToSharedPreferences();
//       }
//     });
//   }

//   void handleText(
//       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
//     if ((snapshot.data!.get('#partecipant') > 1)) {
//       text =
//           'For the moment there are ${snapshot.data!.get('#partecipant')} partecipants';
//     } else {
//       text = "Why don't you invite someone to your party?";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       return Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
//             title: const Text(
//               'Dj Party',
//               style: TextStyle(color: Colors.black),
//             ),
//             centerTitle: true,
//           ),
//           body: Stack(children: <Widget>[
//             StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection('parties')
//                     .doc(widget.code)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(
//                       child: Text('The party has been deleted by the admin'),
//                     );
//                   } else {
//                     handleText(snapshot);
//                     return Column(children: [
//                       Positioned(
//                         top: constraints.minHeight * .4,
//                         left: constraints.minWidth * .2,
//                         child: Stack(children: [
//                           SizedBox(
//                             child: Text(
//                               text,
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 15),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                         ]),
//                       ),
//                       Positioned(
//                         child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: ExpansionPanelList(
//                                 expansionCallback: (panelIndex, isExpanded) {
//                                   _expanded = !_expanded;
//                                   setState(() {});
//                                 },
//                                 children: [
//                                   ExpansionPanel(
//                                     isExpanded: _expanded,
//                                     canTapOnHeader: true,
//                                     backgroundColor:
//                                         const Color.fromRGBO(30, 215, 96, 0.9),
//                                     headerBuilder: (context, isExpanded) =>
//                                         SizedBox(
//                                             height: MediaQuery.of(context)
//                                                     .size
//                                                     .height /
//                                                 15,
//                                             child: ListTile(
//                                               title: Text(
//                                                 widget.name,
//                                                 style: const TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 25),
//                                               ),
//                                             )),
//                                     body: Stack(
//                                       children: [
//                                         Text(
//                                           'Party Code : ${widget.code}',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 20,
//                                           ),
//                                         ),
//                                         Row(
//                                           children: const [
//                                             Divider(height: 32),
//                                           ],
//                                         ),
//                                         Center(
//                                           child: RepaintBoundary(
//                                             key: key,
//                                             child: QrImage(
//                                               data: widget.code,
//                                               size: 200,
//                                               backgroundColor: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         Row(
//                                           children: const [
//                                             Divider(height: 16),
//                                           ],
//                                         ),
//                                         Center(
//                                             child: ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor:
//                                                 const Color.fromRGBO(
//                                                     30, 215, 96, 0.9),
//                                             surfaceTintColor:
//                                                 const Color.fromRGBO(
//                                                     30, 215, 96, 0.9),
//                                             foregroundColor:
//                                                 const Color.fromRGBO(
//                                                     30, 215, 96, 0.9),
//                                             shadowColor: const Color.fromRGBO(
//                                                 30, 215, 96, 0.9),
//                                             elevation: 8,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(15.0),
//                                               side: const BorderSide(
//                                                 color: Color.fromARGB(
//                                                     184, 255, 255, 255),
//                                                 width: 5,
//                                               ),
//                                             ),
//                                           ),
//                                           onPressed: () async {
//                                             handleShare();
//                                           },
//                                           child: const Text(
//                                             'Share',
//                                             selectionColor: Colors.black,
//                                             style: TextStyle(
//                                                 fontSize: 22,
//                                                 color: Colors.black),
//                                           ),
//                                         )),
//                                         Row(
//                                           children: const [
//                                             Divider(height: 16),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ])),
//                       ),
//                       buildBody(snapshot)
//                     ]);
//                   }
//                 }),
//           ]));
//     });
//   }

//   Future handleShare() async {
//     try {
//       RenderRepaintBoundary boundary =
//           key.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       var image = await boundary.toImage();
//       ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();
//       final appDir = await getApplicationDocumentsDirectory();
//       var datetime = DateTime.now();
//       file = await File('${appDir.path}/$datetime.png').create();
//       await file?.writeAsBytes(pngBytes);

//       await Share.shareFiles(
//         [file!.path],
//         mimeTypes: ["image/png"],
//         text:
//             "Scan this Qr-Code to join my SpotiParty! or instert this code: ${widget.code}",
//       );
//     } catch (e) {
//       showInSnackBar(context, e.toString(), Colors.red);
//       return;
//     }
//   }

//   handleStepBack() {
//     Future.delayed(const Duration(milliseconds: 200)).then((value) {
//       nextScreenReplace(context, const Home());
//     });
//   }

//   handlePassToLobby() {
//     Future.delayed(const Duration(milliseconds: 200)).then((value) {
//       nextScreenReplace(context, const SpotifyPlayer());
//     });
//   }

//   Future handleEnterInLobby() async {
//     final sp = context.read<SignInProvider>();
//     final ip = context.read<InternetProvider>();
//     final fp = context.read<FirebaseRequests>();
//     await ip.checkInternetConnection();

//     if (ip.hasInternet == false) {
//       showInSnackBar(context, "Check your Internet connection", Colors.red);
//       partyController.reset();
//       return;
//     }

//     fp.checkPartyExists(code: widget.code.toString()).then((value) async {
//       if (sp.hasError == true) {
//         showInSnackBar(context, sp.errorCode.toString(), Colors.red);
//         partyController.reset();
//         return;
//       }
//       if (value == true) {
//         fp.isPartyStarted().then((value) {
//           if (sp.hasError == true) {
//             showInSnackBar(context, sp.errorCode.toString(), Colors.red);
//             partyController.reset();
//             return;
//           }

//           fp.setPartyStarted(widget.code).then((value) {
//             if (sp.hasError == true) {
//               showInSnackBar(context, sp.errorCode.toString(), Colors.red);
//               partyController.reset();
//               return;
//             }
//             fp.getPartyDataFromFirestore(widget.code).then((value) {
//               if (sp.hasError == true) {
//                 showInSnackBar(context, sp.errorCode.toString(), Colors.red);
//                 partyController.reset();
//                 return;
//               }
//               fp.saveDataToSharedPreferences().then((value) {
//                 partyController.success();
//                 handlePassToLobby();
//               });
//             });
//           });
//         });
//       }
//     });
//   }

//   Widget buildBody(
//       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> party) {
//     final sp = context.read<SignInProvider>();
//     final width = MediaQuery.of(context).size.width;

//     if (party.data!.get('admin').toString() == sp.uid &&
//         !party.data!.get('isStarted')) {
//       return (Positioned(
//         bottom: 10,
//         left: width * 0.1,
//         child: RoundedLoadingButton(
//           onPressed: () {
//             handleEnterInLobby();
//           },
//           controller: partyController,
//           successColor: const Color.fromRGBO(30, 215, 96, 0.9),
//           width: width * 0.80,
//           elevation: 0,
//           borderRadius: 25,
//           color: const Color.fromRGBO(30, 215, 96, 0.9),
//           child: Wrap(
//             children: const [
//               Icon(
//                 FontAwesomeIcons.music,
//                 size: 20,
//                 color: Colors.white,
//               ),
//               SizedBox(
//                 width: 15,
//               ),
//               Text("Start Party",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ),
//       ));
//     } else if (!party.data!.get('isStarted')) {
//       return const Center(
//         child: Text(
//           'Wait the Admin starts the party',
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//       );
//     } else {
//       return (Align(
//         alignment: Alignment.bottomCenter,
//         child: RoundedLoadingButton(
//           onPressed: () {
//             partyController.success();
//             handleEnterInLobby();
//           },
//           controller: partyController,
//           successColor: const Color.fromRGBO(30, 215, 96, 0.9),
//           width: width * 0.80,
//           elevation: 0,
//           borderRadius: 25,
//           color: const Color.fromRGBO(30, 215, 96, 0.9),
//           child: Wrap(
//             children: const [
//               Icon(
//                 FontAwesomeIcons.music,
//                 size: 20,
//                 color: Colors.white,
//               ),
//               SizedBox(
//                 width: 15,
//               ),
//               Text("Enter in the lobby",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ),
//       ));
//     }
//   }
// }
