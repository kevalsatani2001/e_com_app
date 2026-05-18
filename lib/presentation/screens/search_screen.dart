import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_event.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.status != ProductStatus.success) {
            return const Center(child: CircularProgressIndicator());
          }

          final sliderMax = state.catalogMaxPrice > 0
              ? state.catalogMaxPrice
              : 1.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by title',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    context.read<ProductBloc>().add(
                          FilterProductsEvent(
                            query: value,
                            maxPrice: state.maxPriceFilter,
                          ),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Up to \$${state.maxPriceFilter.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Slider(
                  value: state.maxPriceFilter.clamp(0, sliderMax),
                  min: 0,
                  max: sliderMax,
                  onChanged: (value) {
                    context.read<ProductBloc>().add(
                          FilterProductsEvent(
                            query: state.searchQuery,
                            maxPrice: value,
                          ),
                        );
                  },
                ),
              ),
              Expanded(
                child: state.filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No matches for your filters',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: state.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = state.filteredProducts[index];
                          return ProductCard(
                            product: product,
                            isFavourite: state.isFavourite(product.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
