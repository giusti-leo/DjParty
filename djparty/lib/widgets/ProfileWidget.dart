import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/EditProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final int imagePath;
  final String init;
  final int initColor;
  final bool isEdit;
  final VoidCallback onClicked;
  final User loggedUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.initColor,
    required this.init,
    this.isEdit = false,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          const SizedBox(height: 32),
          buildImage(context),
          Positioned(
            bottom: 0,
            right: 100,
            child: buildEditIcon(context),
          ),
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.white,
        minRadius: 70.0,
        child: CircleAvatar(
            backgroundColor: Color(imagePath),
            minRadius: 65,
            child: Text(
              init.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(initColor),
                fontSize: 40,
              ),
            )));
  }

  Widget buildEditIcon(
    BuildContext context,
  ) =>
      buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: Colors.black,
          all: 8,
          child: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfile(
                            loggedUser: loggedUser,
                            db: db,
                          )));
            },
            color: Colors.white,
          ),
        ),
      );

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
}
