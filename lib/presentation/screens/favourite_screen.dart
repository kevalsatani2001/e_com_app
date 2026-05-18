import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/product_card.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Favourites')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.favouriteProducts.isEmpty) {
            return const Center(child: Text("No items saved yet."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: state.favouriteProducts.length,
            itemBuilder: (context, index) {
              final product = state.favouriteProducts[index];
              return ProductCard(product: product, isFavourite: true);
            },
          );
        },
      ),
    );
  }
}