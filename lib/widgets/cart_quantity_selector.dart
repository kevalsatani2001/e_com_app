import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../data/models/product_model.dart';
import '../logic/bloc/product_bloc.dart';
import '../logic/bloc/product_event.dart';

enum CartQuantitySelectorSize { compact, regular }

class CartQuantitySelector extends StatelessWidget {
  const CartQuantitySelector({
    super.key,
    required this.product,
    required this.quantity,
    this.size = CartQuantitySelectorSize.regular,
  });

  final Product product;
  final int quantity;
  final CartQuantitySelectorSize size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = size == CartQuantitySelectorSize.compact;
    final buttonSize = compact ? 32.0 : 44.0;
    final iconSize = compact ? 18.0 : 22.0;
    final fontSize = compact ? 14.0 : 16.0;
    final radius = compact ? AppTheme.radiusSm : AppTheme.radiusMd;

    return Container(
      height: compact ? 36 : 48,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          _StepButton(
            size: buttonSize,
            iconSize: iconSize,
            icon: Icons.remove_rounded,
            onPressed: () {
              context
                  .read<ProductBloc>()
                  .add(DecrementCartQuantityEvent(product));
            },
          ),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepButton(
            size: buttonSize,
            iconSize: iconSize,
            icon: Icons.add_rounded,
            onPressed: () {
              context
                  .read<ProductBloc>()
                  .add(IncrementCartQuantityEvent(product));
            },
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.size,
    required this.iconSize,
    required this.icon,
    required this.onPressed,
  });

  final double size;
  final double iconSize;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }
}
