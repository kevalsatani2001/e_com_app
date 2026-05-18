import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_event.dart';
import '../../logic/bloc/product_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.cartProducts.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          double totalAmount = state.cartProducts.fold(0, (sum, item) => sum + item.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.cartProducts[index];
                    return ListTile(
                      leading: Image.network(product.image, width: 50, fit: BoxFit.contain),
                      title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          context.read<ProductBloc>().add(RemoveFromCartEvent(product));
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        onPressed: () {
                          context.read<ProductBloc>().add(CheckoutCartEvent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checked out successfully! Cart cleared.')),
                          );
                        },
                        child: const Text("Checkout", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}