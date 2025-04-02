import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_meter/screens/energy.dart';
import '/components/IconImage.dart';
import '/components/spacing.dart';
import '/screens/login_page.dart';
import '../components/heading.dart';
import '../constants.dart';
//import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'device1.dart';

double power = 0.0;
double energy = 0.0;
double bill = 0.0;
double targetBill = 0.0;
String futurePredictedMessage = '';
late String predictedMessage;

class UserHome extends StatefulWidget {
  static const String id = 'user_home';

  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("s1");
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Map<String, dynamic> userData;
  late bool light1 = false;
  late String username;

  @override
  void initState() {
    super.initState();
    fetchTargetBillandStatus();
    fetchAndSumPower();
    calculateMonthlyBill();
    getCurrentUser();
  }

  Future<void> fetchTargetBillandStatus() async {
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
    DatabaseReference ref = FirebaseDatabase.instance.ref("status/s1");

    DatabaseEvent event = await ref.once();

    if (event.snapshot.exists) {
      var lightStatus = event.snapshot.value;
      if (lightStatus.toString() == "LOW") {
        setState(() {
          light1 = false;
        });
      } else {
        setState(() {
          light1 = true;
        });
      }
      print("Light Status: $light1");
    } else {
      print("No data found under status/s1");
    }
  }

