import 'package:flutter/material.dart';
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
        backgroundColor: grey_colour,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pushNamed(context, HomePage.id);
          },
        ),
        title: TitleHeading(title: 'User Login'),
      ),
      body: Container(
        decoration: kdecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
          child: ListView(
            children: [
              Center(
                child: Card(
                  color: grey_colour,
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: off_white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 30,
                                color: grey_colour,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
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
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: off_white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.password_outlined,
                                size: 30,
                                color: grey_colour,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              password = value;
                            },
                          ),
                        ),
                        Spacing(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: off_white,
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
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
                              color: grey_colour,
                              fontFamily: 'AmazonEmber',
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
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
