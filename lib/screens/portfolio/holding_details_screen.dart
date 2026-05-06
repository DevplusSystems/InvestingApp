import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';

class HoldingDetailsScreen extends ConsumerStatefulWidget {
  final String symbol;
  final Map<String, dynamic> holdingData;

  const HoldingDetailsScreen({
    super.key,
    required this.symbol,
    required this.holdingData,
  });

  @override
  ConsumerState<HoldingDetailsScreen> createState() => _HoldingDetailsScreenState();
}

class _HoldingDetailsScreenState extends ConsumerState<HoldingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PortfolioTransaction> _getSymbolTransactions() {
    final transactions = ref.read(portfolioProvider).value ?? [];
    return transactions
        .where((t) => t.symbol.toUpperCase() == widget.symbol.toUpperCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, dynamic> _calculateDetailedMetrics() {
    final transactions = _getSymbolTransactions();
    final holdingData = widget.holdingData;
    
    int totalShares = 0;
    double totalCost = 0.0;
    double totalValue = 0.0;
    
    // Calculate from transactions
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.buy) {
        totalShares += transaction.quantity;
        totalCost += (transaction.quantity * transaction.price) + transaction.commission;
      } else {
        totalShares -= transaction.quantity;
        totalCost -= (transaction.quantity * transaction.price) + transaction.commission;
      }
    }
    
    // Current value (using last transaction price as current price for demo)
    double currentPrice = 0.0;
    if (transactions.isNotEmpty) {
      currentPrice = transactions.first.price; // Last transaction price
    }
    totalValue = totalShares * currentPrice;
    
    // P&L calculations
    final totalPnL = totalValue - totalCost;
    final totalPnLPercent = totalCost > 0 ? (totalPnL / totalCost) * 100 : 0.0;
    
    // Daily P&L (mock calculation - in real app would use previous day's close)
    final dailyPnL = totalShares * (currentPrice * 0.02); // Mock 2% daily change
    final dailyPnLPercent = currentPrice > 0 ? (dailyPnL / (totalShares * currentPrice)) * 100 : 0.0;
    
    return {
      'totalShares': totalShares,
      'totalCost': totalCost,
      'totalValue': totalValue,
      'currentPrice': currentPrice,
      'avgPrice': totalShares > 0 ? totalCost / totalShares : 0.0,
      'totalPnL': totalPnL,
      'totalPnLPercent': totalPnLPercent,
      'dailyPnL': dailyPnL,
      'dailyPnLPercent': dailyPnLPercent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateDetailedMetrics();
    final transactions = _getSymbolTransactions();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary', icon: Icon(Icons.summarize)),
            Tab(text: 'Holdings', icon: Icon(Icons.account_balance)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(metrics),
          _buildHoldingsTab(metrics),
          _buildHistoryTab(transactions),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(Map<String, dynamic> metrics) {
    final totalShares = metrics['totalShares'] as int;
    final totalCost = metrics['totalCost'] as double;
    final totalValue = metrics['totalValue'] as double;
    final currentPrice = metrics['currentPrice'] as double;
    final avgPrice = metrics['avgPrice'] as double;
    final totalPnL = metrics['totalPnL'] as double;
    final totalPnLPercent = metrics['totalPnLPercent'] as double;
    final dailyPnL = metrics['dailyPnL'] as double;
    final dailyPnLPercent = metrics['dailyPnLPercent'] as double;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Value and Live Quote
          _buildValueCard(totalValue, currentPrice, totalShares),
          const SizedBox(height: 16),

          // P&L Section
          _buildPnLSection(dailyPnL, dailyPnLPercent, totalPnL, totalPnLPercent),
          const SizedBox(height: 16),

          // Purchase Information
          _buildPurchaseInfoCard(totalCost, avgPrice, totalShares),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildValueCard(double totalValue, double currentPrice, int totalShares) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Current Value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Quote',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Shares Owned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    totalShares.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPnLSection(double dailyPnL, double dailyPnLPercent, double totalPnL, double totalPnLPercent) {
    final isDailyProfit = dailyPnL >= 0;
    final isTotalProfit = totalPnL >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profit & Loss',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Daily P&L
          Row(
            children: [
              Icon(
                isDailyProfit ? Icons.trending_up : Icons.trending_down,
                color: isDailyProfit ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's P&L",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${isDailyProfit ? '+' : ''}\$${dailyPnL.abs().toStringAsFixed(2)} (${dailyPnLPercent.abs().toStringAsFixed(2)}%)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDailyProfit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Total P&L
          Row(
            children: [
              Icon(
                isTotalProfit ? Icons.trending_up : Icons.trending_down,
                color: isTotalProfit ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total P&L',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${isTotalProfit ? '+' : ''}\$${totalPnL.abs().toStringAsFixed(2)} (${totalPnLPercent.abs().toStringAsFixed(2)}%)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isTotalProfit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseInfoCard(double totalCost, double avgPrice, int totalShares) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Cost',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Avg Buy Price',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${avgPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Price',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${(totalCost / totalShares).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to buy screen with pre-filled symbol
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Buy More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to sell screen with pre-filled symbol
                  },
                  icon: const Icon(Icons.sell),
                  label: const Text('Sell'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsTab(Map<String, dynamic> metrics) {
    final totalShares = metrics['totalShares'] as int;
    final totalCost = metrics['totalCost'] as double;
    final totalValue = metrics['totalValue'] as double;
    final avgPrice = metrics['avgPrice'] as double;
    final currentPrice = metrics['currentPrice'] as double;
    final totalPnL = metrics['totalPnL'] as double;
    final totalPnLPercent = metrics['totalPnLPercent'] as double;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Holdings Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.surface],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.symbol} Holdings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Shares',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          totalShares.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Average Price',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '\$${avgPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Holdings Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Holdings Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildHoldingDetailRow('Total Cost', '\$${totalCost.toStringAsFixed(2)}'),
                _buildHoldingDetailRow('Current Value', '\$${totalValue.toStringAsFixed(2)}'),
                _buildHoldingDetailRow('Current Price', '\$${currentPrice.toStringAsFixed(2)}'),
                _buildHoldingDetailRow('Total P&L', '\$${totalPnL.toStringAsFixed(2)}', totalPnL >= 0),
                _buildHoldingDetailRow('P&L %', '${totalPnLPercent.toStringAsFixed(2)}%', totalPnLPercent >= 0),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Holdings Allocation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Allocation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Portfolio Chart', style: TextStyle(color: Colors.grey)),
                        Text('Coming Soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingDetailRow(String label, String value, [bool isPositive = true]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: label.contains('P&L') ? (isPositive ? Colors.green : Colors.red) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<PortfolioTransaction> transactions) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Add filter functionality
                },
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Transactions List
        Expanded(
          child: transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(PortfolioTransaction transaction) {
    final isBuy = transaction.type == TransactionType.buy;
    final totalCost = (transaction.quantity * transaction.price) + transaction.commission;
    final currentValue = transaction.quantity * transaction.price; // Using purchase price as current price
    final pnl = currentValue - (transaction.quantity * transaction.price + transaction.commission);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBuy ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isBuy ? 'BUY' : 'SELL',
                      style: TextStyle(
                        color: isBuy ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  // TODO: Edit transaction
                },
                icon: const Icon(Icons.edit, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction.quantity} shares',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@ \$${transaction.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.commission > 0)
                    Text(
                      'Comm: \$${transaction.commission.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
