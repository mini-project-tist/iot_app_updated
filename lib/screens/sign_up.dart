import 'package:flutter/material.dart';
import '/constants.dart';
import '/screens/home_page.dart';
import 'login_page.dart';
import '../components/spacing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
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
  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

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
          title: TitleHeading(title: 'Sign Up')
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
                  shadowColor: off_white,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: off_white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              hintText: 'Enter your username',
                              prefixIcon: const Icon(
                                Icons.account_circle_outlined,
                                size: 30,
                                color: grey_colour,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
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
                                print(
                                    'The account already exists for that email.');
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text(
                            'Register',
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
