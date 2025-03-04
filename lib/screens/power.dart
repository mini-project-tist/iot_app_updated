import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:smart_meter/screens/user_home.dart';

import '../components/heading.dart';
import '../constants.dart';

class Power extends StatefulWidget {
  static const String id = 'power';

  const Power({super.key});

  @override
  State<Power> createState() => _PowerState();
}

class _PowerState extends State<Power> {
  DatabaseReference powerRef = FirebaseDatabase.instance.ref("power");
  List<FlSpot> powerData = [];
  List<String> dateLabels = []; // Store date labels for the X-axis

  @override
  void initState() {
    super.initState();
    fetchPowerData();
  }

  void fetchPowerData() async {
    DataSnapshot snapshot = await powerRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<FlSpot> tempList = [];
      List<String> tempLabels = [];

      int index = 0; // X-axis index for FLChart

      data.forEach((key, value) {
        try {
          // Parse "dd-MM-yyyy" format to DateTime
          DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(key.toString());

          // Convert to "Month Day" format
          String formattedDate =
              DateFormat("MMM d").format(parsedDate); // Example: "Jun 1"

          double powerValue = (value as num).toDouble();
          tempList.add(
              FlSpot(index.toDouble(), powerValue)); // (X, Y) = (index, power)
          tempLabels.add(formattedDate); // Store formatted date
          index++;
        } catch (e) {
          print("Error parsing date: $e");
        }
      });

      setState(() {
        powerData = tempList;
        dateLabels = tempLabels;
      });
    }
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
            Navigator.pushNamed(context, UserHome.id);
          },
        ),
        title: TitleHeading(title: 'Power Usage'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: double.infinity,
        decoration: kdecoration,
        child: powerData.isEmpty
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loader while fetching data
            : Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1, // Ensures a perfect square
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        // Minimum value on Y-axis
                        maxY: 1000,
                        // Maximum value on Y-axis
                        gridData: FlGridData(
                          show: false,
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: off_white,
                            )),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              minIncluded: false,
                              interval: 100,
                              // Labels every 100 units
                              reservedSize: 40,
                              // Adjust spacing
                              getTitlesWidget: (value, meta) {
                                if (value % 100 == 0) {
                                  // Show only for multiples of 100
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                        color: off_white, fontSize: 12),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(
                              'Energy',
                              style: TextStyle(
                                color: off_white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < dateLabels.length) {
                                  return Text(
                                    dateLabels[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: off_white,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                              reservedSize: 30,
                              interval: 1,
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: powerData,
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3)),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 1,
                                  // Change this value to increase/decrease dot size
                                  color: Colors.blue,
                                  // Change dot color
                                  strokeWidth: 1,
                                  strokeColor: Colors.blueGrey,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
      ),
    );
  }
}
