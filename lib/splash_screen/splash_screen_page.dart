import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/splash_screen/splash_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreenPage extends StatelessWidget {
  static const routeName = '/splash_screen/splash_screen_page';
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: ((context) {
      return SplashScreenBloc(SplashScreenInitial())..add(SplashInitialEvent());
    }), child: BlocBuilder<SplashScreenBloc, SplashScreenState>(
        builder: ((context, state) {
      return _displayLogo();
    })));
  }

  Widget _displayLogo() {
    return Container(
      color: primaryFadeColor,
      child: Center(
          child: Image.asset(
        'assets/images/menu_empty.png',
        fit: BoxFit.cover,
      )),
    );
  }
}
