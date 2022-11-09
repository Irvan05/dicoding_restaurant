import 'package:dicoding_restaurant/restaurant_list/restaurant_list_page.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit {
  LoginCubit({this.userName = '', this.passWord = ''}) : super(null);

  String userName;
  String passWord;

  void login(String user, String pass) {
    userName = user;
    passWord = pass;

    if (userName != '' && passWord != '') {
      loginSuccess();
    }
  }

  void loginSuccess() {
    // isLogin = true;
    Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => RestaurantListPage(isNotification: false),
        ));
  }
}
