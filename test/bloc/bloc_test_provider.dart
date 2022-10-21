import 'dart:convert';
import 'dart:io';

import 'package:dicoding_restaurant/models/restaurant.dart';

Future<Map<String, dynamic>> fetchRestaurant() async {
  final jsonString =
      await File('assets/data/restaurant_list.json').readAsString();
  List parsed = jsonDecode(jsonString);
  var restaurantList =
      parsed.map((json) => Restaurant.fromAPIList(json)).toList();

  Map<String, dynamic> returnValue = {
    'restaurant': restaurantList,
    'ctr': 20,
    'error': false,
    'errorSource': ''
  };
  return returnValue;
}

Future<Map<String, dynamic>> fetchRestaurantDetails() async {
  final jsonString =
      await File('assets/data/restaurant_list.json').readAsString();
  List parsed = jsonDecode(jsonString);
  var restaurant = Restaurant.fromJsonAsset(parsed[0]);

  Map<String, dynamic> returnValue = {
    'restaurant': restaurant,
    'error': false,
    'errorSource': 'null'
  };
  return returnValue;
}
