import 'package:flutter/material.dart';
import 'package:smart_meter/screens/user_home.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '/components/spacing.dart';
import '../components/heading.dart';
import '../constants.dart';
import 'package:firebase_database/firebase_database.dart';

double power = 0.0;

class Device1 extends StatefulWidget {
  static const String id = 'device1';

  const Device1({super.key});

  @override
  State<Device1> createState() => _Device1State();
}

class _Device1State extends State<Device1> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("s2");

  @override
  void initState() {
    super.initState();
    fetchAndDisplayPower();
  }

  void fetchAndDisplayPower() {
    ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        // Find the latest entry by sorting the keys (timestamps)
        var latestKey = data.keys
            .reduce((a, b) => a.toString().compareTo(b.toString()) > 0 ? a : b);
        double latestPower = (data[latestKey] as num).toDouble();

        print("Latest power reading: $latestPower at $latestKey"); // Debugging

        setState(() {
          power = latestPower;
        });
      } else {
        print("No power data found!");
      }
    });
  }

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
            Navigator.pushNamed(context, UserHome.id);
          },
        ),
        title: TitleHeading(title: 'Device 1'),
      ),
      body: Container(
        height: double.infinity,
        decoration: kdecoration,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SfRadialGauge(
                title: GaugeTitle(
                  text: 'Power Usage',
                  textStyle: TextStyle(
                    color: off_white,
                    fontWeight: FontWeight.w400,
                    fontSize: 35,
                  ),
                ),
                axes: <RadialAxis>[
                  RadialAxis(
                    axisLineStyle: AxisLineStyle(
                      cornerStyle: CornerStyle.bothCurve,
                      thickness: 20,
                    ),
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          '${power}W',
                          style: TextStyle(
                            color: off_white,
                            fontWeight: FontWeight.w400,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ],
                    showTicks: false,
                    canRotateLabels: true,
                    showLastLabel: true,
                    axisLabelStyle: GaugeTextStyle(
                      color: off_white,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        enableAnimation: true,
                        animationType: AnimationType.ease,
                        animationDuration: 5000,
                        cornerStyle: CornerStyle.bothCurve,
                        value: power,
                        width: 20,
                        gradient: SweepGradient(colors: [
                          Color(0xffFF8007),
                          Color(0xffFEC836),
                        ], stops: <double>[
                          0.25,
                          0.75
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Text(
            //   'Device Rating: 9W',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: off_white,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
