import 'package:flutter/material.dart';
import '../../models/market_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final MarketFilter currentFilter;
  final Function(MarketFilter) onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedRegion;
  late String selectedType;
  late String selectedCategory;

  final List<String> regions = ['Global', 'USA', 'Pakistan', 'Asia'];
  final List<String> types = ['Gainers', 'Losers', 'Most Active'];
  final List<String> categories = ['Stocks', 'Indices', 'Commodities', 'Crypto'];

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.currentFilter.region;
    selectedType = widget.currentFilter.type;
    selectedCategory = widget.currentFilter.category;
  }

  void _applyFilters() {
    widget.onFilterChanged(
      MarketFilter(
        region: selectedRegion,
        type: selectedType,
        category: selectedCategory,
        searchQuery: widget.currentFilter.searchQuery,
      ),
    );
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      selectedRegion = 'Global';
      selectedType = 'Gainers';
      selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Market Movers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Filter Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Region Filter
                _buildFilterSection(
                  title: '🌍 Region',
                  options: regions,
                  selectedValue: selectedRegion,
                  onSelected: (value) {
                    setState(() {
                      selectedRegion = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Type Filter
                _buildFilterSection(
                  title: '📊 Type',
                  options: types,
                  selectedValue: selectedType,
                  onSelected: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Category Filter
                _buildFilterSection(
                  title: '📦 Category',
                  options: categories,
                  selectedValue: selectedCategory,
                  onSelected: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Apply Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
