import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_usage_tracker.dart';
import '../../services/rate_limited_api_service.dart';

class ApiUsageWidget extends ConsumerWidget {
  const ApiUsageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageStats = ref.watch(apiUsageStatsProvider);
    final criticalUsage = ref.watch(criticalApiUsageProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'API Usage Monitor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (criticalUsage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${criticalUsage.length} Critical',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Usage Statistics
          ...usageStats['apis']?.entries.map((entry) {
            final apiName = entry.key;
            final stats = entry.value as Map<String, dynamic>;
            final callsMade = stats['callsMade'] as int;
            final maxCalls = stats['maxCalls'] as int;
            final usagePercentage = double.tryParse(stats['usagePercentage'].toString()) ?? 0.0;
            final timeUntilReset = stats['timeUntilReset'] as int;
            final isCritical = usagePercentage >= 80;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCritical 
                    ? Colors.red.withOpacity(0.05)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCritical 
                      ? Colors.red.withOpacity(0.2)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Name and Status
                  Row(
                    children: [
                      Text(
                        _formatApiName(apiName),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(usagePercentage).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(usagePercentage),
                          style: TextStyle(
                            color: _getStatusColor(usagePercentage),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$callsMade / $maxCalls calls',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          Text(
                            '${usagePercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(usagePercentage),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: usagePercentage / 100,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(usagePercentage),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Time Until Reset
                  if (timeUntilReset > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resets in ${timeUntilReset}m',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }).toList() ?? [],

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Monitor your API usage to avoid rate limits. Free tiers have limited calls per day.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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

  String _formatApiName(String apiName) {
    switch (apiName) {
      case 'twelveData':
        return 'Twelve Data';
      case 'fmp':
        return 'Financial Modeling Prep';
      case 'goldApi':
        return 'Gold API';
      case 'finnhub':
        return 'Finnhub';
      default:
        return apiName;
    }
  }

  Color _getStatusColor(double usagePercentage) {
    if (usagePercentage >= 80) {
      return Colors.red;
    } else if (usagePercentage >= 60) {
      return Colors.orange;
    } else if (usagePercentage >= 40) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText(double usagePercentage) {
    if (usagePercentage >= 80) {
      return 'Critical';
    } else if (usagePercentage >= 60) {
      return 'Warning';
    } else if (usagePercentage >= 40) {
      return 'Moderate';
    } else {
      return 'Good';
    }
  }
}
