import 'package:flutter/material.dart';
import 'package:smart_meter/constants.dart';

class SlideDots extends StatelessWidget {
  final bool isActive;
  const SlideDots({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 10),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? yellowColour : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12),),
      ),
    );
  }
}
