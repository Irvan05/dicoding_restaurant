import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<List<MenuDetails>> {
  CartCubit(
      {required this.cartItems, required this.totalPrice, required this.tax})
      : super(cartItems);

  List<MenuDetails> cartItems;

  double totalPrice;
  double tax;

  void removeItem(MenuDetails item) {
    cartItems.removeWhere((element) => element.name == item.name);
    totalPrice = cartItems.fold(
        0, (previousValue, element) => previousValue + element.price);
    tax = totalPrice * 0.1;
    print('remove');
    emit(cartItems);
  }
}
