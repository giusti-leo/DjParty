import 'package:flutter/material.dart';

///Custom IconButton
///with a [VoidCallback]
///
///
class SizedIconButton extends StatelessWidget {
  ///[width] sets the size of the icon
  ///[icon] sets the icon
  /// [onPressed] is the callback
  const SizedIconButton(
      {Key? key,
      Color color = const Color.fromRGBO(30, 215, 96, 0.9),
      required this.width,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  ///[width] sets the size of the icon
  final double width;

  ///[icon] sets the icon
  final Icon icon;

  /// [onPressed] is the callback
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}
