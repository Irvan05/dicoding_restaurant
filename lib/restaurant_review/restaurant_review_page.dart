import 'package:dicoding_restaurant/utils/globals.dart';
import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_review/restaurant_review_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RestaurantReviewPage extends StatefulWidget {
  static const routeName = '/restaurant_review/restaurant_review_page';
  const RestaurantReviewPage({Key? key, required this.restaurant})
      : super(key: key);

  final Restaurant restaurant;

  @override
  State<RestaurantReviewPage> createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  late Restaurant _restaurant;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _restaurant = widget.restaurant;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return (RestaurantReviewBloc(
          RestaurantReviewInitial(restaurant: _restaurant)));
    }, child: BlocBuilder<RestaurantReviewBloc, RestaurantReviewState>(
        builder: (context, state) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Reviews'),
              const Spacer(),
              const Icon(Icons.star, size: 20, color: icon1Color),
              Text("${_restaurant.rating}"),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _reviewModal();
                },
                icon: const Icon(Icons.rate_review_outlined))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: state is RestaurantReviewInitial &&
                  state.restaurant.customerReviews != null
              ? ListView(
                  scrollDirection: Axis.vertical,
                  children: state.restaurant.customerReviews!.map((r) {
                    return _reviewCard(r);
                  }).toList(),
                )
              : state is RestaurantReviewLoading
                  ? displayLoading()
                  : const Center(
                      child: OutlinedText(
                        title: 'No reviews yet...',
                        bgColor: Colors.white,
                        fgColor: Colors.black,
                        fontSize: 24,
                        strokeWidth: 1,
                      ),
                    ),
        ),
      );
    }));
  }

  Future _reviewModal() {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const OutlinedText(
              title: 'Write a Review',
              bgColor: Colors.white,
              fgColor: Colors.black,
              fontSize: 20,
              strokeWidth: 1,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Name...',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _reviewController,
                minLines: 4,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Review...',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _nameController.text = '';
                          _reviewController.text = '';
                        },
                        child: const Text('Cancel')),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          BlocProvider.of<RestaurantReviewBloc>(
                                  _scaffoldKey.currentContext!)
                              .add(PostReview(
                                  name: _nameController.text,
                                  review: _reviewController.text));
                        },
                        child: const Text('Submit')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(CustomerReview r) {
    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 20, color: primaryColor),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        r.date,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(
                thickness: 1,
              ),
              Container(
                padding: const EdgeInsets.all(3),
                child: Text(
                  r.review,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
