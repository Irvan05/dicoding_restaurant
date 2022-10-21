import 'package:bloc_test/bloc_test.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_bloc.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_provider.dart';
import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:mocktail/mocktail.dart';

import 'bloc_test_provider.dart';

class RestaurantDetailsProviderMock extends Mock
    implements RestaurantDetailsProvider {}

class DbProviderMock extends Mock implements DatabaseProvider {}

void main() {
  group('restaurant details bloc testing', () {
    late RestaurantDetailsProviderMock restaurantDetailsProviderMock;
    late DbProviderMock dbProviderMock;
    late RestaurantDetailsBloc restaurantDetailsBloc;

    RestaurantDetailsLoading stateLoading = RestaurantDetailsLoading();
    late RestaurantDetailsInitial stateInitial;

    late Map<String, dynamic> restaurantDetailsData;

    setUp(() async {
      restaurantDetailsProviderMock = RestaurantDetailsProviderMock();
      dbProviderMock = DbProviderMock();

      restaurantDetailsBloc = RestaurantDetailsBloc(
          stateLoading, restaurantDetailsProviderMock, dbProviderMock);

      restaurantDetailsData = await fetchRestaurantDetails();
      stateInitial = RestaurantDetailsInitial(
        restaurant: restaurantDetailsData['restaurant'],
        foodsList: restaurantDetailsData['restaurant'].menus!.foods,
        drinksList: restaurantDetailsData['restaurant'].menus!.drinks,
      );
    });

    test('initial test', () {
      expect(restaurantDetailsBloc.state, stateLoading);
    });

    blocTest<RestaurantDetailsBloc, RestaurantDetailsState>('fetching data',
        build: () {
      return restaurantDetailsBloc;
    }, act: (RestaurantDetailsBloc bloc) {
      when(restaurantDetailsProviderMock.getRestaurantDetails)
          .thenAnswer((_) async {
        return restaurantDetailsData;
      });
      when(dbProviderMock.getFavorite).thenAnswer((_) async {
        return List<Restaurant>.empty();
      });
      return bloc.add(const RestaurantDetailsInitialEvent());
    }, expect: () {
      return <RestaurantDetailsState>[stateLoading, stateInitial];
    }, verify: (RestaurantDetailsBloc bloc) {
      verify(restaurantDetailsProviderMock.getRestaurantDetails).called(1);
    });
  });
}
