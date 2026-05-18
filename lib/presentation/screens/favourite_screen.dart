import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/product_card.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.favouriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: scheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Save items you love',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: state.favouriteProducts.length,
            itemBuilder: (context, index) {
              final product = state.favouriteProducts[index];
              return ProductCard(
                product: product,
                isFavourite: true,
              );
            },
          );
        },
      ),
    );
  }
}
