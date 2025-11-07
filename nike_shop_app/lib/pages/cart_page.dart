import 'package:flutter/material.dart';
import 'package:nike_shop_app/components/cart_item.dart';
import 'package:nike_shop_app/models/cart.dart';
import 'package:nike_shop_app/models/shoe.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //heading
            const Text(
              "My Cart",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),

            SizedBox(height: 20),

            //list
            Expanded(
              child: ListView.builder(
                itemCount: value.getUserCart().length,
                itemBuilder: (context, index) {
                  Shoe shoe = value.getUserCart()[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: CartItem(shoe: shoe),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
