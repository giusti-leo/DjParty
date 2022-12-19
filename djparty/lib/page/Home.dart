import 'package:djparty/page/Home.dart';
import 'package:djparty/page/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:djparty/page/SignInPage.dart';
import 'package:djparty/page/JoinOptions.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'RegistrationPage.dart';

//String name, email;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? user = FirebaseAuth.instance.currentUser;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');

  Future<void> _signOut(BuildContext context) async {
    //FirebaseAuth.instance.currentUser.delete();                                  ---> TO_DO
    await FirebaseAuth.instance.signOut();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const SignInPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future:   dbRef.orderByKey().equalTo(user!.uid).orderByChild('name').once(),
        future: dbRef.child(user!.uid).once(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;

            return SafeArea(
                child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
                title: const Text('SpotiParty'),
                centerTitle: true,
              ),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black54, BlendMode.darken),
                            image: AssetImage("assets/images/logo.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        accountEmail: Text('{$users.email}'),
                        accountName: Text('{$users.name}'),
                      ),
                      /*currentAccountPicture: profile == null
                            ? CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(
                                  value.substring(0, 1),
                                  style: const TextStyle(fontSize: 40.0),
                                ),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(profile),
                              ),
                        accountName: Text(
                          value,
                          style: const TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 5.0,
                                  color: Colors.white70),
                              Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 5.0,
                                  color: Colors.white70),
                            ],
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        accountEmail: Text(
                          email,
                          style: const TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 5.0,
                                  color: Colors.white70),
                              Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 5.0,
                                  color: Colors.white70),
                            ],
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),*/
                      ListTile(
                        // tileColor: Colors.blueGrey[900],
                        shape: const Border(
                          // top: BorderSide(
                          //   color: Colors.black,
                          //   width: 1),
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        // Border.symmetric( vertical: BorderSide.none,horizontal: BorderSide(color: Colors.black, width: 3),),
                        //   color: Colors.black, style: BorderStyle.solid),
                        leading: const Icon(Icons.home_outlined,
                            color: Colors.white),
                        title: const Text(
                          'Home',
                        ),
                        onTap: () => {Navigator.of(context).pop()},
                      ),
                      ListTile(
                        // leading: Icon(Icons.exit_to_app),
                        // title: Text('Logout'),
                        // onTap: () => {Navigator.of(context).pop()},
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        onTap: () => _signOut(context),
                        title: const Text(
                          'Logout',
                        ),
                        leading: const Icon(
                          Icons.logout_sharp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 170,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  const MaterialStatePropertyAll<Color>(
                                      Color.fromRGBO(30, 215, 96, 0.9)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
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
                                      builder: (context) =>
                                          const GeneratorScreen(
                                              title: 'Create your Party')));
                            }),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 40,
                        width: 170,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  const MaterialStatePropertyAll<Color>(
                                      Color.fromRGBO(30, 215, 96, 0.9)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: const Text('Join a Party',
                                style: TextStyle(fontSize: 17)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const JoinOptions()));
                            }),
                      ),
                    ]),
              ),
            ));
          } else {
            return SafeArea(
                child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(30, 215, 96, 0.9),
                title: const Text('SpotiParty'),
                centerTitle: true,
              ),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 170,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  const MaterialStatePropertyAll<Color>(
                                      Color.fromRGBO(30, 215, 96, 0.9)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
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
                                      builder: (context) =>
                                          const GeneratorScreen(
                                              title: 'Create your Party')));
                            }),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 40,
                        width: 170,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  const MaterialStatePropertyAll<Color>(
                                      Color.fromRGBO(30, 215, 96, 0.9)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: const Text('Join a Party',
                                style: TextStyle(fontSize: 17)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const JoinOptions()));
                            }),
                      ),
                    ]),
              ),
            ));
          }
        });
  }
}
