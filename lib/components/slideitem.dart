import'package:flutter/material.dart';
import 'package:smart_meter/components/spacing.dart';
import 'package:smart_meter/model/slide.dart';

import '../constants.dart';

class SlideItem extends StatelessWidget {
  final int index;
  const SlideItem({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bulb.jpeg'),
                fit: BoxFit.cover),
          ),
        ),
        Spacing(),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 40,
              letterSpacing: 3,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: "Watt", // "Watt" in dark blue
                style: TextStyle(color: darkBlueColour),
              ),
              TextSpan(
                text: "Zap", // "Z" in yellow
                style: TextStyle(
                  color: Color(0xffffb228),
                ),
              ),
            ],
          ),
        ),
        Spacing(),
        Text(
          slideList[index].description,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              color: blackColour
          ),
        ),
      ],
    );
  }
}
