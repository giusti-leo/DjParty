import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  static String routeName = 'home';
  User loggedUser;
  FirebaseFirestore db;

  HomePage({super.key, required this.loggedUser, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController drawerController = ZoomDrawerController();
  MenuItem currentItem = MenuItems.home;

  String myToken = "";

  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: ZoomDrawer(
        controller: drawerController,
        style: DrawerStyle.defaultStyle,
        mainScreen: getScreen(),
        menuScreen: Builder(builder: (context) {
          return MenuScreen(
            loggedUser: widget.loggedUser,
            db: widget.db,
            currentItem: currentItem,
            onSelectedItem: (item) {
              setState(() {
                currentItem = item;
              });
              ZoomDrawer.of(context)!.close();
            },
          );
        }),
        borderRadius: 24.8,
        angle: 0.0,
        menuBackgroundColor: const Color.fromARGB(255, 178, 184, 172),
        slideWidth: MediaQuery.of(context).size.width * .5,
        openCurve: Curves.fastLinearToSlowEaseIn,
        closeCurve: Curves.easeInCirc,
      ),
    ));
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getScreen() {
    switch (currentItem) {
      case MenuItems.profile:
        return UserProfile(
          drawerController: drawerController,
          loggedUser: FirebaseAuth.instance.currentUser!,
          db: FirebaseFirestore.instance,
        );
      case MenuItems.home:
        return Home(
          drawerController: drawerController,
          loggedUser: FirebaseAuth.instance.currentUser!,
          db: FirebaseFirestore.instance,
        );
    }
  }
}

class MenuScreen extends StatelessWidget {
  MenuItem currentItem;
  ValueChanged<MenuItem> onSelectedItem;
  User loggedUser;
  FirebaseFirestore db;

  MenuScreen(
      {Key? key,
      required this.currentItem,
      required this.onSelectedItem,
      required this.loggedUser,
      required this.db})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 178, 184, 172),
          body: SafeArea(
              child: Column(children: [
            DrawerHeader(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    (loggedUser.photoURL != '')
                        ? CircleAvatar(
                            radius: 37,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  NetworkImage("${loggedUser.photoURL}"),
                            ),
                          )
                        : CircleAvatar(
                            radius: 37,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.black,
                                child: Text(
                                  loggedUser.displayName!
                                      .toUpperCase()
                                      .substring(0, 1),
                                  style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 20,
                                      fontStyle: FontStyle.normal),
                                )),
                          )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('${loggedUser.displayName}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12))
                  ],
                )
              ],
            )),
            const Spacer(
              flex: 1,
            ),
            ...MenuItems.all.map(buildMenuItem).toList(),
            const Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                child: Row(children: const [
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 28,
                  ),
                  Text('Logout',
                      style: TextStyle(color: Colors.white, fontSize: 16))
                ]),
                onTap: () async {
                  {
                    FirebaseAuth.instance.signOut();
                  }
                },
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ]))),
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTileTheme(
        selectedColor: Colors.white,
        child: ListTile(
          selectedTileColor: Colors.black26,
          selected: currentItem == item,
          minLeadingWidth: 20,
          leading: Icon(item.icon),
          title: Text(item.title),
          onTap: () {
            onSelectedItem(item);
          },
        ),
      );
}

class MenuItem {
  final String title;
  final IconData icon;

  const MenuItem(this.title, this.icon);
}

class MenuItems {
  static const profile = MenuItem('Profile', LineIcons.user);
  static const home = MenuItem('Home', LineIcons.home);

  static const all = <MenuItem>[profile, home];
}
