import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: dashboardData.when(
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Value',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${data.totalPortfolioValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: data.dailyChange >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.dailyChange >= 0 ? '+' : ''}${data.dailyChange.toStringAsFixed(2)} (${data.dailyChangePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: data.dailyChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Top Holdings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.topHoldings.length,
                    itemBuilder: (context, index) {
                      final holding = data.topHoldings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(holding.name),
                          subtitle: Text(holding.symbol),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${holding.value.toStringAsFixed(2)}'),
                              Text(
                                '${holding.changePercent >= 0 ? '+' : ''}${holding.changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: holding.changePercent >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
