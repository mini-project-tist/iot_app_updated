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

import 'device1.dart';

double power = 0.0;
double price = 0.0;
double energy = 0.0;
double bill = 0.0;
double targetBill = 0.0;
String predicted = '';

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
  bool light1 = true;
  bool light2 = true;
  late String username;

  @override
  void initState() {
    super.initState();
    fetchTargetBill();
    calculateMonthlyBill();
    getCurrentUser();
    fetchAndSumPower();
  }
  Future<void> fetchTargetBill() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("target_bill");
      DatabaseEvent event = await ref.once();

      if (event.snapshot.exists) {
        double fetchedTargetBill = (event.snapshot.value as num).toDouble();
        setState(() {
          targetBill = fetchedTargetBill;
        });
        print("Target bill fetched: $targetBill");
      } else {
        print("No target bill found in database.");
      }
    } catch (e) {
      print("Error fetching target bill: $e");
    }
  }

  void calculateMonthlyBill() async {
    double newBill = 0.0;
    DatabaseReference ref = FirebaseDatabase.instance.ref("energy");
    DatabaseEvent event = await ref.once();
    int dayCount = 0;
    if (event.snapshot.exists && event.snapshot.value is Map) {
      Map<dynamic, dynamic> energyData = event.snapshot.value as Map<dynamic, dynamic>;
      double totalEnergy = 0.0;
      String currentMonth = DateTime.now().month.toString().padLeft(2, '0');

      // Sum energy consumption and count days in the current month
      energyData.forEach((date, energy) {
        if (date.split("-")[1] == currentMonth) {
          totalEnergy += (energy as num).toDouble();
          dayCount++; // Counting the number of days of data available
        }
      });

      // Calculate charges based on slabs
      double remainingEnergy = totalEnergy;
      if (remainingEnergy > 250) {
        newBill += (remainingEnergy - 250) * 7.60;
        remainingEnergy = 250;
      }
      if (remainingEnergy > 200) {
        newBill += (remainingEnergy - 200) * 6.40;
        remainingEnergy = 200;
      }
      if (remainingEnergy > 150) {
        newBill += (remainingEnergy - 150) * 4.80;
        remainingEnergy = 150;
      }
      if (remainingEnergy > 100) {
        newBill += (remainingEnergy - 100) * 3.70;
        remainingEnergy = 100;
      }
      if (remainingEnergy > 50) {
        newBill += (remainingEnergy - 50) * 3.15;
        remainingEnergy = 50;
      }
      newBill += remainingEnergy * 1.50;

      // Add fixed charge based on total consumption
      double fixedCharge = 0.0;
      if (totalEnergy > 250) {
        fixedCharge = 80.0;
      } else if (totalEnergy > 200) {
        fixedCharge = 70.0;
      } else if (totalEnergy > 150) {
        fixedCharge = 55.0;
      } else if (totalEnergy > 100) {
        fixedCharge = 45.0;
      } else if (totalEnergy > 50) {
        fixedCharge = 35.0;
      }

      newBill = double.parse((newBill + fixedCharge).toStringAsFixed(2));
    }

    setState(() {
      bill = newBill;
    });

    // Check if the bill exceeds 75% of the target bill and show an alert
    if (targetBill > 0 && bill >= 0.75 * targetBill) {
      showTargetBillAlert();
    }
    // Check if today is within the first 15 days of the month and if there are exactly 15 days of data
    int currentDay = DateTime.now().day;
    if (currentDay <= 5 && dayCount == 5) {
      double predictedBill = bill * 5; // Predict bill for the next 15 days

      if (predictedBill > targetBill) {
        showOverUsageWarning(predictedBill);
      }
    }
  }

