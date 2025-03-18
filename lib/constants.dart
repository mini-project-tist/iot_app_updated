import 'package:flutter/material.dart';

const greyColour = Color(0xff363347);
const blueColour = Color(0xff5B9DFD);
const offWhiteColour = Color(0xfff1f4f8);
const yellowColour = Color(0xfffcd947);
const blackColour = Color.fromRGBO(0, 0, 0, 0.5);
const yellowGradient = LinearGradient(
  colors: [
    Color.fromRGBO(252, 217, 71, 1),
    Colors.orangeAccent,
    Color.fromRGBO(255, 128, 7, 0.8),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const buttonGradient = LinearGradient(
  colors: [Color(0xffffb228), Color(0xfffcd947)],
  stops: [0.15, 0.85],
  begin: Alignment.bottomRight,
  end: Alignment.topLeft,
);
const offWhite = Color(0xffd3d3d3);
const kBoxDecoration = BoxDecoration(
  color: Colors.white,
);
const kInputDecorationTheme = InputDecoration(
  contentPadding: EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 20.0),
  filled: true,
  fillColor: offWhite,
);
const kEmailDecoration = InputDecoration(
  filled: true,
  fillColor: offWhiteColour,
  contentPadding: const EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 20.0),
  hintText: 'Enter your email',
  prefixIcon: const Icon(
    Icons.email_outlined,
    size: 30,
    color: blueColour,
  ),
  border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius:
      BorderRadius.all(Radius.circular(15.0))),
);
const kPasswordDecoration = InputDecoration(
  filled: true,
  fillColor: offWhiteColour,
  contentPadding: const EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 20.0),
  hintText: 'Enter your password',
  prefixIcon: const Icon(
    Icons.password_outlined,
    size: 30,
    color: blueColour,
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius:
    BorderRadius.all(Radius.circular(15.0),),),
);
const kUsernameDecoration = InputDecoration(
  filled: true,
  fillColor: offWhiteColour,
  contentPadding: const EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 20.0),
  hintText: 'Enter your username',
  prefixIcon: const Icon(
    Icons.account_circle_outlined,
    size: 30,
    color: blueColour,
  ),
  border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius:
      BorderRadius.all(Radius.circular(15.0))),
);
const appIcon = Icon(
  Icons.arrow_back_ios_new_rounded,
  color: Colors.white,
  size: 25,
);