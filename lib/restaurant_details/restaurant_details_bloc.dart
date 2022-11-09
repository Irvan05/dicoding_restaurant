import 'package:dicoding_restaurant/cart/cart_page.dart';
import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_provider.dart';
import 'package:dicoding_restaurant/restaurant_review/restaurant_review_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// EVENT //////////////
class RestaurantDetailsEvent extends Equatable {
  const RestaurantDetailsEvent();

  @override
  List<Object> get props => [];
}

class RestaurantDetailsInitialEvent extends RestaurantDetailsEvent {
  const RestaurantDetailsInitialEvent();
}

class SearchBoxReset extends RestaurantDetailsEvent {
  final bool isFood;
  const SearchBoxReset({required this.isFood});
}

class SearchBoxQuery extends RestaurantDetailsEvent {
  final bool isFood;
  final String searchString;
  const SearchBoxQuery({required this.isFood, required this.searchString});
}

class OpenReviewPage extends RestaurantDetailsEvent {
  final Restaurant restaurant;
  const OpenReviewPage({required this.restaurant});
}

class ToggleFavorite extends RestaurantDetailsEvent {
  final Restaurant restaurant;
  const ToggleFavorite({required this.restaurant});
}

class AddToCart extends RestaurantDetailsEvent {
  final MenuDetails item;
  const AddToCart({required this.item});
}

class OpenCart extends RestaurantDetailsEvent {
  const OpenCart();
}

////////////////////////
// STATE //////////////////////
abstract class RestaurantDetailsState extends Equatable {
  final List<MenuDetails> cartItem;

  const RestaurantDetailsState({required this.cartItem});

  @override
  List<Object> get props => [];
}

class RestaurantDetailsLoading extends RestaurantDetailsState {
  RestaurantDetailsLoading({required super.cartItem});
}

class RestaurantDetailsError extends RestaurantDetailsState {
  final String message;
  final String errorSource;

  RestaurantDetailsError(
      {required this.message,
      required this.errorSource,
      required super.cartItem});
}

class RestaurantDetailsInitial extends RestaurantDetailsState {
  final Restaurant restaurant;
  final List<MenuDetails> foodsList;
  final List<MenuDetails> drinksList;

  RestaurantDetailsInitial(
      {required this.restaurant,
      required this.foodsList,
      required this.drinksList,
      required super.cartItem});
}

