import 'package:flutter/material.dart';
import '/constants.dart';
import '/screens/login_page.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: kBoxDecoration,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Image(
                  image: AssetImage('images/bulb.jpeg'),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              GradientElevatedButton(
                style: GradientElevatedButton.styleFrom(
                  side: BorderSide(style: BorderStyle.none),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundGradient: buttonGradient,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, LoginPage.id);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
