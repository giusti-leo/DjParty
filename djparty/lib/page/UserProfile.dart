import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/EditProfile.dart';
import 'package:djparty/widgets/ProfileWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  static String routeName = 'userProfile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(128, 52, 74, 61),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(30, 215, 96, 0.9),
          title: const Text(
            'Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Stack(children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  strokeWidth: 3,
                ));
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('No data'),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 24),
                  ProfileWidget(
                    imagePath: snapshot.data!.get('image'),
                    init: snapshot.data!.get('init').toString(),
                    initColor: snapshot.data!.get('initColor'),
                    onClicked: () {},
                  ),
                  const SizedBox(height: 24),
                  buildName(snapshot.data!.get('username').toString(),
                      snapshot.data!.get('email').toString()),
                  const SizedBox(height: 48),
                  buildAbout(snapshot.data!.get('description').toString()),
                ],
              );
            },
          )
        ])));
  }

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

  Widget buildAbout(String descriptions) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'About me',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  hintStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromRGBO(30, 215, 96, 0.9), width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromRGBO(30, 215, 96, 0.9), width: 3),
                  ),
                ),
                textAlign: TextAlign.center,
                initialValue: descriptions,
                readOnly: true,
                style: const TextStyle(
                    fontSize: 16, height: 1.4, color: Colors.white),
              ),
            )
          ],
        ),
      );
}
