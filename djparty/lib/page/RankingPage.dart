import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/entities/User.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    final fr = context.read<FirebaseRequests>();
    sp.getDataFromSharedPreferences();
    fr.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final fr = context.read<FirebaseRequests>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parties')
            .doc(fr.partyCode)
            .collection('members')
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(158, 61, 219, 71),
              backgroundColor: Color.fromARGB(128, 52, 74, 61),
              strokeWidth: 10,
            ));
          }
          return (snapshot.data.docs.length > 0)
              ? ListView.builder(
                  itemBuilder: ((context, index) {
                    final user = snapshot.data.docs[index];
                    User currentUser = User.getTrackFromFirestore(user);
                    return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          elevation: 20,
                          color: const Color.fromARGB(255, 215, 208, 208),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: width * 0.02),
                              (currentUser.imageUrl != '')
                                  ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      maxRadius: height * 0.025,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            '${currentUser.imageUrl}'),
                                        maxRadius: height * 0.022,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      maxRadius: height * 0.025,
                                      child: CircleAvatar(
                                          maxRadius: height * 0.022,
                                          backgroundColor:
                                              Color(currentUser.image!),
                                          child: Text(
                                            currentUser.username![0]
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 40,
                                                fontStyle: FontStyle.italic),
                                          ))),
                              SizedBox(
                                height: height * 0.065,
                              ),
                              Text(
                                currentUser.username.toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: width * 0.35,
                              ),
                              Text(
                                'Score: ${currentUser.points}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: width * 0.02,
                              ),
                            ],
                          ),
                        ));
                  }),
                  itemCount: snapshot.data.docs.length)
              : const Text(
                  'Server problems',
                  style: TextStyle(color: Colors.white),
                );
        });
  }
}
