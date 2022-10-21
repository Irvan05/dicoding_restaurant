import 'package:bloc_test/bloc_test.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_bloc.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_provider.dart';
import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:mocktail/mocktail.dart';

import 'bloc_test_provider.dart';

class RestaurantListProviderMock extends Mock
    implements RestaurantListProvider {}

class DbProviderMock extends Mock implements DatabaseProvider {}

void main() {
  group('restaurant list bloc testing', () {
    late RestaurantListProviderMock restaurantListProviderMock;
    late DbProviderMock dbProviderMock;
    late RestaurantListBloc restaurantListBloc;

    RestaurantListLoading stateLoading = const RestaurantListLoading(
      isSearch: false,
      isNotification: false,
      restaurantView: RestaurantView.allRestaurant,
    );
    late RestaurantListInitial stateInitial;

    late Map<String, dynamic> restaurantListData;

    setUp(() async {
      restaurantListProviderMock = RestaurantListProviderMock();
      dbProviderMock = DbProviderMock();

      restaurantListBloc = RestaurantListBloc(
          stateLoading, restaurantListProviderMock, dbProviderMock);

      restaurantListData = await fetchRestaurant();
      stateInitial = RestaurantListInitial(
          isSearch: false,
          isNotification: false,
          restaurantView: RestaurantView.allRestaurant,
          restaurantList: restaurantListData['restaurant'],
          restaurantListSearch: List<Restaurant>.empty(),
          ctr: restaurantListData['restaurant'].length,
          searchCtr: 0,
          favCtr: 0,
          favSearchCtr: 0);
    });

    test('initial test', () {
      expect(restaurantListBloc.state, stateLoading);
    });

    blocTest<RestaurantListBloc, RestaurantListState>('fetching data',
        build: () {
      return restaurantListBloc;
    }, act: (RestaurantListBloc bloc) {
      when(restaurantListProviderMock.getRestaurantList).thenAnswer((_) async {
        return restaurantListData;
      });
      when(dbProviderMock.getFavorite).thenAnswer((_) async {
        return List<Restaurant>.empty();
      });
      return bloc.add(const RestaurantListInitialEvent(isNotification: false));
    }, expect: () {
      return <RestaurantListState>[stateLoading, stateInitial];
    }, verify: (RestaurantListBloc bloc) {
      verify(restaurantListProviderMock.getRestaurantList).called(1);
    });
  });
}
