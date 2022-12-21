import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/page/JoinOptions.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'package:djparty/main.dart';

//String name, email;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String name = '';
  var username = '';

  @override
  void initState() {
    super.initState();

    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection('Users').doc(uid);

    username = documentReference.collection('email').toString();
    name = documentReference.collection('name').toString();
  }

  Future<void> _signOut(BuildContext context) async {
    //FirebaseAuth.instance.currentUser.delete();                                  ---> TO_DO
    await FirebaseAuth.instance.signOut();
    await isUserLoggedIn();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Main()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
        title: const Text('SpotiParty'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text('Username / Name'),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text(
                'Profile',
                selectionColor: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                ),
                title: const Text('Logout', selectionColor: Colors.black),
                onTap: () => {_signOut(context)}),
          ],
        ),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 40,
            width: 170,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                      Color.fromRGBO(30, 215, 96, 0.9)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text('Create your Party',
                    style: TextStyle(fontSize: 17)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GeneratorScreen(
                              title: 'Create your Party')));
                }),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 40,
            width: 170,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll<Color>(
                      Color.fromRGBO(30, 215, 96, 0.9)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child:
                    const Text('Join a Party', style: TextStyle(fontSize: 17)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JoinOptions()));
                }),
          ),
        ]),
      ),
    ));
  }
}
