import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:http/http.dart' as http;

class RestaurantListProvider {
  Future<Map<String, dynamic>> getRestaurantList() async {
    String getRestaurantListURL = '$apiBaseUrl/list';

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw ('No internet Connection');
      }

      var getRestaurantResponse = await http.get(
        Uri.parse(getRestaurantListURL),
      );

      if (getRestaurantResponse.statusCode == 200) {
        RestaurantList restaurantList =
            RestaurantList.fromRawJson(getRestaurantResponse.body);
        Map<String, dynamic> returnValue = {
          'restaurant': restaurantList.restaurants,
          'ctr': restaurantList.ctr,
          'error': restaurantList.error,
          'errorSource': restaurantList.message
        };
        return returnValue;
      } else {
        var getRestaurantResponseJson = jsonDecode(getRestaurantResponse.body);
        return {
          'error': getRestaurantResponseJson["message"],
          'errorSource': 'getRestaurantList'
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'errorSource': 'getRestaurantList'};
    }
  }

  Future<Map<String, dynamic>> searchRestaurant(String searchString) async {
    String getRestaurantListURL = '$apiBaseUrl/search?q=$searchString';

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw ('No internet Connection');
      }

      var searchRestaurantResponse = await http.get(
        Uri.parse(getRestaurantListURL),
      );

      if (searchRestaurantResponse.statusCode == 200) {
        var restaurantList =
            RestaurantList.fromRawJsonSearch(searchRestaurantResponse.body);

        Map<String, dynamic> returnValue = {
          'restaurant': restaurantList.restaurants,
          'searchCtr': restaurantList.ctr,
          'error': null,
          'errorSource': 'null'
        };
        return returnValue;
      } else {
        var searchRestaurantResponseJson =
            jsonDecode(searchRestaurantResponse.body);
        return {
          'error': searchRestaurantResponseJson["message"],
          'errorSource': 'searchRestaurant'
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'errorSource': 'searchRestaurant catch'};
    }
  }
}
