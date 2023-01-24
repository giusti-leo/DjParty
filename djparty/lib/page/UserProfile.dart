import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/EditProfile.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:djparty/widgets/ProfileWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  static String routeName = 'userProfile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String descr = '';

  bool _isLoading = false; // This is initially false where no loading state

  @override
  void initState() {
    super.initState();
    dataLoadFunction(); // this function gets called
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });

    // fetch you data over here
    getData();

    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    final fr = context.read<FirebaseRequests>();

    sp.getDataFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          backgroundColor: Color.fromARGB(128, 52, 74, 61),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(158, 61, 219, 71),
            title: const Text(
              'Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onTap: () {
                nextScreenReplace(context, const Home());
              },
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Color.fromARGB(158, 61, 219, 71),
                  backgroundColor: Color.fromARGB(128, 52, 74, 61),
                  strokeWidth: 10,
                )) // this will show when loading is true
              : Stack(children: [
                  Stack(children: [
                    (sp.imageUrl != '')
                        ? Positioned(
                            top: constraints.minHeight * 0.1,
                            left: constraints.minWidth * 0.26,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: constraints.minWidth * 0.25,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage("${sp.imageUrl}"),
                                maxRadius: constraints.minWidth * 0.25 - 10,
                              ),
                            ))
                        : Positioned(
                            top: constraints.minHeight * 0.1,
                            left: constraints.minWidth * 0.26,
                            child: CircleAvatar(
                                backgroundColor: Colors.white,
                                maxRadius: constraints.minWidth * 0.25,
                                child: CircleAvatar(
                                    maxRadius: constraints.minWidth * 0.25 - 10,
                                    backgroundColor: Color(sp.image!),
                                    child: Text(
                                      sp.init.toString().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(sp.initColor!),
                                          fontSize: 40,
                                          fontStyle: FontStyle.italic),
                                    )))),
                  ]),
                  Positioned(
                    top: constraints.minHeight * 0.1,
                    right: constraints.minWidth * 0.2,
                    child: Center(
                      child: buildCircle(
                        color: Colors.white,
                        all: 3,
                        child: buildCircle(
                          color: Colors.black,
                          all: 8,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              nextScreen(context, EditProfile());
                            },
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: constraints.minHeight * 0.35,
                    left: constraints.minWidth * 0.26,
                    child: buildName(sp.name!.toString(), sp.email!.toString()),
                  ),
                  Positioned(
                    bottom: constraints.minHeight * 0.4,
                    left: constraints.minWidth * 0.32,
                    child: const Text(
                      'About me',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Positioned(
                      bottom: constraints.minHeight * 0.19,
                      left: constraints.minWidth * 0.1,
                      child: SizedBox(
                        width: constraints.maxWidth * .8,
                        child: TextFormField(
                          maxLines: 5,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black12,
                            hintStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(158, 61, 219, 71),
                                  width: 3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(158, 61, 219, 71),
                                  width: 3),
                            ),
                          ),
                          textAlign: TextAlign.center,
                          initialValue: sp.description!.toString(),
                          readOnly: true,
                          style: const TextStyle(
                              fontSize: 16, height: 1.4, color: Colors.white),
                        ),
                      ))
                ]));
    });
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildName(String username, String email) => Column(
        children: [
          Text(
            username,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color.fromRGBO(30, 215, 96, 0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white),
          )
        ],
      );
}