////////////////////////
// BLOC ////////////////////////////////////
class RestaurantDetailsBloc
    extends Bloc<RestaurantDetailsEvent, RestaurantDetailsState> {
  RestaurantDetailsProvider provider;
  DatabaseProvider dbProvider;
  RestaurantDetailsBloc(
      RestaurantDetailsState initialState, this.provider, this.dbProvider)
      : super(initialState) {
    on<RestaurantDetailsInitialEvent>(_loadingInitial);
    on<SearchBoxReset>(_searchBoxReset);
    on<SearchBoxQuery>(_searchBoxQuery);
    on<OpenReviewPage>(_openReviewPage);
    on<ToggleFavorite>(_toggleFavorite);
    on<AddToCart>(_addToCart);
    on<OpenCart>(_openCart);
  }

  void _openCart(OpenCart event, Emitter<RestaurantDetailsState> emit) {
    if (state is RestaurantDetailsInitial) {
      Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => CartPage(
              cartItems: state.cartItem,
            ),
          ));
    }
  }

  void _addToCart(AddToCart event, Emitter<RestaurantDetailsState> emit) {
    if (state is RestaurantDetailsInitial) {
      RestaurantDetailsInitial currentState = state as RestaurantDetailsInitial;
      emit(RestaurantDetailsLoading(cartItem: state.cartItem));

      List<MenuDetails> temp = List<MenuDetails>.empty(growable: true);
      //state.cartItem;
      temp.addAll(state.cartItem);
      temp.add(event.item);
      emit(RestaurantDetailsInitial(
          restaurant: currentState.restaurant,
          foodsList: currentState.foodsList,
          drinksList: currentState.drinksList,
          cartItem: temp));
    }
  }

  void _toggleFavorite(
      ToggleFavorite event, Emitter<RestaurantDetailsState> emit) {
    if (state is RestaurantDetailsInitial) {
      RestaurantDetailsInitial currentState = state as RestaurantDetailsInitial;
      emit(RestaurantDetailsLoading(cartItem: state.cartItem));
      var restaurant = event.restaurant;
      bool toggle = !event.restaurant.isFavorite;
      restaurant.isFavorite = toggle;

      dbProvider.setFavorite(restaurant);

      emit(RestaurantDetailsInitial(
          restaurant: currentState.restaurant,
          foodsList: currentState.foodsList,
          drinksList: currentState.drinksList,
          cartItem: state.cartItem));
    }
  }

  void _openReviewPage(
      OpenReviewPage event, Emitter<RestaurantDetailsState> emit) async {
    Navigator.pushNamed(
      navigatorKey.currentContext!,
      RestaurantReviewPage.routeName,
      arguments: event.restaurant,
    );
  }

  void _searchBoxQuery(
      SearchBoxQuery event, Emitter<RestaurantDetailsState> emit) async {
    if (state is RestaurantDetailsInitial) {
      RestaurantDetailsInitial currentState = state as RestaurantDetailsInitial;
      emit(RestaurantDetailsLoading(cartItem: state.cartItem));

      List<MenuDetails> foodsList = currentState.foodsList;
      List<MenuDetails> drinksList = currentState.drinksList;
      Restaurant restaurantDetails = currentState.restaurant;
      if (restaurantDetails.menus != null) {
        if (event.isFood) {
          foodsList = currentState.restaurant.menus!.foods
              .where((menu) => menu.name
                  .toLowerCase()
                  .contains(event.searchString.toLowerCase()))
              .toList();
        } else {
          drinksList = currentState.restaurant.menus!.drinks
              .where((drinks) => drinks.name
                  .toLowerCase()
                  .contains(event.searchString.toLowerCase()))
              .toList();
        }
      }
      emit(RestaurantDetailsInitial(
          restaurant: restaurantDetails,
          foodsList: foodsList,
          drinksList: drinksList,
          cartItem: state.cartItem));
    }
  }

  void _searchBoxReset(
      SearchBoxReset event, Emitter<RestaurantDetailsState> emit) async {
    if (state is RestaurantDetailsInitial) {
      RestaurantDetailsInitial currentState = state as RestaurantDetailsInitial;
      emit(RestaurantDetailsLoading(cartItem: state.cartItem));

      List<MenuDetails> foodsList = currentState.foodsList;
      List<MenuDetails> drinksList = currentState.drinksList;
      Restaurant restaurantDetails = currentState.restaurant;

      if (restaurantDetails.menus != null) {
        if (event.isFood) {
          foodsList = restaurantDetails.menus!.foods;
        } else {
          drinksList = restaurantDetails.menus!.drinks;
        }
      }
      emit(RestaurantDetailsInitial(
          restaurant: restaurantDetails,
          foodsList: foodsList,
          drinksList: drinksList,
          cartItem: state.cartItem));
    }
  }

  void _loadingInitial(RestaurantDetailsInitialEvent event,
      Emitter<RestaurantDetailsState> emit) async {
    emit(RestaurantDetailsLoading(cartItem: state.cartItem));
    try {
      Map<String, dynamic> restaurantDetailsData =
          await provider.getRestaurantDetails();

      if (restaurantDetailsData['error'] == null ||
          restaurantDetailsData['error'] == false) {
        Restaurant restaurantDetails = restaurantDetailsData['restaurant'];

        List<MenuDetails> foodsList = List<MenuDetails>.empty(growable: true);
        List<MenuDetails> drinksList = List<MenuDetails>.empty(growable: true);

        if (restaurantDetails.menus != null) {
          foodsList = restaurantDetails.menus!.foods;
          drinksList = restaurantDetails.menus!.drinks;
        }

        var favorites = await dbProvider.getFavorite();
        int index = favorites.indexWhere((element) {
          return element.id == restaurantDetails.id;
        });
        if (index > 0) {
          restaurantDetails.isFavorite = true;
        }

        emit(RestaurantDetailsInitial(
            restaurant: restaurantDetails,
            foodsList: foodsList,
            drinksList: drinksList,
            cartItem: state.cartItem));
      } else if (restaurantDetailsData['error'] != null) {
        emit(RestaurantDetailsError(
            message: restaurantDetailsData['error'],
            errorSource: restaurantDetailsData['errorSource'],
            cartItem: state.cartItem));
      } else {
        throw ('_mapRestaurantDetailsLoadingInitialToState error');
      }
    } catch (e) {
      emit(RestaurantDetailsError(
          message: e.toString(),
          errorSource: '_mapRestaurantDetailsLoadingInitialToState catch',
          cartItem: state.cartItem));
    }
  }
}
