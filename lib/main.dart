import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dicoding_restaurant/utils/screen_arguments.dart';
import 'package:dicoding_restaurant/utils/background_service.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_page.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_page.dart';
import 'package:dicoding_restaurant/restaurant_review/restaurant_review_page.dart';
import 'package:dicoding_restaurant/splash_screen/splash_screen_page.dart';
import 'package:dicoding_restaurant/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_generator/material_color_generator.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationHelper notificationHelper = NotificationHelper();
  final BackgroundService service = BackgroundService();

  service.initializeIsolate();

  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  await notificationHelper.initNotifications(flutterLocalNotificationsPlugin);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dicoding Restaurant App',
        navigatorKey: navigatorKey,
        theme: ThemeData(
            textTheme:
                GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
            primarySwatch: generateMaterialColor(color: primaryColor),
            scaffoldBackgroundColor: primaryFadeColor),
        initialRoute: SplashScreenPage.routeName,
        routes: {
          SplashScreenPage.routeName: (context) => const SplashScreenPage(),
          RestaurantListPage.routeName: (context) => RestaurantListPage(
              isNotification:
                  ModalRoute.of(context)?.settings.arguments as bool),
          RestaurantDetailsPage.routeName: (context) => RestaurantDetailsPage(
              arguments: ModalRoute.of(context)?.settings.arguments
                  as RestaurantDetailsPageArguments),
          RestaurantReviewPage.routeName: (context) => RestaurantReviewPage(
              restaurant:
                  ModalRoute.of(context)?.settings.arguments as Restaurant),
        });
  }
}
