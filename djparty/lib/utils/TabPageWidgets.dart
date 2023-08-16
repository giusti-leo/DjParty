import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
Color backGround = const Color.fromARGB(255, 35, 34, 34);
Color alertColor = Colors.red;

List<Widget> tabletTabs = const [
  Tab(
    icon: Icon(
      Icons.people_alt_sharp,
      color: Colors.white,
      size: 30.0,
    ),
  ),
  Tab(
    icon: Icon(
      Icons.music_note,
      color: Colors.white,
      size: 30.0,
    ),
  ),
  Tab(
    icon: Icon(
      Icons.search,
      color: Colors.white,
      size: 30.0,
    ),
  ),
];

List<Widget> mobileTabs = const [
  Tab(text: "Users"),
  Tab(text: "Player"),
  Tab(text: "Search"),
];

Widget mobileStructTabs(TabController tabController) {
  return SizedBox(
    height: 20,
    child: Align(
        alignment: Alignment.center,
        child: TabBar(
            controller: tabController,
            isScrollable: true,
            labelPadding: const EdgeInsets.only(left: 20, right: 20),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicator: CircleTabIndicator(color: mainGreen, radius: 4),
            tabs: mobileTabs)),
  );
}

Widget tabletStructTabs(TabController tabController) {
  return Align(
    alignment: Alignment.center,
    child: RotatedBox(
      quarterTurns: 1,
      child: TabBar(
          controller: tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.only(left: 20, right: 20),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicator: CircleTabIndicator(color: mainGreen, radius: 4),
          tabs: tabletTabs),
    ),
  );
}

class CircleTabIndicator extends Decoration {
  final Color color;
  double radius;

  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final double radius;
  late Color color;

  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    late Paint paint;
    paint = Paint()..color = color;
    paint = paint..isAntiAlias = true;
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, paint);
  }
}
