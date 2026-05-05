import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/common/shimmer_widgets.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider);
    final portfolioSummary = ref.watch(portfolioSummaryProvider);

    return Scaffold(
      body: Column(
        children: [
          // Portfolio Summary Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: portfolioAsync.when(
              data: (holdings) {
                final totalInvestment = portfolioSummary['totalInvestment'] ?? 0.0;
                final currentValue = portfolioSummary['currentValue'] ?? 0.0;
                final totalProfitLoss = portfolioSummary['totalProfitLoss'] ?? 0.0;
                final totalProfitLossPercent = portfolioSummary['totalProfitLossPercent'] ?? 0.0;
                final holdingsCount = portfolioSummary['holdingsCount']?.toInt() ?? 0;

                return Column(
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Portfolio Summary',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical:4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$holdingsCount Holdings',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Total Investment
                    _buildSummaryItem(
                      context,
                      title: 'Total Investment',
                      value: '\$${totalInvestment.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Current Value
                    _buildSummaryItem(
                      context,
                      title: 'Current Value',
                      value: '\$${currentValue.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Profit/Loss
                    _buildSummaryItem(
                      context,
                      title: 'Profit/Loss',
                      value: '${totalProfitLoss >= 0 ? '+' : ''}\$${totalProfitLoss.abs().toStringAsFixed(2)}',
                      icon: totalProfitLoss >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      valueColor: totalProfitLoss >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                      textColor: totalProfitLoss >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Profit/Loss Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: totalProfitLossPercent >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            totalProfitLossPercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: totalProfitLossPercent >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${totalProfitLossPercent >= 0 ? '+' : ''}${totalProfitLossPercent.abs().toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: totalProfitLossPercent >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const PortfolioSummaryShimmer(),
              error: (error, stack) => _buildErrorWidget(error),
            ),
          ),
          
          // Holdings List
          Expanded(
            child: portfolioAsync.when(
              data: (holdings) {
                if (holdings.isEmpty) {
                  return _buildEmptyPortfolio();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(portfolioProvider.notifier)._loadPortfolio();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: holdings.length,
                    itemBuilder: (context, index) {
                      final holding = holdings[index];
                      return _buildHoldingCard(holding, index);
                    },
                  ),
                );
              },
              loading: () => const PortfolioHoldingsShimmer(),
              error: (error, stack) => _buildErrorWidget(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
    Color? textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: valueColor != null ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2) : null,
                decoration: valueColor != null
                    ? BoxDecoration(
                        color: valueColor,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Text(
                  value,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingCard(PortfolioHolding holding, int index) {
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
                  holding.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${holding.quantity} shares @ \$${holding.averagePrice.toStringAsFixed(2)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${holding.currentValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: holding.profitLoss >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${holding.profitLoss >= 0 ? '+' : ''}${holding.profitLossPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: holding.profitLoss >= 0 ? Colors.green.shade800 : Colors.red.shade800,
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
                    SnackBar(content: Text('Stock details for ${holding.symbol} coming soon!')),
                  );
                },
                onLongPress: () {
                  _showHoldingActions(holding);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPortfolio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your portfolio is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your investment portfolio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showTransactionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
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
              ref.read(portfolioProvider.notifier)._loadPortfolio();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const TransactionDialog(),
    );
  }

  void _showHoldingActions(PortfolioHolding holding) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Buy More'),
              onTap: () {
                Navigator.of(context).pop();
                _showBuyDialog(holding.symbol);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle),
              title: const Text('Sell Shares'),
              onTap: () {
                Navigator.of(context).pop();
                _showSellDialog(holding);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Details for ${holding.symbol} coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyDialog(String? symbol) {
    showDialog(
      context: context,
      builder: (context) => TransactionDialog(
        initialSymbol: symbol,
        transactionType: TransactionType.buy,
      ),
    );
  }

  void _showSellDialog(PortfolioHolding holding) {
    showDialog(
      context: context,
      builder: (context) => TransactionDialog(
        initialSymbol: holding.symbol,
        transactionType: TransactionType.sell,
        maxQuantity: holding.quantity,
        currentPrice: holding.currentPrice,
      ),
    );
  }
}

class TransactionDialog extends StatefulWidget {
  final String? initialSymbol;
  final TransactionType transactionType;
  final int? maxQuantity;
  final double? currentPrice;

  const TransactionDialog({
    super.key,
    this.initialSymbol,
    required this.transactionType,
    this.maxQuantity,
    this.currentPrice,
  });

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends ConsumerState<TransactionDialog> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _commissionController = TextEditingController(text: '0.0');
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSymbol != null) {
      _symbolController.text = widget.initialSymbol!;
    }
    if (widget.currentPrice != null) {
      _priceController.text = widget.currentPrice!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _commissionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitTransaction() {
    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final commission = double.tryParse(_commissionController.text) ?? 0.0;
    final notes = _notesController.text.trim();

    if (symbol.isEmpty || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (widget.transactionType == TransactionType.sell && 
        widget.maxQuantity != null && quantity > widget.maxQuantity!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You only have ${widget.maxQuantity} shares available')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (widget.transactionType == TransactionType.buy) {
      ref.read(portfolioProvider.notifier).buyStock(
        symbol: symbol,
        quantity: quantity,
        price: price,
        commission: commission,
        notes: notes,
      );
    } else {
      ref.read(portfolioProvider.notifier).sellStock(
        symbol: symbol,
        quantity: quantity,
        price: price,
        commission: commission,
        notes: notes,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.transactionType == TransactionType.buy ? 'Buy' : 'Sell'} Stock'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(
                labelText: 'Stock Symbol',
                hintText: 'e.g., AAPL, GOOGL',
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: widget.initialSymbol == null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                suffixText: widget.maxQuantity != null 
                    ? 'Available: ${widget.maxQuantity}' 
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price per Share (\$)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commissionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Commission (\$)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this transaction',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitTransaction,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.transactionType == TransactionType.buy ? 'Buy' : 'Sell'),
        ),
      ],
    );
  }
}

class PortfolioSummaryShimmer extends StatelessWidget {
  const PortfolioSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerContainer(
          width: double.infinity,
          height: 200,
          borderRadius: BorderRadius.circular(16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class PortfolioHoldingsShimmer extends StatelessWidget {
  const PortfolioHoldingsShimmer({super.key});

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
