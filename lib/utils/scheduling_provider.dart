import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dicoding_restaurant/utils/background_service.dart';
import 'package:flutter/material.dart';

class SchedulingProvider extends ChangeNotifier {
  DateTime now = DateTime.now();
  int startHour = 11;

  Future<bool> scheduledNotification(bool value) async {
    late DateTime start;
    if (now.hour >= startHour) {
      start = DateTime(now.year, now.month, now.day + 1, startHour, 0, 0);
    } else {
      start = DateTime(now.year, now.month, now.day, startHour, 0, 0);
    }

    if (value) {
      notifyListeners();
      return await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        1,
        BackgroundService.callback,
        startAt: start,
        allowWhileIdle: true,
        exact: true,
        wakeup: true,
      );
    } else {
      notifyListeners();
      return await AndroidAlarmManager.cancel(1);
    }
  }
}
