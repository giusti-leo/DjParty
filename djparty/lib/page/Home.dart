import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/User.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut(BuildContext context) async {
    //FirebaseAuth.instance.currentUser.delete();                                  ---> TO_DO
    await FirebaseAuth.instance.signOut();
    await isUserLoggedIn();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Main()));
  }

  Future<Person?> readUsername() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await docUser.get();
    print(uid);
    print(snapshot);

    if (snapshot.exists) {
      return Person.fromJson(snapshot.data()!);
    }
  }

  Widget buildUser(Person user) => ListTile(
        leading: CircleAvatar(child: Text('${user.username}')),
        title: Text('${user.email}'),
      );

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
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: FutureBuilder<Person?>(
                  future: readUsername(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data;
                      return user == null
                          ? const Center(
                              child: Text('No username'),
                            )
                          : buildUser(user);
                    } else {
                      print(snapshot.data);
                      return const Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.greenAccent,
                        color: Colors.lightGreenAccent,
                        strokeWidth: 3,
                      ));
                    }
                  })),
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
          /*
          FutureBuilder<Person?>(
              future: readUsername(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data;
                  return user == null
                      ? const Center(
                          child: Text('No username'),
                        )
                      : buildUser(user);
                } else {
                  return const  Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.greenAccent,
                    color: Colors.lightGreenAccent,
                    strokeWidth: 3,
                  ));
                }
              })),
              */
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

    // ignore: dead_code
  }
}
