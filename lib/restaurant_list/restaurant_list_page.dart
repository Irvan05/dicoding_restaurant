import 'package:dicoding_restaurant/restaurant_details/restaurant_details_page.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_provider.dart';
import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_list/restaurant_list_bloc.dart';
import 'package:dicoding_restaurant/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:animate_icons/animate_icons.dart';

class RestaurantListPage extends StatefulWidget {
  static const routeName = '/restaurant_list/restaurant_list_page';

  const RestaurantListPage({Key? key, required this.isNotification})
      : super(key: key);

  final bool isNotification;

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimateIconController _iconController;

  final _debouncer = Debouncer(milliseconds: 1500);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  final NotificationHelper _notificationHelper = NotificationHelper();
  late final bool _isNotification;

  @override
  void initState() {
    _notificationHelper
        .configureSelectNotificationSubject(RestaurantDetailsPage.routeName);
    _isNotification = widget.isNotification;
    _iconController = AnimateIconController();

    super.initState();
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return (RestaurantListBloc(
          RestaurantListLoading(
              isSearch: false,
              isNotification: _isNotification,
              restaurantView: RestaurantView.allRestaurant),
          RestaurantListProvider(),
          DatabaseProvider())
        ..add(RestaurantListInitialEvent(isNotification: _isNotification)));
    }, child: BlocBuilder<RestaurantListBloc, RestaurantListState>(
        builder: (context, state) {
      sessionDebouncer.run(logOut);
      // if (state is RestaurantListInitial) {
      //   RestaurantListInitial.debouncer.run((() =>
      //       BlocProvider.of<RestaurantListBloc>(context).add(const Logout())));
      // } else {
      //   RestaurantListInitial.debouncer.cancel();
      // }
      return Scaffold(
          key: _scaffoldKey,
          appBar: _appbar(state),
          drawer: _drawer(state),
          body: _body(state));
    }));
  }

  PreferredSizeWidget _appbar(RestaurantListState state) {
    return AppBar(
      actions: [
        AnimateIcons(
          startIcon: Icons.search,
          endIcon: Icons.cancel_outlined,
          size: 30.0,
          controller: _iconController,
          onStartIconPress: () {
            if (state.restaurantView == RestaurantView.allRestaurant) {
              BlocProvider.of<RestaurantListBloc>(_scaffoldKey.currentContext!)
                  .add(const ToggleSearch());
              return true;
            }
            return false;
          },
          onEndIconPress: () {
            if (state.restaurantView == RestaurantView.allRestaurant) {
              BlocProvider.of<RestaurantListBloc>(_scaffoldKey.currentContext!)
                  .add(const ToggleSearch());
              return true;
            }
            return false;
          },
          duration: const Duration(milliseconds: 500),
          startIconColor: state.restaurantView == RestaurantView.favorites
              ? primaryColor
              : Colors.black,
          endIconColor: state.restaurantView == RestaurantView.favorites
              ? primaryColor
              : Colors.black,
          clockwise: false,
        ),
      ],
      title: state.isSearch
          ? _searchBar(_scaffoldKey.currentContext!)
          : Text(
              state.restaurantView == RestaurantView.allRestaurant
                  ? 'All Restaurant'
                  : 'Favorite Restaurant',
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget _body(RestaurantListState state) {
    if (state is RestaurantListLoading) {
      return displayLoading();
    } else if (state is RestaurantListError) {
      return Center(
        child: displayError(state.message, state.errorSource, () {
          _iconController.animateToStart();
          BlocProvider.of<RestaurantListBloc>(_scaffoldKey.currentContext!).add(
            RestaurantListInitialEvent(isNotification: state.isNotification),
          );
        }, true),
      );
    } else if (state is RestaurantListInitial && !state.isSearch) {
      return _restaurantListView(
          state.restaurantList, state.ctr, state.favCtr, state.restaurantView);
    } else if (state is RestaurantListInitial && state.isSearch) {
      return _restaurantListView(state.restaurantListSearch, state.searchCtr,
          state.favSearchCtr, state.restaurantView);
    }
    return Center(
      child: displayError('Undefined state', null, () {}, false),
    );
  }

  Widget _drawer(RestaurantListState state) {
    return Drawer(
        backgroundColor: primaryFadeColor,
        child: ListView(children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: primaryColor,
            child: const Text(
              'View',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            ),
          ),
          InkWell(
            onTap: (() {
              if (_iconController.isEnd()) {
                _iconController.animateToStart();
              }

              if (state.restaurantView != RestaurantView.allRestaurant) {
                BlocProvider.of<RestaurantListBloc>(
                        _scaffoldKey.currentContext!)
                    .add(const ToggleRestaurantView(
                        restaurantView: RestaurantView.allRestaurant));
              }
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                  title: const Text(
                    'All Restaurant',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Radio<RestaurantView>(
                    value: RestaurantView.allRestaurant,
                    groupValue: state.restaurantView,
                    onChanged: ((value) {
                      if (_iconController.isEnd()) {
                        _iconController.animateToStart();
                      }

                      if (state.restaurantView !=
                          RestaurantView.allRestaurant) {
                        BlocProvider.of<RestaurantListBloc>(
                                _scaffoldKey.currentContext!)
                            .add(const ToggleRestaurantView(
                                restaurantView: RestaurantView.allRestaurant));
                      }
                    }),
                  )),
            ),
          ),
          InkWell(
            onTap: (() {
              if (state.restaurantView != RestaurantView.favorites) {
                if (_iconController.isEnd()) {
                  _iconController.animateToStart();
                }
                BlocProvider.of<RestaurantListBloc>(
                        _scaffoldKey.currentContext!)
                    .add(const ToggleRestaurantView(
                        restaurantView: RestaurantView.favorites));
              }
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                  title: const Text(
                    'Favorites',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Radio<RestaurantView>(
                    value: RestaurantView.favorites,
                    groupValue: state.restaurantView,
                    onChanged: ((value) {
                      if (state.restaurantView != RestaurantView.favorites) {
                        if (_iconController.isEnd()) {
                          _iconController.animateToStart();
                        }
                        BlocProvider.of<RestaurantListBloc>(
                                _scaffoldKey.currentContext!)
                            .add(const ToggleRestaurantView(
                                restaurantView: RestaurantView.favorites));
                      }
                    }),
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: primaryColor,
            child: const Text(
              'Setting',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
                title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Restaurant Notification',
                  overflow: TextOverflow.ellipsis,
                ),
                Switch(
                    value: state.isNotification,
                    onChanged: (val) {
                      showDialog(
                          context: navigatorKey.currentContext!,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(
                                  "Are you sure to ${state.isNotification ? 'disable' : 'enable'} notification?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () async {
                                      BlocProvider.of<RestaurantListBloc>(
                                              _scaffoldKey.currentContext!)
                                          .add(ToggleNotification(
                                              isNotification: val));
                                    },
                                    child: const Text('Confirm'))
                              ],
                            );
                          });
                    })
              ],
            )),
          ),
        ]));
  }

  Widget _restaurantListView(List<Restaurant> restaurantList, int ctr,
      int favCtr, RestaurantView view) {
    if (ctr < 1) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: displayError('No restaurant found...', null, () {}, false)),
      );
    } else if (view == RestaurantView.favorites && favCtr < 1) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: displayError('No Favorite yet...', null, () {}, false)),
      );
    } else {
      if (view == RestaurantView.favorites) {
        return AnimatedList(
            key: _listKey,
            initialItemCount: ctr,
            itemBuilder: (context, i, animation) {
              if (restaurantList[i].isFavorite == false) {
                return const SizedBox();
              } else {
                return _buildItemAnimation(
                    i, restaurantList[i], view, animation);
              }
            });
      } else {
        return ListView.builder(
            itemCount: ctr,
            itemBuilder: (context, i) {
              return _buildItem(i, restaurantList[i], view);
            });
      }
    }
  }

  Widget _buildItemAnimation(int index, Restaurant restaurant,
      RestaurantView view, Animation<double> animation) {
    return SizeTransition(
        sizeFactor: animation, child: _buildItem(index, restaurant, view));
  }

  Widget _buildItem(int index, Restaurant restaurant, RestaurantView view) {
    // var state = context.read<RestaurantListState>();
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
      child: Column(
        children: [
          if (restaurant.isMoreInfo)
            InkWell(
              onTap: () {
                BlocProvider.of<RestaurantListBloc>(
                        _scaffoldKey.currentContext!)
                    .add(OpenRestaurantToogle(restaurant: restaurant));
              },
              child: Hero(
                tag: restaurant.pictureId,
                child: Image.network(
                  'https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}',
                  fit: BoxFit.fitWidth,
                ),
              ),
            )
          else
            const SizedBox(),
          ListTile(
            onTap: () {
              BlocProvider.of<RestaurantListBloc>(_scaffoldKey.currentContext!)
                  .add(OpenRestaurantDetails(restaurant: restaurant));
              // BlocProvider.of<RestaurantListBloc>(_scaffoldKey.currentContext!)
              //     .add(OpenRestaurantToogle(restaurant: restaurant));
            },
            leading: SizedBox(
              width: 100,
              child: Stack(
                children: [
                  const Center(child: CircularProgressIndicator()),
                  InkWell(
                    onTap: () {
                      BlocProvider.of<RestaurantListBloc>(
                              _scaffoldKey.currentContext!)
                          .add(OpenRestaurantToogle(restaurant: restaurant));
                    },
                    child: Hero(
                      tag: restaurant.isMoreInfo
                          ? "${restaurant.pictureId}z"
                          : restaurant.pictureId,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImageWithRetry(
                                    "https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}"),
                                fit: BoxFit.cover),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        restaurant.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      child: Icon(
                          restaurant.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: restaurant.isFavorite
                              ? icon2Color
                              : primaryColor),
                      onTap: () {
                        if (view == RestaurantView.favorites &&
                            restaurant.isFavorite) {
                          removeItem(index, restaurant);
                        }
                        BlocProvider.of<RestaurantListBloc>(
                                _scaffoldKey.currentContext!)
                            .add(ToggleFavorite(restaurant: restaurant));
                      },
                    )
                  ],
                )),
            subtitle: Container(
              height: 40,
              padding: const EdgeInsets.only(bottom: 2),
              margin: const EdgeInsets.only(bottom: 3),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: icon1Color,
                          ),
                          Text(" ${restaurant.city}"),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 15,
                            color: icon1Color,
                          ),
                          Text(" ${restaurant.rating}"),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void removeItem(int index, Restaurant restaurant) {
    // ignore: prefer_function_declarations_over_variables
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return _buildItemAnimation(
          index, restaurant, RestaurantView.favorites, animation);
    };
    _listKey.currentState!.removeItem(index, builder);
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: TextField(
        autofocus: true,
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search restaurant...',
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && val != '') {
            _debouncer.run((() => BlocProvider.of<RestaurantListBloc>(context)
                .add(RestaurantSearch(searchString: val.toLowerCase()))));
          } else {
            _debouncer.cancel();
          }
        },
      ),
    );
  }
}
