import 'package:flutter/material.dart';

class TrendingStock {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final List<double> chartData;

  TrendingStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.chartData,
  });
}

class TrendingSection extends StatelessWidget {
  final List<TrendingStock> stocks;

  const TrendingSection({
    super.key,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Trending',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return _buildTrendingCard(context, stock, index);
          },
        ),
      ],
    );
  }

  Widget _buildTrendingCard(BuildContext context, TrendingStock stock, int index) {
    final isPositive = stock.changePercent >= 0;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to stock details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stock details for ${stock.symbol} coming soon!')),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini chart (placeholder)
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildSimpleChart(context, stock.chartData, isPositive),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Stock info
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stock.symbol,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stock.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 12,
                                  color: isPositive ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${isPositive ? '+' : ''}${stock.changePercent.abs().toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: isPositive ? Colors.green : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleChart(BuildContext context, List<double> data, bool isPositive) {
    if (data.isEmpty) {
      return Center(
        child: Icon(
          Icons.trending_up,
          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
          size: 24,
        ),
      );
    }

    final padding = 8.0;
    final chartWidth = MediaQuery.of(context).size.width / 2 - 40; // Adjust for grid
    final chartHeight = 60.0;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return const SizedBox();

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * (chartWidth - padding * 2);
      final y = padding + (1 - (data[i] - minValue) / range) * (chartHeight - padding * 2);
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return CustomPaint(
      painter: _SimpleChartPainter(
        path: path,
        points: points,
        color: isPositive ? Colors.green : Colors.red,
      ),
      child: Container(),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  final Path path;
  final List<Offset> points;
  final Color color;

  _SimpleChartPainter({
    required this.path,
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw line
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (final point in points) {
      canvas.drawCircle(point, 2.0, dotPaint);
    }

    // Highlight last point
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;
      
      canvas.drawCircle(lastPoint, 3.0, dotPaint);
      canvas.drawCircle(lastPoint, 2.0, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) {
    return oldDelegate.path != path ||
           oldDelegate.points != points ||
           oldDelegate.color != color;
  }
}

// Sample data for demonstration
final List<TrendingStock> sampleTrendingStocks = [
  TrendingStock(
    symbol: 'TSLA',
    name: 'Tesla Inc.',
    price: 240.15,
    changePercent: -0.8,
    chartData: [245, 243, 241, 242, 240, 241, 240.15],
  ),
  TrendingStock(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    price: 189.23,
    changePercent: 1.2,
    chartData: [185, 186, 187, 188, 189, 189.5, 189.23],
  ),
  TrendingStock(
    symbol: 'NVDA',
    name: 'NVIDIA Corp.',
    price: 485.09,
    changePercent: 4.8,
    chartData: [460, 465, 470, 475, 480, 485, 485.09],
  ),
  TrendingStock(
    symbol: 'GOOGL',
    name: 'Alphabet Inc.',
    price: 142.67,
    changePercent: 0.9,
    chartData: [140, 141, 141.5, 142, 142.5, 142.6, 142.67],
  ),
  TrendingStock(
    symbol: 'MSFT',
    name: 'Microsoft Corp.',
    price: 378.91,
    changePercent: -0.9,
    chartData: [382, 381, 380, 379, 378, 378.5, 378.91],
  ),
  TrendingStock(
    symbol: 'AMZN',
    name: 'Amazon.com Inc.',
    price: 156.78,
    changePercent: 1.9,
    chartData: [153, 154, 155, 156, 156.5, 156.7, 156.78],
  ),
];
