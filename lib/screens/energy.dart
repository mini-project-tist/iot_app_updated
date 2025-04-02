import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:smart_meter/screens/user_home.dart';

import '../components/heading.dart';
import '../constants.dart';

class Energy extends StatefulWidget {
  static const String id = 'energy';

  const Energy({super.key});

  @override
  State<Energy> createState() => _EnergyState();
}

class _EnergyState extends State<Energy> {
  DatabaseReference energyRef = FirebaseDatabase.instance.ref("energy");
  List<FlSpot> energyData = [];
  List<String> dateLabels = []; // Store date labels for the X-axis

  @override
  void initState() {
    super.initState();
    fetchEnergyData();
  }


  void fetchEnergyData() async {
    DataSnapshot snapshot = await energyRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      List<MapEntry<DateTime, double>> sortedEntries = [];

      // Get current month and year
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      data.forEach((key, value) {
        try {
          // Parse the key (date) into DateTime
          DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(key.toString());

          // Filter only the entries from the current month
          if (parsedDate.month == currentMonth && parsedDate.year == currentYear) {
            // Convert value to double safely
            double energyValue = (value as num).toDouble();

            // Store as a map entry (DateTime -> energyValue)
            sortedEntries.add(MapEntry(parsedDate, energyValue));
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      });

      // Sort the list in descending order (latest date first)
      sortedEntries.sort((a, b) => b.key.compareTo(a.key));

      // Create the lists for the chart
      List<FlSpot> tempList = [];
      List<String> tempLabels = [];

      for (int i = 0; i < sortedEntries.length; i++) {
        DateTime date = sortedEntries[i].key;
        double energyValue = sortedEntries[i].value;

        // Format date as "Month Day" (e.g., "Jun 1")
        String formattedDate = DateFormat("MMM d").format(date);

        tempList.add(FlSpot(i.toDouble(), energyValue));
        tempLabels.add(formattedDate);
      }

      // Update the state with sorted values
      setState(() {
        energyData = tempList;
        dateLabels = tempLabels;
      });

      print("Filtered energy data for current month sorted and updated.");
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
        title: TitleHeading(title: 'Energy Usage'),
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 400,
                      width: energyData.length * 50,
                      child: AspectRatio(
                        aspectRatio: 1, // Ensures a perfect square
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            // Minimum value on Y-axis
                            maxY: 50,
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
                                  interval: 10,
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
                                      return Transform.rotate(
                                        angle: -0.4,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 12, right: 12),
                                          child: Text(
                                            dateLabels[index], // No need to reverse again
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: blackColour,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container();
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
                                    colors: [
                                      Colors.blue.withOpacity(0.5), // Light blue at the top
                                      Colors.blue.withOpacity(0.1)  // Fading blue at the bottom
                                    ],
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
                    ),
                  ),
                ),),
      ),
    );
  }
}
