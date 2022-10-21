import 'package:dicoding_restaurant/splash_screen/splash_screen_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splah screen bloc testing', () {
    late SplashScreenBloc splashScreenBloc;

    setUp(() {
      splashScreenBloc = SplashScreenBloc(SplashScreenInitial());
    });

    test('initial test', () {
      expect(splashScreenBloc.state, SplashScreenInitial());
    });
  });
}
