import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:dicoding_restaurant/utils/screen_arguments.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_page.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_provider.dart';
import 'package:dicoding_restaurant/utils/shared_pref_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// EVENT //////////////
class RestaurantListEvent extends Equatable {
  const RestaurantListEvent();

  @override
  List<Object> get props => [];
}

class RestaurantListInitialEvent extends RestaurantListEvent {
  final bool isNotification;
  const RestaurantListInitialEvent({required this.isNotification});
}

class ToggleSearch extends RestaurantListEvent {
  const ToggleSearch();
}

class RestaurantSearch extends RestaurantListEvent {
  final String searchString;
  const RestaurantSearch({required this.searchString});
}

class OpenRestaurantDetails extends RestaurantListEvent {
  final Restaurant restaurant;
  const OpenRestaurantDetails({required this.restaurant});
}

class ToggleNotification extends RestaurantListEvent {
  final bool isNotification;
  const ToggleNotification({required this.isNotification});
}

class ToggleFavorite extends RestaurantListEvent {
  final Restaurant restaurant;
  const ToggleFavorite({required this.restaurant});
}

class ToggleRestaurantView extends RestaurantListEvent {
  final RestaurantView restaurantView;
  const ToggleRestaurantView({required this.restaurantView});
}

////////////////////////
// STATE //////////////////////
abstract class RestaurantListState extends Equatable {
  final bool isSearch;
  final bool isNotification;
  final RestaurantView restaurantView;

  const RestaurantListState(
      {required this.isSearch,
      required this.isNotification,
      required this.restaurantView});
  @override
  List<Object> get props => [isSearch, isNotification, restaurantView];
}

class RestaurantListLoading extends RestaurantListState {
  const RestaurantListLoading(
      {required super.isSearch,
      required super.isNotification,
      required super.restaurantView});
}

class RestaurantListError extends RestaurantListState {
  final String message;
  final String errorSource;

  const RestaurantListError(
      {required super.isSearch,
      required super.isNotification,
      required super.restaurantView,
      required this.message,
      required this.errorSource});
}

class RestaurantListInitial extends RestaurantListState {
  final List<Restaurant> restaurantList;
  final List<Restaurant> restaurantListSearch;
  final int ctr;
  final int searchCtr;
  final int favCtr;
  final int favSearchCtr;

  const RestaurantListInitial(
      {required super.isSearch,
      required super.isNotification,
      required super.restaurantView,
      required this.restaurantList,
      required this.restaurantListSearch,
      required this.ctr,
      required this.searchCtr,
      required this.favCtr,
      required this.favSearchCtr});
}

