import 'package:flutter/material.dart';
import 'package:nike_shop_app/components/bottom_nav_bar.dart';
import 'package:nike_shop_app/pages/cart_page.dart';
import 'package:nike_shop_app/pages/shop_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //selected index to control bottom nav bar
  int _selectedIndex = 0;

  //update selected index
  void navigateButtomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //shop page
    const ShopPage(),

    //cart page
    const CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateButtomBar(index),
      ),
    );
  }
}
