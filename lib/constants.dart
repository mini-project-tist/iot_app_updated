import 'package:flutter/material.dart';

const grey_colour = Color(0xff363347);
const blue_colour = Color(0xff5B9DFD);
const off_white = Color(0xffd3d3d3);
const kdecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xff4d4d51), Color(0xff1f1c2c)],
    stops: [0.25, 0.75],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
);
List<String> d_types = ['Light Bulb', 'Fan', 'DC Motor'];
// const kButtonStyle = ButtonStyle(
//   backgroundColor: WidgetStatePropertyAll(off_white),
//   textStyle: WidgetStatePropertyAll(
//     TextStyle(color: grey_colour),
//   ),
// );
const kInputDecorationTheme = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 20.0),
  filled: true,
  fillColor: off_white,
);
