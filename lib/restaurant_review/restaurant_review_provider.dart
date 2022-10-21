import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> postReview(
    String id, String name, String review) async {
  String getRestaurantListURL = '$apiBaseUrl/review';

  try {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw ('No internet Connection');
    }

    Map<String, String> reviewPostBody = {
      'id': id,
      'name': name,
      'review': review
    };

    var reviewPostResponse =
        await http.post(Uri.parse(getRestaurantListURL), body: reviewPostBody);

    if (reviewPostResponse.statusCode == 201) {
      var reviewPostResponseJson = jsonDecode(reviewPostResponse.body);
      Map<String, dynamic> returnValue = {
        'json': reviewPostResponseJson['customerReviews'],
        'error': reviewPostResponseJson['error'],
        'errorSource': 'null'
      };
      return returnValue;
    } else {
      var reviewPostResponseJson = jsonDecode(reviewPostResponse.body);
      return {
        'error': reviewPostResponseJson["message"],
        'errorSource': 'postReview'
      };
    }
  } catch (e) {
    return {'error': e.toString(), 'errorSource': 'postReview catch'};
  }
}
