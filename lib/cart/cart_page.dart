import 'dart:io';

import 'package:dicoding_restaurant/cart/cart_cubit.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  CartPage({
    super.key,
    required this.cartItems,
  });

  final List<MenuDetails> cartItems;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final CartCubit cubit; // = CartCubit(cartItems: cartItems);

  @override
  void initState() {
    double totalPrice = widget.cartItems
        .fold(0, (previousValue, element) => previousValue + element.price);
    cubit = CartCubit(
        cartItems: widget.cartItems,
        totalPrice: totalPrice,
        tax: totalPrice * 0.1);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Cart')),
        body: BlocBuilder<CartCubit, List<MenuDetails>>(
          bloc: cubit,
          builder: (context, state) {
            sessionDebouncer.run(logOut);
            return ListView.builder(
                itemCount: state.length + 1,
                itemBuilder: (context, index) {
                  final formatCurrency = NumberFormat.simpleCurrency(
                      locale: Platform.localeName, name: 'IDR');
                  if (index < state.length) {
                    return Container(
                        child: ListTile(
                      leading: Image.asset(
                        'assets/images/menu_empty.png',
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      title: Text(state[index].name),
                      subtitle:
                          Text('${formatCurrency.format(state[index].price)}'),
                      trailing: IconButton(
                          onPressed: () {
                            cubit.removeItem(state[index]);
                          },
                          icon: Icon(Icons.delete)),
                    ));
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatCurrency.format(cubit.totalPrice)}',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text('Tax 10%: ${cubit.tax}'),
                        Text(
                          'Total: ${formatCurrency.format(cubit.totalPrice + cubit.tax)}',
                          style: TextStyle(fontSize: 28),
                        ),
                      ],
                    );
                  }
                });
          },
        ));
  }
}
