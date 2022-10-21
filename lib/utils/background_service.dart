import 'dart:math';
import 'dart:ui';
import 'dart:isolate';
import 'package:dicoding_restaurant/main.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_provider.dart';
import 'package:dicoding_restaurant/utils/notification_helper.dart';

final ReceivePort port = ReceivePort();

class BackgroundService {
  static BackgroundService? _instance;
  static const String _isolateName = 'isolate';
  static SendPort? _uiSendPort;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  void initializeIsolate() {
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      _isolateName,
    );
  }

  static Future<void> callback() async {
    final NotificationHelper notificationHelper = NotificationHelper();
    var restaurantListData = await RestaurantListProvider().getRestaurantList();

    if (restaurantListData['error'] == null ||
        restaurantListData['error'] == false) {
      List<Restaurant> restaurantList = restaurantListData['restaurant'];

      await notificationHelper.showNotification(flutterLocalNotificationsPlugin,
          restaurantList[Random().nextInt(restaurantList.length)]);

      _uiSendPort ??= IsolateNameServer.lookupPortByName(_isolateName);
      _uiSendPort?.send(null);
    }
  }
}
