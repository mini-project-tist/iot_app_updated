import 'package:flutter/material.dart';
class TitleHeading extends StatelessWidget {
  const TitleHeading({super.key,required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 30.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
