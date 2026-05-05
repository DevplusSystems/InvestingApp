import 'package:flutter/material.dart';

class MarketMover {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;

  MarketMover({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
  });
}

class MarketMovers extends StatelessWidget {
  final List<MarketMover> movers;

  const MarketMovers({
    super.key,
    required this.movers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Market Movers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: movers.length,
            itemBuilder: (context, index) {
              final mover = movers[index];
              return _buildMoverCard(context, mover, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoverCard(BuildContext context, MarketMover mover, int index) {
    final isPositive = mover.changePercent >= 0;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Symbol
                  Text(
                    mover.symbol,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    '\$${mover.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Change percentage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 10,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isPositive ? '+' : ''}${mover.changePercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Sample data for demonstration
final List<MarketMover> sampleMarketMovers = [
  MarketMover(
    symbol: 'AAPL',
    price: 189.23,
    change: 4.31,
    changePercent: 2.3,
  ),
  MarketMover(
    symbol: 'TSLA',
    price: 240.15,
    change: -2.67,
    changePercent: -1.1,
  ),
  MarketMover(
    symbol: 'NVDA',
    price: 485.09,
    change: 22.31,
    changePercent: 4.8,
  ),
  MarketMover(
    symbol: 'GOOGL',
    price: 142.67,
    change: 1.23,
    changePercent: 0.9,
  ),
  MarketMover(
    symbol: 'MSFT',
    price: 378.91,
    change: -3.45,
    changePercent: -0.9,
  ),
  MarketMover(
    symbol: 'AMZN',
    price: 156.78,
    change: 2.89,
    changePercent: 1.9,
  ),
];
