import 'dart:async';

import 'package:flutter/material.dart';

const primaryColor = Color(0xFFF5A265);
const secondaryColor = Color(0xFFA86534);
const primaryFadeColor = Color.fromARGB(255, 255, 231, 213);

const icon1Color = Color(0xFF00B330);
const icon2Color = Color.fromARGB(255, 175, 0, 0);

enum RestaurantView { allRestaurant, favorites }

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const apiBaseUrl = "https://restaurant-api.dicoding.dev";

class Debouncer {
  final int milliseconds;
  late VoidCallback action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  cancel() {
    _timer?.cancel();
  }
}

// bool isLogin = false;
final sessionDebouncer = Debouncer(milliseconds: 10000);

void logOut() {
  ScaffoldMessenger.of(navigatorKey.currentContext!)
      .showSnackBar(const SnackBar(
    content: Text('Should Logout...'),
    duration: Duration(seconds: 2),
  ));
  print('Should Logout...');
  // Navigator.pushReplacement(
  // navigatorKey.currentContext!, MaterialPageRoute(
  //   builder: (context) => const LoginPage(),
  // ));
}

class OutlinedText extends StatelessWidget {
  const OutlinedText(
      {Key? key,
      required this.title,
      required this.bgColor,
      required this.fgColor,
      required this.fontSize,
      required this.strokeWidth})
      : super(key: key);

  final String title;
  final Color bgColor;
  final Color fgColor;
  final double fontSize;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          letterSpacing: 1.0,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = bgColor,
        ),
      ),
      Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
              letterSpacing: 1.0, fontSize: fontSize, color: fgColor)),
    ]);
  }
}

Widget displayLoading() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

Widget displayError(String errorMessage, String? errorSource,
    Function errorCallback, bool isRetry) {
  return Column(children: [
    OutlinedText(
      bgColor: Colors.white,
      fgColor: Colors.black,
      fontSize: 24,
      strokeWidth: 1,
      title: errorMessage,
    ),
    const SizedBox(
      height: 20,
    ),
    errorSource != null
        ? OutlinedText(
            bgColor: Colors.white,
            fgColor: Colors.black,
            fontSize: 20,
            strokeWidth: 1,
            title: errorSource,
          )
        : const SizedBox(),
    const SizedBox(
      height: 20,
    ),
    isRetry
        ? ElevatedButton(
            onPressed: () => errorCallback(), child: const Text('Retry'))
        : const SizedBox()
  ]);
}
