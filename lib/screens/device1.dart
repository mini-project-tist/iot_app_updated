import 'package:flutter/material.dart';
import 'package:smart_meter/screens/user_home.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/serpapi.dart';
import '/components/spacing.dart';
import '../components/heading.dart';
import '../constants.dart';
//import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class Device1 extends StatefulWidget {
  static const String id = 'device1';

  const Device1({super.key});

  @override
  State<Device1> createState() => _Device1State();
}

class _Device1State extends State<Device1> {
  final SerpApiService serpApiService = SerpApiService();
  List<Map<String, dynamic>> recommendations = [];
  DatabaseReference ref = FirebaseDatabase.instance.ref("s1");
  bool isExpandedRadialGauge = false;
  bool isExpandedLineGraph = false;
  bool isExpandedRecommendations = false;
  double power = 0.0;
  List<FlSpot> powerData = [];
  List<String> timeLabels = []; // Store extracted time strings
  String tips = '';
  late String light;

  @override
  void initState() {
    super.initState();
    fetchSwitch();
    fetchAndDisplayPower();
    fetchData(device_type).then((data) {
      tips = data;
      print(data);
    }).catchError((error) {
      print(error);
    });
  }
  Future<void> fetchSwitch() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("status/s1");

    DatabaseEvent event = await ref.once();

