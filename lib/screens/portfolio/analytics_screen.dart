import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
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

  Map<String, dynamic> _calculateAnalytics() {
    final transactions = ref.read(portfolioProvider).value ?? [];
    final notifier = ref.read(portfolioProvider.notifier);
    final holdings = notifier.getCurrentHoldings();
    
    // Basic metrics
    final totalInvestment = transactions.fold<double>(0.0, (sum, t) => 
      t.type == TransactionType.buy ? sum + (t.quantity * t.price) + t.commission : sum);
    final currentValue = holdings.fold<double>(0.0, (sum, h) => sum + (h['totalValue'] as double));
    final totalPnL = currentValue - totalInvestment;
    final totalPnLPercent = totalInvestment > 0 ? (totalPnL / totalInvestment) * 100 : 0.0;
    
    // Transaction metrics
    final buyTransactions = transactions.where((t) => t.type == TransactionType.buy).length;
    final sellTransactions = transactions.where((t) => t.type == TransactionType.sell).length;
    final totalCommission = transactions.fold<double>(0.0, (sum, t) => sum + t.commission);
    
    // Holdings metrics
    final totalHoldings = holdings.length;
    final profitableHoldings = holdings.values.where((h) => 
      (h['totalValue'] as double) > (h['totalCost'] as double)).length;
    final losingHoldings = totalHoldings - profitableHoldings;
    
    // Best and worst performers
    var bestPerformer = holdings.entries.isNotEmpty ? holdings.entries.first : null;
    var worstPerformer = holdings.entries.isNotEmpty ? holdings.entries.first : null;
    
    for (final holding in holdings.entries) {
      final pnl = (holding.value['totalValue'] as double) - (holding.value['totalCost'] as double);
      final pnlPercent = (holding.value['totalCost'] as double) > 0 ? 
        (pnl / (holding.value['totalCost'] as double)) * 100 : 0.0;
      
      if (bestPerformer != null) {
        final bestPnlPercent = (bestPerformer.value['totalCost'] as double) > 0 ? 
          (((bestPerformer.value['totalValue'] as double) - (bestPerformer.value['totalCost'] as double)) / 
           (bestPerformer.value['totalCost'] as double)) * 100 : 0.0;
        if (pnlPercent > bestPnlPercent) {
          bestPerformer = holding;
        }
      }
      
      if (worstPerformer != null) {
        final worstPnlPercent = (worstPerformer.value['totalCost'] as double) > 0 ? 
          (((worstPerformer.value['totalValue'] as double) - (worstPerformer.value['totalCost'] as double)) / 
           (worstPerformer.value['totalCost'] as double)) * 100 : 0.0;
        if (pnlPercent < worstPnlPercent) {
          worstPerformer = holding;
        }
      }
    }
    
    return {
      'totalInvestment': totalInvestment,
      'currentValue': currentValue,
      'totalPnL': totalPnL,
      'totalPnLPercent': totalPnLPercent,
      'buyTransactions': buyTransactions,
      'sellTransactions': sellTransactions,
      'totalCommission': totalCommission,
      'totalHoldings': totalHoldings,
      'profitableHoldings': profitableHoldings,
      'losingHoldings': losingHoldings,
      'bestPerformer': bestPerformer,
      'worstPerformer': worstPerformer,
    };
  }

  List<Map<String, dynamic>> _getMonthlyPerformance() {
    final transactions = ref.read(portfolioProvider).value ?? [];
    final monthlyData = <String, Map<String, dynamic>>{};
    
    for (final transaction in transactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);
      
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {
          'buys': 0,
          'sells': 0,
          'investment': 0.0,
          'commission': 0.0,
        };
      }
      
      if (transaction.type == TransactionType.buy) {
        monthlyData[monthKey]!['buys']++;
        monthlyData[monthKey]!['investment'] += (transaction.quantity * transaction.price) + transaction.commission;
      } else {
        monthlyData[monthKey]!['sells']++;
      }
      
      monthlyData[monthKey]!['commission'] += transaction.commission;
    }
    
    return monthlyData.entries.map((entry) => {
      'month': entry.key,
      ...entry.value,
    }).toList()..sort((a, b) => b['month'].compareTo(a['month']));
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _calculateAnalytics();
    final monthlyPerformance = _getMonthlyPerformance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Performance', icon: Icon(Icons.trending_up)),
            Tab(text: 'Activity', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(analytics),
          _buildPerformanceTab(analytics),
          _buildActivityTab(monthlyPerformance),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary
          _buildSummaryCard(analytics),
          const SizedBox(height: 16),
          
          // Transaction Summary
          _buildTransactionCard(analytics),
          const SizedBox(height: 16),
          
          // Holdings Summary
          _buildHoldingsCard(analytics),
          const SizedBox(height: 16),
          
          // Top Performers
          _buildPerformersCard(analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> analytics) {
    final totalPnL = analytics['totalPnL'] as double;
    final isProfit = totalPnL >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit ? [Colors.green.shade50, Colors.green.shade100] : [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isProfit ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Portfolio Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
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
                    'Total Investment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${(analytics['totalInvestment'] as double).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Value',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${(analytics['currentValue'] as double).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total P&L',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${isProfit ? '+' : ''}\$${totalPnL.abs().toStringAsFixed(2)} (${(analytics['totalPnLPercent'] as double).abs().toStringAsFixed(2)}%)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> analytics) {
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
            'Transaction Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTransactionItem('Buy Orders', analytics['buyTransactions'], Colors.green),
              _buildTransactionItem('Sell Orders', analytics['sellTransactions'], Colors.red),
              _buildTransactionItem('Commission', '\$${(analytics['totalCommission'] as double).toStringAsFixed(2)}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String label, dynamic value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            label.contains('Buy') ? Icons.add_shopping_cart : 
            label.contains('Sell') ? Icons.sell : Icons.money,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value is String ? value : value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsCard(Map<String, dynamic> analytics) {
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
            'Holdings Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHoldingItem('Total Holdings', analytics['totalHoldings'], Colors.blue),
              _buildHoldingItem('Profitable', analytics['profitableHoldings'], Colors.green),
              _buildHoldingItem('Losing', analytics['losingHoldings'], Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            label.contains('Total') ? Icons.account_balance : 
            label.contains('Profitable') ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformersCard(Map<String, dynamic> analytics) {
    final bestPerformer = analytics['bestPerformer'] as MapEntry<String, Map<String, dynamic>>?;
    final worstPerformer = analytics['worstPerformer'] as MapEntry<String, Map<String, dynamic>>?;

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
            'Top Performers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (bestPerformer != null)
            _buildPerformerItem(bestPerformer, true),
          if (bestPerformer != null && worstPerformer != null)
            const SizedBox(height: 12),
          if (worstPerformer != null)
            _buildPerformerItem(worstPerformer, false),
        ],
      ),
    );
  }

  Widget _buildPerformerItem(MapEntry<String, Map<String, dynamic>> performer, bool isBest) {
    final symbol = performer.key;
    final data = performer.value;
    final pnl = (data['totalValue'] as double) - (data['totalCost'] as double);
    final pnlPercent = (data['totalCost'] as double) > 0 ? 
      (pnl / (data['totalCost'] as double)) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isBest ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isBest ? Icons.emoji_events : Icons.trending_down,
            color: isBest ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBest ? 'Best Performer' : 'Worst Performer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  symbol,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isBest ? '+' : ''}\$${pnl.abs().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isBest ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${isBest ? '+' : ''}${pnlPercent.abs().toStringAsFixed(2)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isBest ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(Map<String, dynamic> analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Performance Chart', style: TextStyle(color: Colors.grey)),
                  Text('Coming Soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Performance Metrics
          _buildPerformanceMetrics(analytics),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> analytics) {
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
            'Performance Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Win Rate', '${analytics['totalHoldings'] > 0 ? ((analytics['profitableHoldings'] / analytics['totalHoldings']) * 100).toStringAsFixed(1) : '0'}%'),
          _buildMetricRow('Avg Return per Holding', '${analytics['totalHoldings'] > 0 ? ((analytics['totalPnL'] / analytics['totalHoldings'])).toStringAsFixed(2) : '0.00'}'),
          _buildMetricRow('Total Commission Paid', '\$${(analytics['totalCommission'] as double).toStringAsFixed(2)}'),
          _buildMetricRow('Commission Impact', '${analytics['totalInvestment'] > 0 ? ((analytics['totalCommission'] / analytics['totalInvestment']) * 100).toStringAsFixed(2) : '0.00'}%'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(List<Map<String, dynamic>> monthlyPerformance) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Monthly Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Monthly List
        Expanded(
          child: monthlyPerformance.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No activity yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: monthlyPerformance.length,
                  itemBuilder: (context, index) {
                    final month = monthlyPerformance[index];
                    return _buildMonthCard(month);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMonthCard(Map<String, dynamic> month) {
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
          Text(
            month['month'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActivityItem('Buys', month['buys'], Colors.green),
              _buildActivityItem('Sells', month['sells'], Colors.red),
              _buildActivityItem('Investment', '\$${(month['investment'] as double).toStringAsFixed(0)}', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
