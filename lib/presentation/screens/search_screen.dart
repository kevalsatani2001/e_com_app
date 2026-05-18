import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_event.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search items...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    context.read<ProductBloc>().add(
                      FilterProductsEvent(query: value, maxPrice: state.maxPriceFilter),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text("Max Price:"),
                    Expanded(
                      child: Slider(
                        value: state.maxPriceFilter,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        label: "\$${state.maxPriceFilter.round()}",
                        onChanged: (value) {
                          context.read<ProductBloc>().add(
                            FilterProductsEvent(query: state.searchQuery, maxPrice: value),
                          );
                        },
                      ),
                    ),
                    Text("\$${state.maxPriceFilter.toStringAsFixed(0)}"),
                  ],
                ),
              ),
              Expanded(
                child: state.filteredProducts.isEmpty
                    ? const Center(child: Text("No items match criteria."))
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    final isFav = state.favouriteProducts.any((p) => p.id == product.id);
                    return ProductCard(product: product, isFavourite: isFav);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}