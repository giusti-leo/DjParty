import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class PartyPage extends StatefulWidget {
  final String code, name;

  const PartyPage({Key? key, required this.code, required this.name})
      : super(key: key);

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  final key = GlobalKey();
  File? file;
  bool _expanded = false;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String text = '';

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
          title: const Text(
            'Dj Party',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Stack(children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('parties')
                  .doc(widget.code)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No data'),
                  );
                }
                if ((snapshot.data!.get('#partecipant') > 1)) {
                  text = 'For the moment there are ' +
                      snapshot.data!.get('#partecipants').toString() +
                      ' partecipant';
                } else {
                  text = "Why don't you invite someone to your party?";
                }
                return Column(children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ExpansionPanelList(
                              expansionCallback: (panelIndex, isExpanded) {
                                _expanded = !_expanded;
                                setState(() {});
                              },
                              children: [
                                ExpansionPanel(
                                  isExpanded: _expanded,
                                  canTapOnHeader: true,
                                  backgroundColor:
                                      const Color.fromRGBO(30, 215, 96, 0.9),
                                  headerBuilder: (context, isExpanded) =>
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              15,
                                          child: ListTile(
                                            title: Text(
                                              widget.name,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 25),
                                            ),
                                          )),
                                  body: Column(
                                    children: [
                                      Text(
                                        'Party Code : ' + widget.code,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Row(
                                        children: const [
                                          Divider(height: 32),
                                        ],
                                      ),
                                      Center(
                                        child: RepaintBoundary(
                                          key: key,
                                          child: QrImage(
                                            data: widget.code,
                                            size: 200,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: const [
                                          Divider(height: 16),
                                        ],
                                      ),
                                      Center(
                                          child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              30, 215, 96, 0.9),
                                          surfaceTintColor:
                                              const Color.fromRGBO(
                                                  30, 215, 96, 0.9),
                                          foregroundColor: const Color.fromRGBO(
                                              30, 215, 96, 0.9),
                                          shadowColor: const Color.fromRGBO(
                                              30, 215, 96, 0.9),
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: const BorderSide(
                                              color: Color.fromARGB(
                                                  184, 255, 255, 255),
                                              width: 5,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            RenderRepaintBoundary boundary = key
                                                    .currentContext!
                                                    .findRenderObject()
                                                as RenderRepaintBoundary;
                                            var image =
                                                await boundary.toImage();
                                            ByteData? byteData =
                                                await image.toByteData(
                                                    format:
                                                        ImageByteFormat.png);
                                            Uint8List pngBytes =
                                                byteData!.buffer.asUint8List();
                                            final appDir =
                                                await getApplicationDocumentsDirectory();
                                            var datetime = DateTime.now();
                                            file = await File(
                                                    '${appDir.path}/$datetime.png')
                                                .create();
                                            await file?.writeAsBytes(pngBytes);

                                            await Share.shareFiles(
                                              [file!.path],
                                              mimeTypes: ["image/png"],
                                              text:
                                                  "Scan this Qr-Code to join my SpotiParty! or instert this code: ${widget.code}",
                                            );
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        child: const Text(
                                          'Share',
                                          selectionColor: Colors.black,
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black),
                                        ),
                                      )),
                                      Row(
                                        children: const [
                                          Divider(height: 16),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]))),
                  FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('parties')
                          .doc(widget.code)
                          .get(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final party = snapshot.data;
                          return party == null
                              ? const Center(
                                  child: Text('No data'),
                                )
                              : buildBody(party);
                        } else {
                          return const Center(
                              child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Color.fromRGBO(30, 215, 96, 0.9),
                            strokeWidth: 3,
                          ));
                        }
                      })),
                ]);
              })
        ])));
  }

  Widget buildBody(DocumentSnapshot<Map<String, dynamic>> party) {
    double height = MediaQuery.of(context).size.height;

    if (party.get('admin').toString() == uid && !party.get('isStarted')) {
      return (Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('parties')
                  .doc(widget.code)
                  .update({"isStarted": true})
                  .then((_) => print('Success'))
                  .catchError((error) => print('Failed: $error'));
              build;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
              surfaceTintColor: const Color.fromRGBO(30, 215, 96, 0.9),
              foregroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
              shadowColor: const Color.fromRGBO(30, 215, 96, 0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(
                  color: Color.fromARGB(184, 255, 255, 255),
                  width: 5,
                ),
              ),
            ),
            child: const Text(
              'Get the party started',
              selectionColor: Colors.black,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
          )));
    } else if (!party.get('isStarted')) {
      return const Center(
        child: Text(
          'Wait the admin starts the party',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Party Started',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }
}
