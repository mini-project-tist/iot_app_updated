import 'package:flutter/material.dart';
import '/constants.dart';
class TitleHeading extends StatelessWidget {
  const TitleHeading({super.key,required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: off_white,
        fontSize: 40.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
