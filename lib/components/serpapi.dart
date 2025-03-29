import 'dart:convert';
import 'package:http/http.dart' as http;

class SerpApiService {
  static const String apiKey = "242c76a2cf8714dab187c27387d23fb14707b75437ae59c3e93b0457c9ce13e8"; // Replace with actual API key
  static const String baseUrl = "https://serpapi.com/search";

  Future<List<Map<String, dynamic>>> fetchRecommendations(
      String device, String wattage) async {
    final String query = "$device $wattage";
    final Uri url = Uri.parse(
        "$baseUrl?engine=google_shopping&q=$query&location=India&hl=en&gl=in&num=3&api_key=$apiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> shoppingResults = data["shopping_results"] ?? [];

        if (shoppingResults.isEmpty) {
          print("No shopping results found!");
          return [];
        }

        return shoppingResults.take(3).map((item) {
          return {
            "title": item["title"] ?? "No Title",
            "price": item["price"] ?? "No Price",
            "rating": item["rating"]?.toString() ?? "No Rating",
            "link": item["product_link"] ?? "#", // Added product link
          };
        }).toList();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    return [];
  }
}