  void calculateMonthlyBill() async {
    double newBill = 0.0;
    DatabaseReference ref = FirebaseDatabase.instance.ref("energy");
    DatabaseEvent event = await ref.once();
    int dayCount = 0;
    if (event.snapshot.exists && event.snapshot.value is Map) {
      Map<dynamic, dynamic> energyData =
          event.snapshot.value as Map<dynamic, dynamic>;
      double totalEnergy = 0.0;
      DateTime now = DateTime.now();
      String currentMonth = now.month.toString().padLeft(2, '0');
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      // Sum energy consumption and count days in the current month
      energyData.forEach((date, energy) {
        if (date.split("-")[1] == currentMonth) {
          totalEnergy += (energy as num).toDouble();
          dayCount++;
        }
      });

      // Avoid division by zero
      if (dayCount == 0) return;

      // Calculate charges based on updated slabs
      double remainingEnergy = totalEnergy;
      if (remainingEnergy > 500) {
        newBill += remainingEnergy * 9;
      } else if (remainingEnergy > 400) {
        newBill += remainingEnergy * 8.05;
      } else if (remainingEnergy > 350) {
        newBill += remainingEnergy * 7.75;
      } else if (remainingEnergy > 300) {
        newBill += remainingEnergy * 7.4;
      } else if (remainingEnergy > 250) {
        newBill += remainingEnergy * 6.55;
      } else {
        if (remainingEnergy > 200) {
          newBill += (remainingEnergy - 200) * 8.35;
          remainingEnergy = 200;
        }
        if (remainingEnergy > 150) {
          newBill += (remainingEnergy - 150) * 7.1;
          remainingEnergy = 150;
        }
        if (remainingEnergy > 100) {
          newBill += (remainingEnergy - 100) * 5.25;
          remainingEnergy = 100;
        }
        if (remainingEnergy > 50) {
          newBill += (remainingEnergy - 50) * 4.15;
          remainingEnergy = 50;
        }
        newBill += remainingEnergy * 3.3;
      }
      double electricityDuty = 0.1 * newBill;
          // Add fixed charge based on total consumption
      double fixedCharge = 0.0;
      if (totalEnergy > 500) {
        fixedCharge = 290.0;
      } else if (totalEnergy > 400) {
        fixedCharge = 265.0;
      } else if (totalEnergy > 350) {
        fixedCharge = 235.0;
      } else if (totalEnergy > 300) {
        fixedCharge = 215.0;
      } else if (totalEnergy > 250) {
        fixedCharge = 190.0;
      } else if (totalEnergy > 200) {
        fixedCharge = 145.0;
      } else if (totalEnergy > 150) {
        fixedCharge = 130.0;
      } else if (totalEnergy > 100) {
        fixedCharge = 95.0;
      } else if (totalEnergy > 50) {
        fixedCharge = 75.0;
      } else {
        fixedCharge = 45.0;
      }
      double meterRent = 6.0;
      double meterGst = 0.09 * 6;
      double fuelSurcharge = 0.10 * totalEnergy;
      newBill = double.parse((newBill + fixedCharge + electricityDuty + meterRent + (meterGst*2) + (fuelSurcharge*2)).toStringAsFixed(2));

      // Calculate average daily bill
      double averageDailyBill = newBill / dayCount;
      print("day $dayCount");
      setState(() {
        bill = newBill;
        print(bill);
      });
      print("avg $averageDailyBill");
      // Predict if the bill may exceed the target bill
      int remainingDays = daysInMonth - now.day;
      double predictedBill = 0.0;
      for (int i = 1; i <= remainingDays; i++) {
        predictedBill = bill + (averageDailyBill * i);
        futurePredictedMessage = '';
        if (predictedBill > targetBill) {
          setState(() {
            futurePredictedMessage =
                "Warning: Your bill may exceed the target on ${now.day + i} of this month.";
          });
          break;
        }
      }
      // Check if the bill exceeds 75% of the target bill
      if (targetBill > 0 && bill >= 0.75 * targetBill ||
          predictedBill > targetBill) {
        showTargetBillAlert();
      }
    }
  }

// Function to show an alert dialog
  void showTargetBillAlert() {
    predictedMessage = '';
    if (targetBill > 0 && bill >= 0.75 * targetBill) {
      setState(() {
        predictedMessage =
            "Your current bill is ₹$bill, which has reached 75% of your target bill ₹$targetBill. Consider reducing your power usage.";
      });
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Target Bill Almost Reached",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 300, // Adjust width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Shrinks the column to fit content
              children: [
                Text(
                  predictedMessage,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10), // Adds spacing
                Text(
                  futurePredictedMessage,
                  style: TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ],
            ),
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
    String currentDate = "28-03-2025";//DateFormat('dd-MM-yyyy').format(DateTime.now());
    DataSnapshot snapshot = await ref.get();
    double newPower = 0.0;
    double newEnergy = 0.0;

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // Debug: Print fetched data
      print("Fetched data: ${snapshot.value}");

      data.forEach((key, value) {
        // Extract the date portion from the key
        List<String> keyParts = key.toString().split("_");
        if (keyParts.length == 2 && keyParts[1] == currentDate) {
          // Convert value to double safely
          double valueAsDouble = double.tryParse(value.toString()) ?? 0.0;

          newPower += valueAsDouble;
          newEnergy += valueAsDouble * (0.01 / 3600);
        }
      });
    }
    print("Computed Power: $newPower, Computed Energy: $newEnergy");
    setState(() {
      power = double.parse(newPower.toStringAsFixed(2));
      energy = double.parse(newEnergy.toStringAsFixed(2));
      print("Updated Energy: $energy"); // Debug print
    });

    // Debug: Print before updating Firebase
    print("Updating Firebase -> Energy: $energy");

    DatabaseReference powerRef = FirebaseDatabase.instance.ref("power");
    await powerRef.update({
      currentDate: power,
    });

    DatabaseReference energyRef = FirebaseDatabase.instance.ref("energy");
    await energyRef.update({
      currentDate: energy,
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
        title: TitleHeading(title: 'User Home'),
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
                            Navigator.pushNamed(context, Energy.id);
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
                              '$bill/-',
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
                                      'Enter target bill for this month',
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
                                                vertical: 10.0,
                                                horizontal: 20.0),
                                        hintText: 'Target Bill',
                                        hintStyle:
                                            TextStyle(color: blackColour),
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
                                        double newTargetBill =
                                            double.tryParse(value) ?? 0.0;
                                        setState(() {
                                          targetBill =
                                              newTargetBill; // Update local variable
                                        });

                                        // Update the value in Firebase Realtime Database
                                        await updateTargetBillInDatabase(
                                            newTargetBill);
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
                                  color: light1
                                      ? Colors.white
                                      : Color.fromRGBO(255, 255, 255, 0.5),
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
                                  device_name,
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
                                    DatabaseReference statusRef =
                                        FirebaseDatabase.instance
                                            .ref("status/s1");

                                    if (!value) {
                                      // If the switch is turned off
                                      statusRef.set("LOW");
                                    } else {
                                      statusRef.set(
                                          "HIGH"); // Optional: Set true when turned on
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
