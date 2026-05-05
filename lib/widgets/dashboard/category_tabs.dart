import 'package:flutter/material.dart';

class CategoryTabs extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<CategoryItem> categories = [
    CategoryItem(
      name: 'All',
      icon: Icons.apps,
    ),
    CategoryItem(
      name: 'Stocks',
      icon: Icons.show_chart,
    ),
    CategoryItem(
      name: 'Indices',
      icon: Icons.public,
    ),
    CategoryItem(
      name: 'Commodities',
      icon: Icons.emoji_objects,
    ),
    CategoryItem(
      name: 'Crypto',
      icon: Icons.currency_bitcoin,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = categories.indexWhere(
      (category) => category.name == widget.selectedCategory,
      orElse: () => 0,
    );
    _tabController = TabController(
      length: categories.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onCategoryChanged(categories[_tabController.index].name);
      }
    });
  }

  @override
  void didUpdateWidget(CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      final newIndex = categories.indexWhere(
        (category) => category.name == widget.selectedCategory,
        orElse: () => 0,
      );
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 0,
        dividerHeight: 0,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: categories.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(category.name),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;

  CategoryItem({
    required this.name,
    required this.icon,
  });
}
