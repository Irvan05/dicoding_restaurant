import 'package:dicoding_restaurant/models/restaurant.dart';

class RestaurantDetailsPageArguments {
  final Restaurant restaurant;
  final bool isFromList;

  RestaurantDetailsPageArguments(
      {required this.restaurant, required this.isFromList});
}
