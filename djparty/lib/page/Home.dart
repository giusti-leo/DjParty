import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/Entities.dart';
import 'package:djparty/main.dart';
import 'package:djparty/page/InsertCode.dart';
import 'package:djparty/page/PartyPage.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/entities/Entities.dart';

import 'package:djparty/page/GenerateShare.dart';

//String name, email;

List parties = [];

class Home extends StatefulWidget {
  static String routeName = 'home';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  List<Widget> itemsData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    var firebaseFirestore = FirebaseFirestore;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text(
          'My parties',
          style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(30, 215, 96, 0.9),
              ),
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final user = snapshot.data;
                      return user == null
                          ? const Center(
                              child: Text('No username'),
                            )
                          : buildDrawer(user);
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        color: Colors.white,
                        strokeWidth: 3,
                      ));
                    }
                  })),
            ),
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
                Navigator.pop(context);
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
                onTap: () => {_signOut(context)}),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: SizedBox(
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('party')
                          .get(),
                      builder: (context, snapshot) {
                        if (!(snapshot.data!.docs
                            .any((element) => element.exists))) {
                          return Container(
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
                        } else {
                          return ListView(
                            children: snapshot.data!.docs.map((doc) {
                              Timestamp tmp = ((doc.data()['startDate']));
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  trailing: Icon(Icons.arrow_right),
                                  title: Text(
                                    doc.data()['PartyName'],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    tmp.toDate().day.toString() +
                                        " / " +
                                        tmp.toDate().month.toString() +
                                        " / " +
                                        tmp.toDate().year.toString(),
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => PartyPage(
                                                  code: doc
                                                      .data()['code']
                                                      .toString(),
                                                  name: doc
                                                      .data()['PartyName']
                                                      .toString(),
                                                )));
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }
                      }))),
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
                        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
                        elevation: 0.1,
                        onPressed: () {
                          Navigator.pushNamed(context, Home.routeName);
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
                              Navigator.pushNamed(
                                  context, GeneratorScreen.routeName);
                            },
                            child: const Text(
                              'Create a party',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            )),
                        Container(
                          width: size.width * 0.15,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const InsertCode(
                                          title: 'Join a Party')));
                            },
                            child: const Text(
                              'Join a party',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, Home.routeName);
    } on FirebaseAuthException catch (e) {
      print(e);
    } on Exception catch (e) {
      displayToastMessage(e.toString(), context);
    }
  }

  Widget buildDrawer(DocumentSnapshot<Map<String, dynamic>> user) => ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            child: Text(
              '${user.get('email')![0].toUpperCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            )),
        title: Text(
          '${user.get('email').toString().split('@')[0]}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      );
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = const Color.fromRGBO(30, 215, 96, 0.9)
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
