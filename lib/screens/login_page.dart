import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:smart_meter/screens/sign_up.dart';
import '/components/heading.dart';
import '/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/user_home.dart';
import '../components/spacing.dart';
import '../constants.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login_page';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColour,
        leading: IconButton(
          icon: appIcon,
          onPressed: () {
            Navigator.pushNamed(context, HomePage.id);
          },
        ),
        title: TitleHeading(title: 'User Login'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: kBoxDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 60.0,
                ),
                SizedBox(
                  width: 350,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: kEmailDecoration,
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                ),
                Spacing(),
                SizedBox(
                  width: 350,
                  child: TextField(
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: kPasswordDecoration,
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                ),
                Spacing(),
                SizedBox(
                  width: 200,
                  child: GradientElevatedButton(
                    style: GradientElevatedButton.styleFrom(
                      side: BorderSide(style: BorderStyle.none),
                      backgroundGradient: buttonGradient,
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        Navigator.pushNamed(context, UserHome.id);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      }
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, SignUp.id);
                      },
                      child: Text("Sign up here",style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColour,
                      ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
