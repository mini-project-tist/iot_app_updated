import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import '/constants.dart';
import 'login_page.dart';
import '../components/spacing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/components/heading.dart';

class SignUp extends StatefulWidget {
  static const String id = 'sign_up';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColour,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.pushNamed(context, LoginPage.id);
          },
        ),
        title: TitleHeading(title: 'Sign Up'),
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
                  height: 20.0,
                ),
                SizedBox(
                  width: 350,
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: kUsernameDecoration,
                    onChanged: (value) {
                      username = value;
                    },
                  ),
                ),
                Spacing(),
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
                        final credential =
                            await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        Map<String, dynamic> data = {
                          'username': username,
                          'email_address': email,
                          'password': password,
                        };
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(credential.user!.uid)
                            .set(data);
                        Navigator.pushNamed(context, LoginPage.id);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          print('The account already exists for that email.');
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
