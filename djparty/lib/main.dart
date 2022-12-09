import 'package:flutter/material.dart';

import 'package:djparty/page/HomePage.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Graphn',
      home: HomePage(),
    );
  }
}
