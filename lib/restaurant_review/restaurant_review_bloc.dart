import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:dicoding_restaurant/restaurant_review/restaurant_review_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// EVENT //////////////
class RestaurantReviewEvent extends Equatable {
  const RestaurantReviewEvent();

  @override
  List<Object> get props => [];
}

class PostReview extends RestaurantReviewEvent {
  final String name;
  final String review;
  const PostReview({required this.name, required this.review});
}

////////////////////////
//  STATE //////////////////////
abstract class RestaurantReviewState {}

class RestaurantReviewLoading extends RestaurantReviewState {
  RestaurantReviewLoading();
}

class RestaurantReviewError extends RestaurantReviewState {
  String message;
  String errorSource;

  RestaurantReviewError({required this.message, required this.errorSource});
}

class RestaurantReviewInitial extends RestaurantReviewState {
  Restaurant restaurant;

  RestaurantReviewInitial({required this.restaurant});
}

////////////////////////
// BLOC ////////////////////////////////////
class RestaurantReviewBloc
    extends Bloc<RestaurantReviewEvent, RestaurantReviewState> {
  RestaurantReviewBloc(RestaurantReviewState initialState)
      : super(initialState) {
    on<PostReview>(_postReview);
  }

  void _postReview(event, Emitter<RestaurantReviewState> emit) async {
    if (state is RestaurantReviewInitial) {
      RestaurantReviewInitial currentState = state as RestaurantReviewInitial;
      emit(RestaurantReviewLoading());
      try {
        Map<String, dynamic> postReviewData = await postReview(
            currentState.restaurant.id, event.name, event.review);

        if (postReviewData['error'] == null ||
            postReviewData['error'] == false) {
          List<CustomerReview> reviewList = List<CustomerReview>.from(
              postReviewData["json"].map((x) => CustomerReview.fromJson(x)));

          Restaurant restaurant = currentState.restaurant;
          restaurant.customerReviews = reviewList;

          emit(RestaurantReviewInitial(restaurant: restaurant));
        } else if (postReviewData['error'] != null) {
          emit(RestaurantReviewError(
              message: postReviewData['error'],
              errorSource: postReviewData['errorSource']));
        } else {
          throw ('_mapPostReviewToState error');
        }
      } catch (e) {
        emit(RestaurantReviewError(
            message: e.toString(), errorSource: '_mapPostReviewToState catch'));
      }
    }
  }
}
