import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_meter/screens/power.dart';
import '/components/IconImage.dart';
import '/components/spacing.dart';
import '/screens/login_page.dart';
import '../components/heading.dart';
import '../constants.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'device1.dart';

double power = 0.0;
double price = 0.0;

class UserHome extends StatefulWidget {
  static const String id = 'user_home';

  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("s2");

  final _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map<String, dynamic> userData;
  bool light = false;
  late String username;
  double targetBill = 0.0;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchAndSumPower();
  }

  void fetchAndSumPower() async {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DataSnapshot snapshot = await ref.get();
    double newPower = 0.0;

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        // Extract the date portion from the key
        List<String> keyParts = key.toString().split("_");
        if (keyParts.length == 2 && keyParts[1] == currentDate) {
          // Ensure correct date format
          double valueAsDouble = (value as num).toDouble();
          newPower += valueAsDouble;
        }
      });
    }

    setState(() {
      power = newPower; // Update power with correct sum
    });
    DatabaseReference powerRef = FirebaseDatabase.instance.ref("power");
    await powerRef.update({
      currentDate: power, // Save today's total power under the date key
    });
  }

  void getCurrentUser() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        final docRef = db.collection("users").doc(user.uid);
        docRef.get().then(
          (DocumentSnapshot doc) {
            userData = doc.data() as Map<String, dynamic>;
            username = user.displayName!;
            print(userData);
          },
          onError: (e) => print("Error getting document: $e"),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: grey_colour,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: off_white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pushNamed(context, LoginPage.id);
          },
        ),
        title: TitleHeading(title: 'Welcome!'),
      ),
      body: Container(
        height: double.infinity,
        decoration: kdecoration,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                color: grey_colour,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconImage(
                          iconColour: Colors.yellow,
                          iconShape: Icons.offline_bolt_sharp),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$power W',
                            style: TextStyle(
                              color: off_white,
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Electricity usage today',
                            style: TextStyle(
                              color: off_white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Power.id);
                        },
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          color: blue_colour,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                elevation: 3,
                color: grey_colour,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconImage(
                          iconColour: Colors.green,
                          iconShape: Icons.currency_rupee_sharp),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10,000/-',
                            style: TextStyle(
                              color: off_white,
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Today\'s electricity bill',
                            style: TextStyle(
                              color: off_white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Enter target bill for today',
                                    style: TextStyle(
                                      color: grey_colour,
                                      fontFamily: 'AmazonEmber',
                                      fontSize: 20,
                                    ),
                                  ),
                                  content: TextField(
                                    style: TextStyle(
                                      color: off_white,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: grey_colour,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                      hintText: 'Target Bill',
                                      hintStyle: TextStyle(color: off_white),
                                      prefixIcon: const Icon(
                                        Icons.currency_rupee_sharp,
                                        size: 30,
                                        color: off_white,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      targetBill = value as double;
                                    },
                                  ),
                                  backgroundColor: off_white,
                                );
                              });
                        },
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          color: blue_colour,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacing(),
              Text(
                'Linked to you',
                style: TextStyle(
                  color: off_white,
                  fontSize: 25,
                ),
              ),
              Spacing(),
              Column(
                children: [
                  Card(
                    elevation: 3,
                    color: grey_colour,
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_circle_sharp,
                                color: off_white,
                                size: 60,
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, Device1.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    width: 1.0,
                                    color: off_white,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Text(
                                  'View profile',
                                  style: TextStyle(
                                    color: off_white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacing(),
                          Row(
                            children: [
                              Text(
                                'BEE PowerCell Bulb',
                                style: TextStyle(
                                  color: off_white,
                                  fontSize: 25,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              Switch(
                                value: light,
                                activeColor: blue_colour,
                                onChanged: (bool value) {
                                  // This is called when the user toggles the switch.
                                  setState(() {
                                    light = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
