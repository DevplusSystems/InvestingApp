import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'number_animation.dart';

class PortfolioCard extends ConsumerStatefulWidget {
  const PortfolioCard({super.key});

  @override
  ConsumerState<PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends ConsumerState<PortfolioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: portfolioAsync.when(
              data: (holdings) {
                final portfolioSummary = ref.read(portfolioSummaryProvider);
                final totalValue = portfolioSummary['currentValue'] ?? 0.0;
                final totalInvestment = portfolioSummary['totalInvestment'] ?? 0.0;
                final totalProfitLoss = portfolioSummary['totalProfitLoss'] ?? 0.0;
                final totalProfitLossPercent = portfolioSummary['totalProfitLossPercent'] ?? 0.0;
                
                // Use dashboard data if available, otherwise use portfolio data
                final dailyChange = dashboardAsync.whenData(
                  (data) => data.dailyChange,
                ) ?? totalProfitLoss;
                
                final dailyChangePercent = dashboardAsync.whenData(
                  (data) => data.dailyChangePercent,
                ) ?? totalProfitLossPercent;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Total Value',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Value with animation
                    AnimatedNumber(
                      value: totalValue,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                      prefix: '\$',
                      duration: const Duration(milliseconds: 800),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Daily change with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Row(
                              children: [
                                Icon(
                                  dailyChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${dailyChange >= 0 ? '+' : ''}\$${dailyChange.abs().toStringAsFixed(2)} (${dailyChangePercent >= 0 ? '+' : ''}${dailyChangePercent.abs().toStringAsFixed(2)}%) today',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => _buildShimmer(),
              error: (error, stack) => _buildError(error),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 160,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 120,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Error loading portfolio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to retry',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}
