import 'package:flutter/material.dart';
import '/constants.dart';
import '/screens/login_page.dart';
import 'sign_up.dart';
import '../components/spacing.dart';
import '../components/heading.dart';

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
        decoration: kdecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleHeading(title: 'Smart Meter App'),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 18.0,
                ),
                child: Card(
                  color: grey_colour,
                  elevation: 3,
                  shadowColor: off_white,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, LoginPage.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: off_white,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: grey_colour,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Spacing(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, SignUp.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: off_white,
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: grey_colour,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
