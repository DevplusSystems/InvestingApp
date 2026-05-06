import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/watchlist_item.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/shimmer_widgets.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final watchlistCount = ref.watch(watchlistCountProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search watchlist...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          
          // Watchlist Content
          Expanded(
            child: watchlistAsync.when(
              data: (watchlist) {
                final filteredWatchlist = _searchQuery.isEmpty
                    ? watchlist
                    : watchlist.where((item) =>
                        item.symbol.toLowerCase().contains(_searchQuery) ||
                        item.name.toLowerCase().contains(_searchQuery)).toList();

                if (filteredWatchlist.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(watchlistProvider.notifier).reload();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredWatchlist.length,
                    itemBuilder: (context, index) {
                      final item = filteredWatchlist[index];
                      return _buildWatchlistCard(item, index);
                    },
                  ),
                );
              },
              loading: () => const WatchlistShimmer(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStockDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add stocks to track their performance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddStockDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(watchlistProvider.notifier).reload();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(WatchlistItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  item.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(item.name),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.change >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.change >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: item.change >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Navigate to stock details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stock details for ${item.symbol} coming soon!')),
                  );
                },
                onLongPress: () {
                  _showRemoveDialog(item);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStockDialog(
        onAdd: (symbol, name) {
          final item = WatchlistItem(
            symbol: symbol,
            name: name,
            price: 0.0, // Will be updated with real data
            change: 0.0,
            changePercent: 0.0,
            addedAt: DateTime.now(),
          );
          ref.read(watchlistProvider.notifier).addToWatchlist(item);
        },
      ),
    );
  }

  void _showRemoveDialog(WatchlistItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${item.symbol}?'),
        content: Text('Are you sure you want to remove ${item.name} from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(watchlistProvider.notifier).removeFromWatchlist(item.symbol);
            },
            child: const Text('Remove'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class WatchlistShimmer extends StatelessWidget {
  const WatchlistShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ShimmerContainer(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: 80,
                        height: 16,
                        margin: const EdgeInsets.only(bottom: 4),
                      ),
                      ShimmerContainer(
                        width: 120,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerContainer(
                      width: 60,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 4),
                    ),
                    ShimmerContainer(
                      width: 40,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddStockDialog extends StatefulWidget {
  final Function(String symbol, String name) onAdd;

  const AddStockDialog({super.key, required this.onAdd});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addStock() {
    final symbol = _symbolController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (symbol.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onAdd(symbol, name);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stock to Watchlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _symbolController,
            decoration: const InputDecoration(
              labelText: 'Stock Symbol',
              hintText: 'e.g., AAPL, GOOGL',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              hintText: 'e.g., Apple Inc.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addStock,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
