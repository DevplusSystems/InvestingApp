import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio_transaction.dart';
import '../../providers/portfolio_provider.dart';

class StockHoldingsListScreen extends ConsumerStatefulWidget {
  const StockHoldingsListScreen({super.key});

  @override
  ConsumerState<StockHoldingsListScreen> createState() => _StockHoldingsListScreenState();
}

class _StockHoldingsListScreenState extends ConsumerState<StockHoldingsListScreen> {
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

  List<Map<String, dynamic>> _getHoldingsWithPrices() {
    final holdings = ref.read(portfolioProvider.notifier).getCurrentHoldings();
    final holdingsList = <Map<String, dynamic>>[];

    for (final entry in holdings.entries) {
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

        holdingsList.add({
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
    holdingsList.sort((a, b) => (b['marketValue'] as double).compareTo(a['marketValue'] as double));
    return holdingsList;
  }

  @override
  Widget build(BuildContext context) {
    final holdings = _getHoldingsWithPrices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Holdings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: holdings.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Summary Header
                _buildSummaryHeader(holdings),
                
                // Holdings List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: holdings.length,
                    itemBuilder: (context, index) {
                      final holding = holdings[index];
                      return _buildHoldingRow(holding);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader(List<Map<String, dynamic>> holdings) {
    final totalMarketValue = holdings.fold<double>(0.0, (sum, h) => sum + (h['marketValue'] as double));
    final totalCost = holdings.fold<double>(0.0, (sum, h) => sum + (h['totalCost'] as double));
    final totalPnL = totalMarketValue - totalCost;
    final totalPnLPercent = totalCost > 0 ? (totalPnL / totalCost) * 100 : 0.0;
    final dailyPnL = holdings.fold<double>(0.0, (sum, h) => sum + (h['dailyPnL'] as double));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Portfolio Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Value', '\$${totalMarketValue.toStringAsFixed(2)}', Colors.white),
              _buildSummaryItem('Total P&L', '${totalPnL >= 0 ? '+' : ''}\$${totalPnL.abs().toStringAsFixed(2)}', 
                totalPnL >= 0 ? Colors.green.shade300 : Colors.red.shade300),
              _buildSummaryItem("Today's P&L", '${dailyPnL >= 0 ? '+' : ''}\$${dailyPnL.abs().toStringAsFixed(2)}', 
                dailyPnL >= 0 ? Colors.green.shade300 : Colors.red.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Holdings Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first stock',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(Map<String, dynamic> holding) {
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
          // Navigate to holding details
          Navigator.of(context).pushNamed('/holding-details', arguments: {
            'symbol': symbol,
            'holdingData': holding,
          });
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
}
