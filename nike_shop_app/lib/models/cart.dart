import 'package:flutter/material.dart';
import 'package:nike_shop_app/models/shoe.dart';

class Cart extends ChangeNotifier {
  //list of shoes for sale
  List<Shoe> shoeShop = [
    Shoe(
      count: 0,
      name: 'Air Jordan',
      price: '240',
      imagePath: 'assets/images/shoe.png',
      description:
          'The Air Jordan is a basketball shoe that was first released by Nike in 1984. Designed for Hall of Fame basketball player Michael Jordan, the shoe has become one of the most popular and iconic sneakers in history.',
    ),
    Shoe(
      count: 0,
      name: 'Nike Air Max',
      price: '180',
      imagePath: 'assets/images/shoe2.png',
      description:
          'The Nike Air Max is a line of shoes that was first released in 1987. Known for its visible air cushioning, the Air Max has become a popular choice for both athletes and sneakerheads.',
    ),
    Shoe(
      count: 0,
      name: 'Zoom freak',
      price: '120',
      imagePath: 'assets/images/shoe3.png',
      description:
          'The Zoom Freak is a signature shoe line for NBA player Giannis Antetokounmpo. Known for its unique design and performance features, the Zoom Freak has gained popularity among basketball players and fans alike.',
    ),
    Shoe(
      count: 0,
      name: 'Blazer',
      price: '200',
      imagePath: 'assets/images/shoe4.png',
      description:
          'The Blazer is a classic Nike sneaker that was first released in the 1970s. Known for its simple design and versatility, the Blazer has remained a popular choice for both basketball players and casual wear.',
    ),
    Shoe(
      count: 0,
      name: 'Air Max',
      price: '300',
      imagePath: 'assets/images/shoe5.png',
      description:
          'The Air Max is a line of shoes that was first released in 1987. Known for its visible air cushioning, the Air Max has become a popular choice for both athletes and sneakerheads.',
    ),
    Shoe(
      count: 0,
      name: 'Cortez',
      price: '150',
      imagePath: 'assets/images/shoe1.png',
      description:
          'The Cortez is a classic Nike sneaker that was first released in 1972. Known for its simple design and comfort, the Cortez has remained a popular choice for both athletes and casual wear.',
    ),
  ];

  //list of items in user's cart
  List<Shoe> userCart = [];

  //get list of shoes for sale
  List<Shoe> getShoesList() {
    return shoeShop;
  }

  //get cart
  List<Shoe> getUserCart() {
    return userCart;
  }

  //add item to cart
  void addToCart(Shoe shoe) {
    userCart.add(shoe);
    notifyListeners();
  }

  // remove item from cart
  void removeFromCart(Shoe shoe) {
    userCart.remove(shoe);
    notifyListeners();
  }
}
