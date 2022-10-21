import 'package:dicoding_restaurant/utils/scheduling_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveSettings(bool isReminder) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminder', isReminder);

    SchedulingProvider scheduled = SchedulingProvider();
    scheduled.scheduledNotification(isReminder);

    return isReminder;
  } catch (e) {
    return !isReminder;
  }
}
