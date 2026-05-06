import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/portfolio_card.dart';
import '../../widgets/dashboard/mini_chart.dart';
import '../../widgets/dashboard/watchlist_preview.dart';
import '../../widgets/dashboard/trending_section.dart';
import '../../widgets/dashboard/enhanced_market_movers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          ref.invalidate(dashboardDataProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portfolio Card (Hero Section)
              const PortfolioCard(),
              
              const SizedBox(height: 16),
              
              // Mini Chart
              MiniChart(
                data: [100, 95, 98, 102, 99, 105, 108, 106, 110, 108, 112, 115],
                height: 100,
                showGradient: true,
              ),
              
              const SizedBox(height: 16),
              
              // Market Movers (Enhanced with filtering)
              const EnhancedMarketMovers(),
              
              const SizedBox(height: 16),
              
              // Watchlist Preview
              const WatchlistPreview(),
              
              const SizedBox(height: 16),
              
              // Trending Section
              TrendingSection(stocks: sampleTrendingStocks),
              
              const SizedBox(height: 50), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}
