import 'dart:convert';

class RestaurantList {
  RestaurantList({
    required this.error,
    required this.message,
    required this.ctr,
    required this.restaurants,
  });

  bool error;
  String message;
  int ctr;
  List<Restaurant> restaurants;

  factory RestaurantList.fromRawJson(String str) =>
      RestaurantList.fromJson(json.decode(str));

  factory RestaurantList.fromRawJsonSearch(String str) =>
      RestaurantList.fromJsonSearch(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestaurantList.fromJson(Map<String, dynamic> json) => RestaurantList(
        error: json["error"],
        message: json["message"],
        ctr: json["count"],
        restaurants: List<Restaurant>.from(
            json["restaurants"].map((x) => Restaurant.fromAPIList(x))),
      );

  factory RestaurantList.fromJsonSearch(Map<String, dynamic> json) =>
      RestaurantList(
          error: json["error"],
          message: '',
          ctr: json["founded"],
          restaurants: List<Restaurant>.from(
              json["restaurants"].map((x) => Restaurant.fromAPIList(x))));

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "count": ctr,
        "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
      };
}

class Restaurant {
  Restaurant(
      {required this.id,
      required this.name,
      required this.description,
      required this.pictureId,
      required this.city,
      required this.rating,
      required this.isFavorite,
      this.menus,
      this.category,
      this.customerReviews});

  String id;
  String name;
  String description;
  String pictureId;
  String city;
  double rating;
  bool isFavorite;
  Menus? menus;
  List<Category>? category;
  List<CustomerReview>? customerReviews;

  factory Restaurant.fromAPIList(Map<String, dynamic> json) {
    return Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        pictureId: json["pictureId"],
        city: json["city"],
        rating: json["rating"].toDouble(),
        isFavorite: false);
  }
  factory Restaurant.fromDBList(Map<String, dynamic> json) {
    return Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        pictureId: json["pictureId"],
        city: json["city"],
        rating: json["rating"].toDouble(),
        isFavorite: json['isFavorite'] == 1 ? true : false);
  }
  factory Restaurant.fromAPIDetails(Map<String, dynamic> json) {
    return Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        pictureId: json["pictureId"],
        city: json["city"],
        rating: json["rating"].toDouble(),
        isFavorite: false,
        menus: Menus.fromJson(json["menus"]),
        category: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
        customerReviews: List<CustomerReview>.from(
            json["customerReviews"].map((x) => CustomerReview.fromJson(x))));
  }
  factory Restaurant.fromJsonAsset(Map<String, dynamic> json) {
    return Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        pictureId: json["pictureId"],
        city: json["city"],
        rating: json["rating"].toDouble(),
        isFavorite: false,
        menus: Menus.fromJson(json["menus"]));
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "pictureId": pictureId,
        "city": city,
        "rating": rating,
        "isFavorite": isFavorite,
      };
  Map<String, dynamic> toJsonDb() => {
        "id": id,
        "name": name,
        "description": description,
        "pictureId": pictureId,
        "city": city,
        "rating": rating,
        "isFavorite": isFavorite ? 1 : 0,
      };
}

class Menus {
  Menus({
    required this.foods,
    required this.drinks,
  });

  List<MenuDetails> foods;
  List<MenuDetails> drinks;

  factory Menus.fromJson(Map<String, dynamic> json) => Menus(
        foods: List<MenuDetails>.from(
            json["foods"].map((x) => MenuDetails.fromJson(x))),
        drinks: List<MenuDetails>.from(
            json["drinks"].map((x) => MenuDetails.fromJson(x))),
      );
}

class MenuDetails {
  MenuDetails({
    required this.name,
  });

  String name;

  factory MenuDetails.fromJson(Map<String, dynamic> json) => MenuDetails(
        name: json["name"],
      );
}

class Category {
  Category({
    required this.name,
  });

  String name;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
      );
}

class CustomerReview {
  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  String name;
  String review;
  String date;

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        name: json["name"],
        review: json["review"],
        date: json["date"],
      );
}
