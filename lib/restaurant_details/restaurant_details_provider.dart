import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:http/http.dart' as http;

class RestaurantDetailsProvider {
  String id;
  RestaurantDetailsProvider(this.id);
  Future<Map<String, dynamic>> getRestaurantDetails() async {
    String getRestaurantDetailsURL = '$apiBaseUrl/detail/$id';

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw ('No internet Connection');
      }

      var getRestaurantResponse = await http.get(
        Uri.parse(getRestaurantDetailsURL),
      );

      if (getRestaurantResponse.statusCode == 200) {
        var getRestaurantResponseJson = jsonDecode(getRestaurantResponse.body);
        Map<String, dynamic> returnValue = {
          'restaurant': Restaurant.fromAPIDetails(
              getRestaurantResponseJson['restaurant']),
          'error': getRestaurantResponseJson['error'],
          'errorSource': 'null'
        };
        return returnValue;
      } else {
        var getRestaurantResponseJson = jsonDecode(getRestaurantResponse.body);
        return {
          'error': getRestaurantResponseJson["message"],
          'errorSource': 'getRestaurantDetails'
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'errorSource': 'getRestaurantDetails catch'
      };
    }
  }
}
