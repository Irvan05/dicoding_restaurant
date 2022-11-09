// EVENT //////////////
import 'package:dicoding_restaurant/login/login_page.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenEvent extends Equatable {
  const SplashScreenEvent();

  @override
  List<Object> get props => [];
}

class SplashInitialEvent extends SplashScreenEvent {}

////////////////////////
// STATE //////////////////////
abstract class SplashScreenState extends Equatable {}

class SplashScreenInitial extends SplashScreenState {
  @override
  List<Object> get props => [];
}

////////////////////////
// BLOC ////////////////////////////////////
class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc(SplashScreenState initialState) : super(initialState) {
    on<SplashInitialEvent>(_loadInitial);
  }

  void _loadInitial(
      SplashInitialEvent event, Emitter<SplashScreenState> emit) async {
    try {
      Future.delayed(const Duration(milliseconds: 600), () async {
        final prefs = await SharedPreferences.getInstance();
        final bool isNotification = prefs.getBool('dailyReminder') ?? false;
        // Navigator.pushReplacementNamed(
        //     navigatorKey.currentContext!, RestaurantListPage.routeName,
        //     arguments: isNotification);
        Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      });
    } catch (e) {
      Navigator.pushReplacementNamed(
          navigatorKey.currentContext!, RestaurantListPage.routeName,
          arguments: false);
    }
  }
}
