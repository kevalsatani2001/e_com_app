import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../logic/bloc/product_bloc.dart';
import '../../logic/bloc/product_event.dart';
import '../../logic/bloc/product_state.dart';
import '../../widgets/cart_quantity_selector.dart';
import '../../widgets/product_card.dart';
import '../../widgets/rating_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (previous, current) =>
            previous.cartQuantity(product.id) != current.cartQuantity(product.id) ||
            previous.isFavourite(product.id) != current.isFavourite(product.id),
        builder: (context, state) {
          final isFavourite = state.isFavourite(product.id);
          final quantity = state.cartQuantity(product.id);

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      backgroundColor: const Color(0xFFF8F7FC),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            isFavourite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavourite
                                ? const Color(0xFFE53935)
                                : scheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            context
                                .read<ProductBloc>()
                                .add(ToggleFavouriteEvent(product));
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 280,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLg),
                                border: Border.all(
                                  color: scheme.outlineVariant
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                              child: Hero(
                                tag: ProductCard.heroTag(product.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _CategoryChip(label: product.category),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RatingBadge(rating: product.rating),
                            const SizedBox(height: 20),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.55,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _DetailBottomBar(
                price: product.price,
                quantity: quantity,
                product: product,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({
    required this.price,
    required this.quantity,
    required this.product,
  });

  final double price;
  final int quantity;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: quantity == 0
                ? FilledButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(AddToCartEvent(product));
                    },
                    child: const Text('Add to Cart'),
                  )
                : CartQuantitySelector(
                    product: product,
                    quantity: quantity,
                  ),
          ),
        ],
      ),
    );
  }
}
