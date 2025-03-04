import 'package:flutter/material.dart';
class IconImage extends StatelessWidget {
  const IconImage({super.key,required this.iconColour, required this.iconShape});
  final Color? iconColour;
  final IconData iconShape;
  @override
  Widget build(BuildContext context) {
    return Icon(
      iconShape,
      color: iconColour,
      size: 60,
    );
  }
}
