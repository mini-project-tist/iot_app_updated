import 'package:flutter/material.dart';
import 'package:smart_meter/screens/device1.dart';
import 'package:smart_meter/screens/power.dart';
import 'constants.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_up.dart';
import 'screens/user_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartMeterApp());
}

class SmartMeterApp extends StatelessWidget {
  const SmartMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'AmazonEmber',
          shadowColor: off_white,
        ),
        initialRoute: Device1.id,
        routes: {
          HomePage.id: (context) => const HomePage(),
          LoginPage.id: (context) => const LoginPage(),
          SignUp.id: (context) => const SignUp(),
          UserHome.id: (context) => const UserHome(),
          Power.id: (context) => const Power(),
          Device1.id: (context) => const Device1(),
        });
  }
}
