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
  DatabaseReference energyRef = FirebaseDatabase.instance.ref("energy");
  List<FlSpot> energyData = [];
  List<String> dateLabels = []; // Store date labels for the X-axis

  @override
  void initState() {
    super.initState();
    fetchPowerData();
  }


  void fetchPowerData() async {
    DataSnapshot snapshot = await energyRef.get();

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
        energyData = tempList;
        dateLabels = tempLabels;
      });
    }
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
            Navigator.pushNamed(context, UserHome.id);
          },
        ),
        title: TitleHeading(title: 'Electricity Usage'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: double.infinity,
        decoration: kBoxDecoration,
        child: energyData.isEmpty
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
                        maxY: 100,
                        // Maximum value on Y-axis
                        gridData: FlGridData(
                          show: false,
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: blackColour,
                            )),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              minIncluded: false,
                              interval: 50,
                              // Labels every 100 units
                              reservedSize: 40,
                              // Adjust spacing
                              getTitlesWidget: (value, meta) {
                                if (value % 10 == 0) {
                                  // Show only for multiples of 100
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                        color: blackColour, fontSize: 7),
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
                                color: blackColour,
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
                                      fontSize: 7,
                                      color: offWhite,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                              reservedSize: 40,
                              interval: 1,
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: energyData,
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                                show: true,
                              gradient: LinearGradient(
                                colors: [Color(0xffffb228), Color(0xfffcd947)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                // Find the maximum y-value in the dataset
                                double maxYValue = energyData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

                                return FlDotCirclePainter(
                                  radius: 2, // Increase dot size for better visibility
                                  color: spot.y == maxYValue ? Colors.red : Colors.blue, // Red if max value
                                  strokeWidth: 1,
                                  strokeColor: spot.y == maxYValue ? Colors.red : Colors.blueGrey,
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