////////////////////////
// BLOC ////////////////////////////////////
class RestaurantListBloc
    extends Bloc<RestaurantListEvent, RestaurantListState> {
  RestaurantListProvider provider;
  DatabaseProvider dbProvider;
  RestaurantListBloc(
      RestaurantListState initialState, this.provider, this.dbProvider)
      : super(initialState) {
    on<RestaurantListInitialEvent>(_loadingInitial);
    on<ToggleSearch>(_toggleSearch);
    on<RestaurantSearch>(_restaurantSearch);
    on<OpenRestaurantDetails>(_openRestaurantDetails);
    on<ToggleNotification>(_toggleNotification);
    on<ToggleFavorite>(_toggleFavorite);
    on<ToggleRestaurantView>(_toggleRestaurantView);
  }

  void _loadingInitial(RestaurantListInitialEvent event,
      Emitter<RestaurantListState> emit) async {
    emit(RestaurantListLoading(
        isSearch: false,
        isNotification: event.isNotification,
        restaurantView: RestaurantView.allRestaurant));
    try {
      Map<String, dynamic> restaurantListData =
          await provider.getRestaurantList();
      if (restaurantListData['error'] == null ||
          restaurantListData['error'] == false) {
        List<Restaurant> restaurantList = restaurantListData['restaurant'];
        var restaurantListSearch = List<Restaurant>.empty();

        List<Restaurant> favorites = await dbProvider.getFavorite();
        restaurantList = setLocalFavorite(favorites, restaurantList);

        emit(RestaurantListInitial(
            isSearch: false,
            isNotification: event.isNotification,
            restaurantView: RestaurantView.allRestaurant,
            restaurantList: restaurantList,
            restaurantListSearch: restaurantListSearch,
            ctr: restaurantListData['ctr'],
            searchCtr: 0,
            favCtr: favorites.length,
            favSearchCtr: 0));
      } else if (restaurantListData['error'] != null) {
        emit(RestaurantListError(
            isSearch: false,
            isNotification: event.isNotification,
            restaurantView: RestaurantView.allRestaurant,
            message: restaurantListData['error'],
            errorSource: restaurantListData['errorSource']));
      } else {
        throw ('_loadingInitial error');
      }
    } catch (e) {
      emit(RestaurantListError(
          isSearch: false,
          isNotification: false,
          restaurantView: RestaurantView.allRestaurant,
          message: e.toString(),
          errorSource: '_loadingInitial catch'));
    }
  }

  void _toggleSearch(
      ToggleSearch event, Emitter<RestaurantListState> emit) async {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;
      emit(RestaurantListLoading(
        isSearch: currentState.isSearch,
        isNotification: currentState.isNotification,
        restaurantView: currentState.restaurantView,
      ));

      emit(RestaurantListInitial(
          isSearch: !currentState.isSearch,
          isNotification: currentState.isNotification,
          restaurantView: currentState.restaurantView,
          restaurantList: currentState.restaurantList,
          restaurantListSearch: currentState.restaurantListSearch,
          ctr: currentState.ctr,
          searchCtr: currentState.searchCtr,
          favCtr: currentState.favCtr,
          favSearchCtr: currentState.favSearchCtr));
    }
  }

  void _restaurantSearch(
      RestaurantSearch event, Emitter<RestaurantListState> emit) async {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;
      emit(RestaurantListLoading(
        isSearch: currentState.isSearch,
        isNotification: currentState.isNotification,
        restaurantView: currentState.restaurantView,
      ));

      try {
        Map<String, dynamic> restaurantSearchData =
            await provider.searchRestaurant(event.searchString);

        if (restaurantSearchData['error'] == null) {
          List<Restaurant> restaurantListSearch =
              restaurantSearchData['restaurant'];

          List<Restaurant> favorites = await dbProvider.getFavorite();
          int favSearCtr = 0;
          for (Restaurant r in favorites) {
            int index = restaurantListSearch.indexWhere((element) {
              return element.id == r.id;
            });
            if (index >= 0) {
              favSearCtr++;
              restaurantListSearch[index].isFavorite = true;
            }
          }

          emit(RestaurantListInitial(
              isSearch: currentState.isSearch,
              isNotification: currentState.isNotification,
              restaurantView: currentState.restaurantView,
              restaurantList: currentState.restaurantList,
              restaurantListSearch: restaurantListSearch,
              ctr: currentState.ctr,
              searchCtr: restaurantSearchData['searchCtr'],
              favCtr: currentState.favCtr,
              favSearchCtr: favSearCtr));
        } else if (restaurantSearchData['error'] != null) {
          emit(RestaurantListError(
              isSearch: currentState.isSearch,
              isNotification: currentState.isNotification,
              restaurantView: currentState.restaurantView,
              message: restaurantSearchData['error'],
              errorSource: restaurantSearchData['errorSource']));
        } else {
          throw ('_restaurantSearch error');
        }
      } catch (e) {
        emit(RestaurantListError(
            isSearch: currentState.isSearch,
            isNotification: currentState.isNotification,
            restaurantView: currentState.restaurantView,
            message: e.toString(),
            errorSource: '_mapRestaurantSearchToState catch'));
      }
    }
  }

  void _openRestaurantDetails(
      OpenRestaurantDetails event, Emitter<RestaurantListState> emit) async {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;

      bool initFav = event.restaurant.isFavorite;
      final returnData = await Navigator.pushNamed(
          navigatorKey.currentContext!, RestaurantDetailsPage.routeName,
          arguments: RestaurantDetailsPageArguments(
              restaurant: event.restaurant, isFromList: true)) as Restaurant;

      if (initFav != returnData.isFavorite) {
        emit(RestaurantListLoading(
          isSearch: currentState.isSearch,
          isNotification: currentState.isNotification,
          restaurantView: currentState.restaurantView,
        ));

        List<Restaurant> restaurantList = currentState.restaurantList;
        int favCtr = currentState.favCtr;
        int favSearchCtr = 0;

        int index = restaurantList.indexWhere((element) {
          return element.id == returnData.id;
        });
        restaurantList[index].isFavorite = returnData.isFavorite;
        if (returnData.isFavorite) {
          favCtr++;
        } else {
          favCtr--;
        }

        if (currentState.searchCtr > 0) {
          List<Restaurant> restaurantListSearch =
              currentState.restaurantListSearch;
          favSearchCtr = currentState.favSearchCtr;

          int index2 = restaurantListSearch.indexWhere((element) {
            return element.id == returnData.id;
          });
          if (index2 >= 0) {
            if (returnData.isFavorite) {
              favSearchCtr++;
            } else {
              favSearchCtr--;
            }
            restaurantListSearch[index2].isFavorite = returnData.isFavorite;
          }
        }

        emit(RestaurantListInitial(
            isSearch: currentState.isSearch,
            isNotification: currentState.isNotification,
            restaurantView: currentState.restaurantView,
            restaurantList: restaurantList,
            restaurantListSearch: currentState.restaurantListSearch,
            ctr: currentState.ctr,
            searchCtr: currentState.searchCtr,
            favCtr: favCtr,
            favSearchCtr: favSearchCtr));
      }
    }
  }

  void _toggleNotification(
      ToggleNotification event, Emitter<RestaurantListState> emit) async {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;
      emit(RestaurantListLoading(
        isSearch: currentState.isSearch,
        isNotification: currentState.isNotification,
        restaurantView: currentState.restaurantView,
      ));

      bool isNotification = await saveSettings(event.isNotification);
      emit(RestaurantListInitial(
          isSearch: currentState.isSearch,
          isNotification: isNotification,
          restaurantView: currentState.restaurantView,
          restaurantList: currentState.restaurantList,
          restaurantListSearch: currentState.restaurantListSearch,
          ctr: currentState.ctr,
          searchCtr: currentState.searchCtr,
          favCtr: currentState.favCtr,
          favSearchCtr: currentState.favSearchCtr));
      Navigator.pop(navigatorKey.currentContext!);
    }
  }

  void _toggleFavorite(
      ToggleFavorite event, Emitter<RestaurantListState> emit) async {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;
      emit(RestaurantListLoading(
          isSearch: currentState.isSearch,
          isNotification: currentState.isNotification,
          restaurantView: currentState.restaurantView));

      bool toggle = !event.restaurant.isFavorite;

      try {
        var restaurantList = currentState.restaurantList;
        int favSearchCtr = currentState.favSearchCtr;
        int index = restaurantList.indexWhere((element) {
          return element.id == event.restaurant.id;
        });
        restaurantList[index].isFavorite = toggle;

        var restaurantListSearch = currentState.restaurantListSearch;
        int indexSearch = restaurantListSearch
            .indexWhere((element) => element.id == event.restaurant.id);
        if (indexSearch >= 0) {
          if (toggle) {
            favSearchCtr++;
          } else {
            favSearchCtr--;
          }
          restaurantListSearch[indexSearch].isFavorite = toggle;
        }

        dbProvider.setFavorite(restaurantList[index]);

        emit(RestaurantListInitial(
            isSearch: currentState.isSearch,
            isNotification: currentState.isNotification,
            restaurantView: currentState.restaurantView,
            restaurantList: currentState.restaurantList,
            restaurantListSearch: currentState.restaurantListSearch,
            ctr: currentState.ctr,
            searchCtr: currentState.searchCtr,
            favCtr: toggle ? currentState.favCtr + 1 : currentState.favCtr - 1,
            favSearchCtr: favSearchCtr));
      } catch (e) {
        emit(RestaurantListError(
            isSearch: currentState.isSearch,
            isNotification: currentState.isNotification,
            restaurantView: currentState.restaurantView,
            message: e.toString(),
            errorSource: '_toggleFavorite catch'));
      }
    }
  }

  void _toggleRestaurantView(
      ToggleRestaurantView event, Emitter<RestaurantListState> emit) {
    if (state is RestaurantListInitial) {
      RestaurantListInitial currentState = state as RestaurantListInitial;
      emit(RestaurantListLoading(
        isSearch: false,
        isNotification: currentState.isNotification,
        restaurantView: event.restaurantView,
      ));

      emit(RestaurantListInitial(
          isSearch: false,
          isNotification: currentState.isNotification,
          restaurantView: event.restaurantView,
          restaurantList: currentState.restaurantList,
          restaurantListSearch: currentState.restaurantListSearch,
          ctr: currentState.ctr,
          searchCtr: currentState.searchCtr,
          favCtr: currentState.favCtr,
          favSearchCtr: currentState.favSearchCtr));
    }
  }

  List<Restaurant> setLocalFavorite(
      List<Restaurant> favorites, List<Restaurant> restaurantList) {
    var returnList = restaurantList;

    for (Restaurant r in favorites) {
      int index = restaurantList.indexWhere((element) {
        return element.id == r.id;
      });
      returnList[index].isFavorite = true;
    }
    return returnList;
  }
}
