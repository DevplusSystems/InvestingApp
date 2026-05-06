import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../common/shimmer_widgets.dart';

class PortfolioCard extends ConsumerWidget {
  const PortfolioCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: portfolioAsync.when(
        data: (holdings) {
          // Simple calculation for display
          final totalValue = holdings.fold<double>(0.0, (sum, holding) => 
            sum + (holding.quantity * holding.price));
          final totalInvestment = holdings.fold<double>(0.0, (sum, holding) => 
            sum + holding.totalCost);
          final totalProfitLoss = totalValue - totalInvestment;
          final totalProfitLossPercent = totalInvestment > 0 ? 
            (totalProfitLoss / totalInvestment) * 100 : 0.0;
          final isOverallProfit = totalProfitLoss >= 0;
          final overallColor = isOverallProfit ? Colors.greenAccent.shade100 : Colors.red.shade100;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Portfolio Value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOverallProfit ? Icons.arrow_upward : Icons.arrow_downward,
                        color: overallColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${isOverallProfit ? '+' : ''}\$${totalProfitLoss.abs().toStringAsFixed(2)} (${totalProfitLossPercent >= 0 ? '+' : ''}${totalProfitLossPercent.abs().toStringAsFixed(2)}%) total P&L',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: overallColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.18), height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        context,
                        label: 'Total Investment',
                        value: '\$${totalInvestment.toStringAsFixed(2)}',
                        valueColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetric(
                        context,
                        label: 'Holdings',
                        value: '${holdings.length}',
                        valueColor: Colors.white,
                        icon: Icons.account_balance_wallet,
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => _buildShimmer(),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor ?? valueColor),
              const SizedBox(width: 3),
            ],
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade600,
            Colors.red.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Portfolio Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                error.toString().length > 50 
                    ? '${error.toString().substring(0, 47)}...'
                    : error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please restart the app',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
