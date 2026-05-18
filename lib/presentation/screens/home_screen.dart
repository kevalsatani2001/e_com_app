import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog Home')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ProductStatus.failure) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: state.allProducts.length,
            itemBuilder: (context, index) {
              final product = state.allProducts[index];
              final isFav = state.favouriteProducts.any((p) => p.id == product.id);
              return ProductCard(product: product, isFavourite: isFav);
            },
          );
        },
      ),
    );
  }
}