import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../data/models/product_model.dart';
import '../logic/bloc/product_bloc.dart';
import '../logic/bloc/product_event.dart';
import '../logic/bloc/product_state.dart';
import '../presentation/screens/product_detail_screen.dart';
import 'cart_quantity_selector.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavourite,
    this.showCartActions = true,
  });

  final Product product;
  final bool isFavourite;
  final bool showCartActions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusMd),
                        ),
                        onTap: () => _openDetail(context),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 28, 12, 8),
                          child: Hero(
                            tag: ProductCard.heroTag(product.id),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: GestureDetector(
                onTap: () => _openDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: GestureDetector(
                onTap: () => _openDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (showCartActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: BlocBuilder<ProductBloc, ProductState>(
                  buildWhen: (previous, current) =>
                      previous.cartQuantity(product.id) !=
                      current.cartQuantity(product.id),
                  builder: (context, state) {
                    final quantity = state.cartQuantity(product.id);

                    if (quantity == 0) {
                      return SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<ProductBloc>()
                                .add(AddToCartEvent(product));
                          },
                          child: const Text('Add to Cart'),
                        ),
                      );
                    }

                    return CartQuantitySelector(
                      product: product,
                      quantity: quantity,
                      size: CartQuantitySelectorSize.compact,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  static String heroTag(int productId) => 'product-image-$productId';
}
