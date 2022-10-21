import 'package:collection/collection.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_provider.dart';
import 'package:dicoding_restaurant/utils/database_provider.dart';
import 'package:dicoding_restaurant/utils/screen_arguments.dart';
import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_details/restaurant_details_bloc.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class RestaurantDetailsPage extends StatefulWidget {
  static const routeName = '/restaurant_details/restaurant_details_page';

  const RestaurantDetailsPage({Key? key, required this.arguments})
      : super(key: key);

  final RestaurantDetailsPageArguments arguments;

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage>
    with SingleTickerProviderStateMixin {
  double _top = 0.0;
  bool _isExpanded = false;
  late bool _isFromList;

  final TextEditingController _foodSearchController = TextEditingController();
  final TextEditingController _drinkSearchController = TextEditingController();
  late AutoScrollController _autoScrollController;

  late Restaurant _restaurant;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _restaurant = widget.arguments.restaurant;
    _isFromList = widget.arguments.isFromList;

    _autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  void dispose() {
    _foodSearchController.dispose();
    _drinkSearchController.dispose();
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return (RestaurantDetailsBloc(RestaurantDetailsLoading(),
          RestaurantDetailsProvider(_restaurant.id), DatabaseProvider())
        ..add(const RestaurantDetailsInitialEvent()));
    }, child: BlocBuilder<RestaurantDetailsBloc, RestaurantDetailsState>(
        builder: (context, state) {
      return Scaffold(
        key: _scaffoldKey,
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, _restaurant);
            return true;
          },
          child: CustomScrollView(
              controller: _autoScrollController, slivers: _sliverList(state)),
        ),
      );
    }));
  }

  List<Widget> _sliverList(RestaurantDetailsState state) {
    List<Widget> returnWidget = [];

    // HEADER ////////////////////////////
    if (state is RestaurantDetailsLoading && !_isFromList) {
      returnWidget.add(SliverToBoxAdapter(
          child:
              SafeArea(child: SizedBox(height: 200, child: displayLoading()))));
    } else {
      returnWidget.add(SliverAppBar(
        pinned: true,
        expandedHeight: 200,
        flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          Future.delayed(Duration.zero, () {
            setState(() {
              _top = constraints.biggest.height;
            });
          });
          return _headerPic(state);
        }),
      ));
    }

    // MAIN BODY ////////////////////////////////
    returnWidget.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    // CATEGORIES //////////////////////////////////
                    state is RestaurantDetailsInitial &&
                            state.restaurant.category != null &&
                            state.restaurant.category!.isNotEmpty
                        ? _displayCategories(state.restaurant)
                        : const SizedBox(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 20,
                            color: icon1Color,
                          ),
                          Text(_restaurant.city),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 20, color: icon1Color),
                          Text("${_restaurant.rating}"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (state is RestaurantDetailsInitial) {
                          BlocProvider.of<RestaurantDetailsBloc>(
                                  _scaffoldKey.currentContext!)
                              .add(
                                  OpenReviewPage(restaurant: state.restaurant));
                        }
                      },
                      child: const Text(
                        'Reviews',
                        style: TextStyle(color: Colors.blue),
                      ))
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          // DESCRIPTION ///////////////////////
          _descriptionWidget(context),
        ]),
      ),
    ));

    // FOODS /////////////////////////////////////
    if (state is RestaurantDetailsInitial &&
        state.restaurant.menus != null &&
        state.restaurant.menus!.foods.isNotEmpty) {
      returnWidget.add(_header(true, state.foodsList.length));

      if (state.foodsList.isNotEmpty) {
        returnWidget.add(SliverGrid.count(
          childAspectRatio: (MediaQuery.of(context).size.width / 2 - 20) / 170,
          crossAxisCount: 2,
          children: state.foodsList
              .mapIndexed(
                  (index, menuDetails) => _buildGrid(menuDetails, index))
              .toList(),
        ));
      } else {
        _emptyGrid(state.foodsList.length);
      }
    }

    // DRINKS /////////////////////////////////////
    if (state is RestaurantDetailsInitial &&
        state.restaurant.menus != null &&
        state.restaurant.menus!.drinks.isNotEmpty) {
      returnWidget.add(_header(false, state.foodsList.length));
      if (state.drinksList.isNotEmpty) {
        returnWidget.add(SliverGrid.count(
          childAspectRatio: (MediaQuery.of(context).size.width / 2 - 20) / 170,
          crossAxisCount: 2,
          children: state.drinksList
              .mapIndexed((index, menuDetails) =>
                  _buildGrid(menuDetails, state.foodsList.length + 1 + index))
              .toList(),
        ));
      } else {
        returnWidget.add(_emptyGrid(state.foodsList.length + 1));
      }
    }

    // ERROR HANDLING /////////////////////////////////////
    if (state is RestaurantDetailsInitial) {
      returnWidget.add(const SliverToBoxAdapter());
    } else if (state is RestaurantDetailsLoading) {
      returnWidget.add(SliverToBoxAdapter(child: displayLoading()));
    } else if (state is RestaurantDetailsError) {
      returnWidget.add(SliverToBoxAdapter(
        child: displayError(
            state.message,
            null,
            () => BlocProvider.of<RestaurantDetailsBloc>(context)
                .add(const RestaurantDetailsInitialEvent()),
            true),
      ));
    } else {
      returnWidget.add(SliverToBoxAdapter(
          child: displayError('Undefined state', null, () {}, false)));
    }

    return (returnWidget);
  }

  Widget _displayCategories(Restaurant restaurant) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: restaurant.category!.map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Center(
              child: Text(
                category.name,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _headerPic(RestaurantDetailsState state) {
    return FlexibleSpaceBar(
      background: Stack(
        children: [
          Container(
            color: primaryFadeColor,
            child: Stack(
              children: [
                const Center(child: CircularProgressIndicator()),
                Hero(
                  tag: _restaurant.pictureId,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImageWithRetry(
                              'https://restaurant-api.dicoding.dev/images/medium/${_restaurant.pictureId}'),
                          fit: BoxFit.cover),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          (state is RestaurantDetailsInitial)
              ? Container(
                  padding: const EdgeInsets.all(12),
                  height: _top,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SafeArea(
                      child: FavoriteButton(
                          iconSize: 60,
                          isFavorite: state.restaurant.isFavorite,
                          valueChanged: (_) {
                            BlocProvider.of<RestaurantDetailsBloc>(
                                    _scaffoldKey.currentContext!)
                                .add(ToggleFavorite(restaurant: _restaurant));
                          }),
                    ),
                  ))
              : const SizedBox()
        ],
      ),
      title: _top <= MediaQuery.of(context).padding.top + kToolbarHeight
          ? Text(_restaurant.name,
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ))
          : OutlinedText(
              bgColor: Colors.white,
              fgColor: Colors.black,
              fontSize: 24,
              strokeWidth: 1,
              title: _restaurant.name,
            ),
      centerTitle: true,
      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
    );
  }

  SliverPersistentHeader _header(bool isFood, int foodLength) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 50,
        maxHeight: 50,
        child: Container(
          height: 51,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: secondaryColor,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0, 2),
              ),
            ],
            color: primaryColor,
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 5),
            margin: const EdgeInsets.only(left: 10, right: 5),
            child: TextField(
              autofocus: false,
              controller:
                  isFood ? _foodSearchController : _drinkSearchController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    color: secondaryColor,
                    onPressed: () {
                      BlocProvider.of<RestaurantDetailsBloc>(
                              _scaffoldKey.currentContext!)
                          .add(SearchBoxReset(isFood: isFood));
                      setState(() {
                        if (isFood) {
                          _foodSearchController.text = '';
                          _scrollToCounter(0);
                        } else {
                          _drinkSearchController.text = '';
                          _scrollToCounter(foodLength + 1);
                        }
                      });
                    },
                    icon: const Icon(Icons.cancel_outlined)),
                hintText: isFood ? 'Search Foods...' : 'Search Drinks...',
                hintStyle: const TextStyle(
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
                BlocProvider.of<RestaurantDetailsBloc>(
                        _scaffoldKey.currentContext!)
                    .add(SearchBoxQuery(isFood: isFood, searchString: val));
                setState(() {
                  if (isFood) {
                    _scrollToCounter(0);
                  } else {
                    _scrollToCounter(foodLength + 1);
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(MenuDetails menuDetails, int index) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coming soon...'),
            duration: Duration(seconds: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: Image.asset(
                        'assets/images/menu_empty.png',
                        fit: BoxFit.cover,
                      ).image,
                      fit: BoxFit.cover),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                menuDetails.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Rp -',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _emptyGrid(int index) {
    return SliverToBoxAdapter(
        child: AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: const Center(child: Text('No Menu found...')),
    ));
  }

  Widget _descriptionWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          _restaurant.description,
          maxLines: _isExpanded ? 100 : 4,
          textAlign: TextAlign.justify,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                _isExpanded ? "show less" : "show more",
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }

  Future _scrollToCounter(int index) async {
    await _autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    _autoScrollController.highlight(0);
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent;
  }
}