// Function to show an alert when the current bill might exceed the target
  void showOverUsageWarning(double predictedBill) {
    predicted = "Your current energy usage suggests that your bill could reach ₹{$predictedBill} by the end of the month, exceeding your target bill ₹$targetBill. Consider reducing your consumption.";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Energy Usage Warning",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your current energy usage suggests that your bill could reach ₹$predictedBill by the end of the month, exceeding your target bill ₹$targetBill. Consider reducing your consumption.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


// Function to show an alert dialog
  void showTargetBillAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Target Bill Almost Reached",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your current bill is ₹$bill, which is 75% or more of your target bill ₹$targetBill. Consider reducing your power usage. ${predicted}",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void fetchAndSumPower() async {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DataSnapshot snapshot = await ref.get();
    double newPower = 0.0;
    double newEnergy = 0.0;

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        // Extract the date portion from the key
        List<String> keyParts = key.toString().split("_");
        if (keyParts.length == 2 && keyParts[1] == currentDate) {
          // Convert value to double safely
          double valueAsDouble = double.tryParse(value.toString()) ?? 0.0;

          newPower += valueAsDouble;
          newEnergy = double.parse((newEnergy + valueAsDouble * (2 / 60)).toStringAsFixed(2));
        }
      });
    }

    setState(() {
      power = power = double.parse(newPower.toStringAsFixed(2));  // Update power with correct sum
      energy = newEnergy;
    });

    DatabaseReference powerRef = FirebaseDatabase.instance.ref("power");
    await powerRef.update({
      currentDate: power, // Save today's total power under the date key
    });

    DatabaseReference energyRef = FirebaseDatabase.instance.ref("energy");
    await energyRef.update({
      currentDate: energy, // Save today's total energy under the date key
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
        height: double.infinity,
        decoration: kBoxDecoration,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                child: Container(
                    decoration: BoxDecoration(
                      gradient: yellowGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconImage(
                            iconColour: Color.fromRGBO(255, 2555, 255, 0.6),
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
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Power usage today',
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
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
                            Icons.arrow_forward_ios,
                            color: blueColour,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: yellowGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconImage(
                            iconColour: Color.fromRGBO(28, 142, 11, 0.4),
                            iconShape: Icons.currency_rupee),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bill}/-',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Monthly electricity bill',
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
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
                                        color: blackColour,
                                        fontFamily: 'AmazonEmber',
                                        fontSize: 20,
                                      ),
                                    ),
                                    content: TextField(
                                      style: TextStyle(
                                        color: blackColour,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: yellowColour,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 20.0),
                                        hintText: 'Target Bill',
                                        hintStyle: TextStyle(color: blackColour),
                                        prefixIcon: const Icon(
                                          Icons.currency_rupee_sharp,
                                          size: 30,
                                          color: blackColour,
                                        ),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) async {
                                        double newTargetBill = double.tryParse(value) ?? 0.0;
                                        setState(() {
                                          targetBill = newTargetBill; // Update local variable
                                        });

                                        // Update the value in Firebase Realtime Database
                                        await updateTargetBillInDatabase(newTargetBill);
                                      },

                                    ),
                                    backgroundColor: Colors.white,
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: blueColour,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacing(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Linked to you',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    fontSize: 25,
                  ),
                ),
              ),
              Column(
                children: [
                  Card(
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: yellowGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_circle_rounded,
                                  color: light1 ? Colors.white : Color.fromRGBO(255,255,255,0.5),
                                  size: 60,
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Device1.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: blueColour,
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      style: BorderStyle.none,
                                    ),
                                  ),

                                  child: Text(
                                    'View profile',
                                    style: TextStyle(
                                      color: Colors.white,
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
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Switch(
                                  value: light1,
                                  activeColor: blueColour,
                                  onChanged: (bool value) {
                                    setState(() {
                                      light1 = value;
                                    });

                                    // Reference to the status object in Firebase
                                    DatabaseReference statusRef = FirebaseDatabase.instance.ref("status/s1");

                                    if (!value) { // If the switch is turned off
                                      statusRef.set("LOW");
                                    } else {
                                      statusRef.set("HIGH"); // Optional: Set true when turned on
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacing(),
                  Card(
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: yellowGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_circle_rounded,
                                  color: light2 ? Colors.white : Color.fromRGBO(255,255,255,0.5),
                                  size: 60,
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Device1.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: blueColour,
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      style: BorderStyle.none,
                                    ),
                                  ),

                                  child: Text(
                                    'View profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacing(),
                            Row(
                              children: [
                                Text(
                                  'Crompton LED Bulb',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Switch(
                                  value: light2,
                                  activeColor: blueColour,
                                  onChanged: (bool value) {
                                    setState(() {
                                      light2 = value;
                                    });

                                    // Reference to the status object in Firebase
                                    DatabaseReference statusRef = FirebaseDatabase.instance.ref("status/s2");

                                    if (!value) { // If the switch is turned off
                                      statusRef.set("LOW");
                                    } else {
                                      statusRef.set("HIGH"); // Optional: Set true when turned on
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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
Future<void> updateTargetBillInDatabase(double newTargetBill) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref("target_bill");
    await ref.set(newTargetBill);
    print("Target bill updated successfully!");
  } catch (e) {
    print("Error updating target bill: $e");
  }
}
