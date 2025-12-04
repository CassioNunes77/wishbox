import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class PriceRangeSelector extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final ValueChanged<double>? onMinChanged;
  final ValueChanged<double>? onMaxChanged;

  const PriceRangeSelector({
    super.key,
    this.minPrice,
    this.maxPrice,
    this.onMinChanged,
    this.onMaxChanged,
  });

  @override
  State<PriceRangeSelector> createState() => _PriceRangeSelectorState();
}

class _PriceRangeSelectorState extends State<PriceRangeSelector> {
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.minPrice ?? 50.0;
    _maxPrice = widget.maxPrice ?? 500.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faixa de preço',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mínimo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '${AppConstants.currencySymbol} ',
                      hintText: '0.00',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      setState(() => _minPrice = price);
                      widget.onMinChanged?.call(price);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Máximo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '${AppConstants.currencySymbol} ',
                      hintText: '0.00',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      setState(() => _maxPrice = price);
                      widget.onMaxChanged?.call(price);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${AppConstants.currencySymbol} ${_minPrice.toStringAsFixed(2)} - ${AppConstants.currencySymbol} ${_maxPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}



