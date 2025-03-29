import 'package:flutter/material.dart';
import 'package:smart_meter/screens/device1.dart';
import 'package:smart_meter/screens/energy.dart';
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'AmazonEmber',
          shadowColor: offWhite,
        ),
        initialRoute: HomePage.id,
        routes: {
          HomePage.id: (context) => const HomePage(),
          LoginPage.id: (context) => const LoginPage(),
          SignUp.id: (context) => const SignUp(),
          UserHome.id: (context) => const UserHome(),
          Energy.id: (context) => const Energy(),
          Device1.id: (context) => const Device1(),
        });
  }
}
