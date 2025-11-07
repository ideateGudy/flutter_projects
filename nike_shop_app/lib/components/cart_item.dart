import 'package:flutter/material.dart';
import 'package:nike_shop_app/models/cart.dart';
import 'package:nike_shop_app/models/shoe.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  Shoe shoe;
  CartItem({super.key, required this.shoe});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  void deleteItemFromCart() {
    Provider.of<Cart>(context, listen: false).removeFromCart(widget.shoe);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(widget.shoe.imagePath),
        title: Text(widget.shoe.name),
        subtitle: Text('\$' + widget.shoe.price),
        trailing: IconButton(
          onPressed: deleteItemFromCart,
          icon: Icon(Icons.delete),
        ),
      ),
    );
  }
}
