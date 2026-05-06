import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/common/shimmer_widgets.dart';
import 'add_holding_simple_screen.dart';
import 'holding_details_screen.dart';
import 'stock_holdings_list_screen.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _commissionController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _transactionDate = DateTime.now();
  bool _isBuyTransaction = true;
  bool _showAddForm = false;

  // Sample stocks for demo
  final List<String> _availableStocks = [
    'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA', 'META', 'NVDA', 'JPM',
    'JNJ', 'V', 'PG', 'UNH', 'HD', 'MA', 'BAC', 'XOM', 'CVX', 'LLY',
    'ABBV', 'PFE', 'KO', 'PEP', 'TMO', 'COST', 'AVGO', 'LIN',
    'NKE', 'DIS', 'DHR', 'CMCSA', 'VZ', 'ADBE', 'NFLX', 'CRM',
    'PYPL', 'ACN', 'INTC', 'WMT', 'CSCO', 'TXN', 'HON', 'QCOM',
    'MDT', 'NEE', 'ABT', 'CRM', 'IBM', 'GE', 'ORCL', 'BA',
    'CAT', 'DE', 'GS', 'MS', 'BLK', 'SPGI', 'ICE', 'CME',
    'CB', 'AIG', 'TRV', 'ALL', 'MET', 'PRU', 'HIG', 'LNC',
    'HBL', 'NESTLE', 'TRG'
  ];

  // Mock stock names mapping
  final Map<String, String> _stockNames = {
    'AAPL': 'Apple Inc.',
    'GOOGL': 'Alphabet Inc.',
    'MSFT': 'Microsoft Corporation',
    'AMZN': 'Amazon.com Inc.',
    'TSLA': 'Tesla Inc.',
    'META': 'Meta Platforms Inc.',
    'NVDA': 'NVIDIA Corporation',
    'JPM': 'JPMorgan Chase & Co.',
    'JNJ': 'Johnson & Johnson',
    'V': 'Visa Inc.',
    'PG': 'Procter & Gamble',
    'UNH': 'UnitedHealth Group',
    'HD': 'Home Depot Inc.',
    'MA': 'Mastercard Inc.',
    'BAC': 'Bank of America Corp.',
    'XOM': 'Exxon Mobil Corp.',
    'CVX': 'Chevron Corp.',
    'LLY': 'Eli Lilly & Co.',
    'ABBV': 'AbbVie Inc.',
    'PFE': 'Pfizer Inc.',
    'KO': 'Coca-Cola Company',
    'PEP': 'PepsiCo Inc.',
    'TMO': 'Thermo Fisher Scientific',
    'COST': 'Costco Wholesale',
    'AVGO': 'Broadcom Inc.',
    'LIN': 'Linde plc',
    'NKE': 'Nike Inc.',
    'DIS': 'The Walt Disney Company',
    'DHR': 'Danaher Corp.',
    'CMCSA': 'Comcast Corp.',
    'VZ': 'Verizon Communications',
    'ADBE': 'Adobe Inc.',
    'NFLX': 'Netflix Inc.',
    'CRM': 'Salesforce Inc.',
    'PYPL': 'PayPal Holdings',
    'ACN': 'Accenture plc',
    'INTC': 'Intel Corp.',
    'WMT': 'Walmart Inc.',
    'CSCO': 'Cisco Systems',
    'TXN': 'Texas Instruments',
    'HON': 'Honeywell International',
    'QCOM': 'QUALCOMM Inc.',
    'MDT': 'Medtronic plc',
    'NEE': 'NextEra Energy',
    'ABT': 'Abbott Laboratories',
    'IBM': 'International Business Machines',
    'GE': 'General Electric',
    'ORCL': 'Oracle Corp.',
    'BA': 'Boeing Company',
    'CAT': 'Caterpillar Inc.',
    'DE': 'Deere & Co.',
    'GS': 'Goldman Sachs Group',
    'MS': 'Morgan Stanley',
    'BLK': 'BlackRock Inc.',
    'SPGI': 'S&P Global Inc.',
    'ICE': 'Intercontinental Exchange',
    'CME': 'CME Group Inc.',
    'CB': 'Chubb Limited',
    'AIG': 'American International Group',
    'TRV': 'The Travelers Companies',
    'ALL': 'Allstate Corp.',
    'MET': 'MetLife Inc.',
    'PRU': 'Prudential Financial',
    'HIG': 'The Hartford Financial Services',
    'LNC': 'Lincoln National Corp.',
    'HBL': 'Habib Bank Limited',
    'NESTLE': 'Nestlé S.A.',
    'TRG': 'Technology Resources Group',
  };

  // Mock current prices (in real app, this would come from an API)
  final Map<String, double> _currentPrices = {
    'AAPL': 182.52, 'GOOGL': 141.80, 'MSFT': 378.91, 'AMZN': 151.94,
    'TSLA': 242.84, 'META': 484.03, 'NVDA': 875.28, 'JPM': 198.59,
    'JNJ': 164.15, 'V': 274.89, 'PG': 155.37, 'UNH': 543.67,
    'HD': 389.76, 'MA': 459.68, 'BAC': 38.42, 'XOM': 108.73,
    'CVX': 151.19, 'LLY': 766.39, 'ABBV': 175.93, 'PFE': 28.47,
    'KO': 68.95, 'PEP': 178.74, 'TMO': 596.27, 'COST': 774.97,
    'AVGO': 1389.35, 'LIN': 432.18, 'NKE': 102.72, 'DIS': 111.41,
    'DHR': 274.96, 'CMCSA': 44.59, 'VZ': 40.97, 'ADBE': 629.03,
    'NFLX': 486.81, 'CRM': 284.76, 'PYPL': 61.58, 'ACN': 328.95,
    'INTC': 43.65, 'WMT': 178.89, 'CSCO': 52.76, 'TXN': 166.72,
    'HON': 207.34, 'QCOM': 194.02, 'MDT': 82.13, 'NEE': 67.84,
    'ABT': 112.67, 'IBM': 194.30, 'GE': 158.67, 'ORCL': 125.83,
    'BA': 209.56, 'CAT': 334.89, 'DE': 418.52, 'GS': 423.67,
    'MS': 89.67, 'BLK': 812.34, 'SPGI': 489.12, 'ICE': 135.78,
    'CME': 215.43, 'CB': 234.56, 'AIG': 67.89, 'TRV': 198.76,
    'ALL': 145.32, 'MET': 189.45, 'PRU': 123.67, 'HIG': 134.89,
    'LNC': 45.67, 'HBL': 156.78, 'NESTLE': 108.45, 'TRG': 234.56,
  };

  // Mock previous day's prices for daily P&L calculation
  final Map<String, double> _previousDayPrices = {
    'AAPL': 180.12, 'GOOGL': 140.25, 'MSFT': 375.43, 'AMZN': 149.87,
    'TSLA': 238.91, 'META': 479.23, 'NVDA': 865.12, 'JPM': 195.34,
    'JNJ': 162.89, 'V': 272.45, 'PG': 153.12, 'UNH': 538.76,
    'HD': 385.43, 'MA': 456.78, 'BAC': 37.89, 'XOM': 106.54,
    'CVX': 149.32, 'LLY': 758.91, 'ABBV': 173.45, 'PFE': 28.12,
    'KO': 68.12, 'PEP': 176.54, 'TMO': 591.23, 'COST': 768.45,
    'AVGO': 1375.67, 'LIN': 428.91, 'NKE': 101.45, 'DIS': 109.87,
    'DHR': 272.34, 'CMCSA': 44.12, 'VZ': 40.56, 'ADBE': 624.56,
    'NFLX': 482.34, 'CRM': 281.23, 'PYPL': 60.89, 'ACN': 325.67,
    'INTC': 43.12, 'WMT': 176.78, 'CSCO': 52.23, 'TXN': 165.34,
    'HON': 205.67, 'QCOM': 192.45, 'MDT': 81.56, 'NEE': 67.23,
    'ABT': 111.89, 'IBM': 192.45, 'GE': 156.78, 'ORCL': 124.56,
    'BA': 207.34, 'CAT': 331.23, 'DE': 415.67, 'GS': 419.56,
    'MS': 88.78, 'BLK': 805.67, 'SPGI': 485.23, 'ICE': 134.12,
    'CME': 213.45, 'CB': 232.34, 'AIG': 66.78, 'TRV': 196.45,
    'ALL': 143.67, 'MET': 187.23, 'PRU': 122.34, 'HIG': 133.45,
    'LNC': 45.12, 'HBL': 154.56, 'NESTLE': 106.78, 'TRG': 231.45,
  };

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _commissionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _transactionDate) {
      setState(() {
        _transactionDate = picked;
      });
    }
  }

  void _showStockSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBuyTransaction ? 'Select Stock to Buy' : 'Select Stock to Sell'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availableStocks.length,
            itemBuilder: (context, index) {
              final stock = _availableStocks[index];
              return ListTile(
                title: Text(stock),
                onTap: () {
                  Navigator.of(context).pop();
                  _symbolController.text = stock;
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = int.parse(_quantityController.text);

    // For SELL transactions, validate that user has enough stocks
    if (!_isBuyTransaction) {
      final notifier = ref.read(portfolioProvider.notifier);
      if (!notifier.canSellStock(symbol, quantity)) {
        final available = notifier.getAvailableQuantity(symbol);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot sell $quantity shares of $symbol. You only own $available shares.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final transaction = PortfolioTransaction(
      type: _isBuyTransaction ? TransactionType.buy : TransactionType.sell,
      symbol: symbol,
      quantity: quantity,
      price: double.parse(_priceController.text),
      commission: double.tryParse(_commissionController.text) ?? 0.0,
      date: _transactionDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    ref.read(portfolioProvider.notifier).addTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_isBuyTransaction ? 'BUY' : 'SELL'} transaction saved successfully!'),
        backgroundColor: _isBuyTransaction ? Colors.green : Colors.red,
      ),
    );

    // Reset form
    _formKey.currentState?.reset();
    setState(() {
      _showAddForm = false;
      _transactionDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showAddForm = !_showAddForm;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: Icon(_showAddForm ? Icons.close : Icons.add),
      ),
      body: portfolioAsync.when(
        data: (transactions) {
          // Get current holdings from transactions
          final notifier = ref.read(portfolioProvider.notifier);
          final holdings = notifier.getCurrentHoldings();
          final holdingsList = holdings.entries.where((entry) => entry.value['quantity'] > 0).toList();

          if (holdingsList.isEmpty) {
            return _buildEmptyState(context);
          }
          return Column(
            children: [
              // Portfolio Overview Cards
              _buildPortfolioOverview(context, ref),

              const SizedBox(height: 16),

              // Holdings List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Holdings (${holdingsList.length})',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _showAddHoldingDialog(context, ref),
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: holdingsList.isEmpty
                            ? _buildEmptyHoldings(context)
                            : _buildComprehensiveHoldingsList(holdingsList),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  
  Widget _buildPortfolioOverview(BuildContext context, WidgetRef ref) {
    final portfolioSummary = ref.read(portfolioSummaryProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Summary Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildOverviewCard(
                context,
                title: 'Total Investment',
                value: portfolioSummary.maybeWhen(
                  data: (data) => '\$${(data['totalInvestment'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                  orElse: () => '\$0.00',
                ),
                icon: Icons.account_balance,
                color: Colors.blue,
              ),
              _buildOverviewCard(
                context,
                title: 'Current Value',
                value: portfolioSummary.maybeWhen(
                  data: (data) => '\$${(data['currentValue'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                  orElse: () => '\$0.00',
                ),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              _buildOverviewCard(
                context,
                title: 'Today\'s P&L',
                value: portfolioSummary.maybeWhen(
                  data: (data) {
                    final pl = (data['totalProfitLoss'] as double?) ?? 0.0;
                    final sign = pl >= 0 ? '+' : '';
                    return '$sign\$${pl.abs().toStringAsFixed(2)}';
                  },
                  orElse: () => '\$0.00',
                ),
                icon: Icons.today,
                color: Colors.orange,
                isProfit: portfolioSummary.maybeWhen(
                  data: (data) => ((data['totalProfitLoss'] as double?) ?? 0.0) >= 0,
                  orElse: () => true,
                ),
              ),
              _buildOverviewCard(
                context,
                title: 'Overall P&L',
                value: portfolioSummary.maybeWhen(
                  data: (data) {
                    final pl = (data['totalProfitLoss'] as double?) ?? 0.0;
                    final percent = (data['totalProfitLossPercent'] as double?) ?? 0.0;
                    final sign = pl >= 0 ? '+' : '';
                    return '$sign\$${pl.abs().toStringAsFixed(2)} ($sign${percent.abs().toStringAsFixed(2)}%)';
                  },
                  orElse: () => '\$0.00 (0.00%)',
                ),
                icon: Icons.show_chart,
                color: Colors.purple,
                isProfit: portfolioSummary.maybeWhen(
                  data: (data) => ((data['totalProfitLoss'] as double?) ?? 0.0) >= 0,
                  orElse: () => true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isProfit = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const Spacer(),
                if (title.contains('P&L'))
                  Icon(
                    isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isProfit ? Colors.green : Colors.red,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isProfit ? (title.contains('P&L') ? (isProfit ? Colors.green : Colors.red) : null) : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Total Value Card
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Portfolio Value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              FutureBuilder(
                future: ref.read(portfolioProvider.notifier).getTotalValue(),
                builder: (context, snapshot) {
                  final totalValue = snapshot.data ?? 0.0;
                  return Text(
                    '\$${totalValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats Cards Row
        Row(
          children: [
            // Total Investment Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Investment',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).textTheme.titleMedium?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: ref.read(portfolioProvider.notifier).getTotalInvestment(),
                      builder: (context, snapshot) {
                        final totalInvestment = snapshot.data ?? 0.0;
                        return Text(
                          '\$${totalInvestment.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Profit/Loss Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Profit/Loss',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).textTheme.titleMedium?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: ref.read(portfolioProvider.notifier).getTotalProfitLoss(),
                      builder: (context, snapshot) {
                        final totalProfitLoss = snapshot.data ?? 0.0;
                        return Text(
                          '\$${totalProfitLoss.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: totalProfitLoss >= 0 ? Colors.green : Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHoldingCard(BuildContext context, WidgetRef ref, MapEntry<String, Map<String, dynamic>> holding) {
    final symbol = holding.key;
    final data = holding.value;
    final quantity = data['quantity'] as int;
    final avgPrice = data['avgPrice'] as double;
    final totalCost = data['totalCost'] as double;
    final totalValue = data['totalValue'] as double;
    final profitLoss = totalValue - totalCost;
    final profitLossPercent = totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0;
    final isProfit = profitLoss >= 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HoldingDetailsScreen(
              symbol: symbol,
              holdingData: data,
            ),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$quantity shares',
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
                    'Avg: \$${avgPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${totalValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isProfit ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isProfit ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isProfit ? '+' : ''}\$${profitLoss.toStringAsFixed(2)} (${profitLossPercent.toStringAsFixed(2)}%)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isProfit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPriceDetail(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComprehensiveHoldingsList(List<MapEntry<String, Map<String, dynamic>>> holdingsList) {
    // Convert holdings to comprehensive format with prices
    final comprehensiveHoldings = <Map<String, dynamic>>[];

    for (final entry in holdingsList) {
      final symbol = entry.key;
      final data = entry.value;
      final quantity = data['quantity'] as int;
      
      if (quantity > 0) {
        final currentPrice = _currentPrices[symbol] ?? 100.0;
        final previousPrice = _previousDayPrices[symbol] ?? currentPrice;
        final totalCost = data['totalCost'] as double;
        final marketValue = quantity * currentPrice;
        final dailyPnL = quantity * (currentPrice - previousPrice);
        final totalPnL = marketValue - totalCost;
        final totalPnLPercent = totalCost > 0 ? (totalPnL / totalCost) * 100 : 0.0;

        comprehensiveHoldings.add({
          'symbol': symbol,
          'name': _stockNames[symbol] ?? symbol,
          'quantity': quantity,
          'currentPrice': currentPrice,
          'totalCost': totalCost,
          'marketValue': marketValue,
          'dailyPnL': dailyPnL,
          'totalPnL': totalPnL,
          'totalPnLPercent': totalPnLPercent,
          'avgPrice': data['avgPrice'] as double,
        });
      }
    }

    // Sort by market value descending
    comprehensiveHoldings.sort((a, b) => (b['marketValue'] as double).compareTo(a['marketValue'] as double));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: comprehensiveHoldings.length,
      itemBuilder: (context, index) {
        final holding = comprehensiveHoldings[index];
        return _buildComprehensiveHoldingRow(holding);
      },
    );
  }

  Widget _buildComprehensiveHoldingRow(Map<String, dynamic> holding) {
    final symbol = holding['symbol'] as String;
    final name = holding['name'] as String;
    final currentPrice = holding['currentPrice'] as double;
    final quantity = holding['quantity'] as int;
    final totalCost = holding['totalCost'] as double;
    final marketValue = holding['marketValue'] as double;
    final dailyPnL = holding['dailyPnL'] as double;
    final totalPnLPercent = holding['totalPnLPercent'] as double;
    final avgPrice = holding['avgPrice'] as double;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HoldingDetailsScreen(
                symbol: symbol,
                holdingData: holding,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stock Name and Price Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${currentPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${quantity} shares',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Financial Details Row
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialItem('Total Cost', '\$${totalCost.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    child: _buildFinancialItem('Market Value', '\$${marketValue.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    child: _buildFinancialItem(
                      "Day's P&L", 
                      '${dailyPnL >= 0 ? '+' : ''}\$${dailyPnL.abs().toStringAsFixed(2)}',
                      dailyPnL >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildFinancialItem(
                      'Total P&L %', 
                      '${totalPnLPercent >= 0 ? '+' : ''}${totalPnLPercent.toStringAsFixed(1)}%',
                      totalPnLPercent >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Average Price and Action Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg: \$${avgPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Buy indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart, size: 14, color: Colors.green.shade800),
                            const SizedBox(width: 4),
                            Text('BUY', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sell indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sell, size: 14, color: Colors.red.shade800),
                            const SizedBox(width: 4),
                            Text('SELL', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Building Your Portfolio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first investment to track your portfolio performance and make informed decisions.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddHoldingDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Holding'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample data feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Try Sample Data'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHoldings(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No holdings found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading portfolio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction Type Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuyTransaction = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isBuyTransaction ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BUY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isBuyTransaction ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuyTransaction = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isBuyTransaction ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SELL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isBuyTransaction ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Fields
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showStockSelectionDialog,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _symbolController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Symbol',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per Share',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _commissionController,
                    decoration: const InputDecoration(
                      labelText: 'Commission (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Transaction Date',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(
                          text: DateFormat('MMM dd, yyyy').format(_transactionDate),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBuyTransaction ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'SAVE ${_isBuyTransaction ? 'BUY' : 'SELL'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHoldingDialog(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddHoldingSimpleScreen(),
      ),
    );
  }
}