    if (event.snapshot.exists) {
      var lightStatus = event.snapshot.value;

      setState(() {
        light = lightStatus.toString(); // Store in variable
      });

      print("Light Status: $light");
    } else {
      print("No data found under status/s1");
    }
  }

  void showFaultPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fault Detected!"),
          content: Text("Fault in Device 1 detected!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void fetchAndDisplayPower() {
    ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        Map<dynamic, dynamic> data =
        event.snapshot.value as Map<dynamic, dynamic>;

        List<FlSpot> graphData = [];
        List<String> labels = [];
        //int index = 0; // Track index for graph points

        // Get today's date in the same format as Firebase keys (dd-mm-yyyy)
        String todayDate = DateTime.now()
            .toLocal()
            .toString()
            .split(" ")[0]
            .split("-")
            .reversed
            .join("-"); // Convert yyyy-mm-dd to dd-mm-yyyy

        // Filter data for only today's readings
        Map<String, double> todaysData = {};
        data.forEach((key, value) {
          if (key.contains(todayDate)) {
            try {
              // Convert string values to double safely
              double parsedValue = double.tryParse(value.toString()) ?? 0.0;
              todaysData[key] = parsedValue;
            } catch (e) {
              print("Error converting value to double: $e");
            }
          }
        });

        try {
          if (todaysData.isNotEmpty) {
            // Sort the keys based on time (hh:mm:ss) extracted from "hh:mm:ss_dd-mm-yyyy"
            List<String> sortedKeys = todaysData.keys.toList()
              ..sort((a, b) {
                String timeA = a.split("_")[0]; // Extract hh:mm:ss
                String timeB = b.split("_")[0];
                return timeA.compareTo(timeB);
              });

            // Find the latest power reading from today's sorted data
            String latestKey = sortedKeys.last;
            double latestPower = todaysData[latestKey]!;

            // Process the sorted data for the graph
            for (int i = 0; i < sortedKeys.length; i++) {
              String timePart = sortedKeys[i].split("_")[0]; // Extract hh:mm:ss
              labels.add(timePart);
              graphData.add(FlSpot(i.toDouble(), todaysData[sortedKeys[i]]!));
            }

            // Update the state after sorting and processing
            setState(() {
              power = latestPower; // Update power gauge
              powerData = graphData; // Update graph data
              timeLabels = labels; // Update time labels
            });

            print("Latest power reading for today: $power at $latestKey");
            // Call `search()` only if power > 9 and recommendations are empty
            if ((power > rating || (power == 0 && light == "HIGH")) && recommendations.isEmpty) {
              showFaultPopup();
              search();
            }
          } else {
            print("No power readings found for today!");
          }
        } catch (e) {
          print("Error processing today's power data: $e");
        }
      } else {
        print("No power data found!");
      }
    });
  }


  void search() async {
    print("Fetching recommendations...");
    final results = await serpApiService.fetchRecommendations(device_type, rating.toString());
    print("Results received: $results");

    setState(() {
      recommendations = results;
    });

    print("Recommendations updated in state: $recommendations");
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
        title: TitleHeading(title: device_name),
      ),
      body: Container(
        height: double.infinity,
        decoration: kBoxDecoration,
        child: ListView(
          children: [
            // Radial Gauge for Current Power
            ExpansionTile(
              title: Text(
                "Power Usage",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
              initiallyExpanded: isExpandedRadialGauge,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpandedRadialGauge = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          axisLineStyle: AxisLineStyle(
                              cornerStyle: CornerStyle.bothCurve,
                              thickness: 20),
                          maximum: 30,
                          annotations: [
                            GaugeAnnotation(
                              widget: Text(
                                '${power}W',
                                style: TextStyle(
                                    color: blackColour,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 25),
                              ),
                            ),
                          ],
                          showTicks: false,
                          canRotateLabels: true,
                          showLastLabel: true,
                          axisLabelStyle: GaugeTextStyle(color: blackColour),
                          pointers: <GaugePointer>[
                            RangePointer(
                              enableAnimation: true,
                              animationType: AnimationType.ease,
                              animationDuration: 5000,
                              cornerStyle: CornerStyle.bothCurve,
                              value: power,
                              width: 20,
                              gradient: SweepGradient(
                                colors: [
                                  Color(0xffFF8007),
                                  Color(0xffFEC836),
                                ],
                                stops: [0.25, 0.75],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Spacing(),
            // Line Graph for Power History

            ExpansionTile(
              title: Text(
                "Power Consumption",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
              initiallyExpanded: isExpandedRadialGauge,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpandedRadialGauge = expanded;
                });
              },
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: 250,
                    width: powerData.length * 50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 30,
                          gridData: FlGridData(
                            show: false,
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: blackColour,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                minIncluded: false,
                                interval: 10,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 3.0),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: blackColour,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Power',
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
                                interval: 1, // Adjust interval dynamically
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < timeLabels.length) {
                                    // Reverse index order
                                    int reversedIndex = timeLabels.length - 1 - index;
                                    return Transform.rotate(
                                      angle: -0.4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8, left: 12, right: 12),
                                        child: Text(
                                          timeLabels[reversedIndex], // Use reversed order
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
                                  double maxYValue =
                                  powerData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

                                  return FlDotCirclePainter(
                                    radius: 2,
                                    color: spot.y == maxYValue ? Colors.red : Colors.blue,
                                    strokeWidth: 1,
                                    strokeColor:
                                    spot.y == maxYValue ? Colors.red : Colors.blueGrey,
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
              ],
            ),
            Spacing(),
            ExpansionTile(
              title: Text(
                "Recommendations",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blackColour),
              ),
              initiallyExpanded: isExpandedRecommendations,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpandedRecommendations = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: power < rating
                        ? Text(
                            "Device is not faulty. No recommendations needed.",
                            style: TextStyle(fontSize: 18, color: blackColour),
                          )
                        : ListView.builder(
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final item = recommendations[index];
                        return ListTile(
                          title: Text(item["title"] ?? "No Title"),
                          trailing: Text("Price: ${item["price"]}"),
                          //
                          // trailing: Text("Rating: ${item["rating"]}"),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Spacing(),
            ExpansionTile(
              title: Text(
                "Custom Tips",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: blackColour,
                ),
              ),
              initiallyExpanded: isExpandedRecommendations,
              onExpansionChanged: (expanded) {
                setState(() {
                  isExpandedRecommendations = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: SizedBox(
                    width: 250,
                    child: Text(
                      "${tips}",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
                // Add spacing at the bottom
                const SizedBox(height: 20),
              ],
            ),

            Spacing(),
          ],
        ),
      ),
    );
  }
}

Future<String> fetchData(String device) async {
  final response = await http.get(Uri.parse(
      'https://majorprojectsmartmeter.pythonanywhere.com/?device=$device_type'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, return the response body
    return response.body;
  } else {
    // If the server returns an error response, throw an exception
    throw Exception('Failed to load data');
  }
}
