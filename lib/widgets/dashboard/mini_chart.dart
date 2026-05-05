import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MiniChart extends StatefulWidget {
  final List<double> data;
  final double height;
  final Color? positiveColor;
  final Color? negativeColor;
  final bool showGradient;
  final Duration animationDuration;

  const MiniChart({
    super.key,
    required this.data,
    this.height = 100.0,
    this.positiveColor,
    this.negativeColor,
    this.showGradient = true,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<MiniChart> createState() => _MiniChartState();
}

class _MiniChartState extends State<MiniChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(MiniChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ),
      );
    }

    final isPositive = widget.data.last > widget.data.first;
    final positiveColor = widget.positiveColor ?? 
        (isPositive ? Colors.green : Colors.red);
    final negativeColor = widget.negativeColor ?? Colors.red;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ChartPainter(
              data: widget.data,
              progress: _animation.value,
              positiveColor: positiveColor,
              negativeColor: negativeColor,
              showGradient: widget.showGradient,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color positiveColor;
  final Color negativeColor;
  final bool showGradient;

  _ChartPainter({
    required this.data,
    required this.progress,
    required this.positiveColor,
    required this.negativeColor,
    required this.showGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final padding = 8.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    // Calculate min and max values
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    // Create path for the chart
    final path = Path();
    final fillPath = Path();

    final pointsToShow = (data.length * progress).floor();
    
    for (int i = 0; i < pointsToShow; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final y = padding + (1 - (data[i] - minValue) / range) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    if (pointsToShow > 0) {
      final lastX = padding + ((pointsToShow - 1) / (data.length - 1)) * chartWidth;
      fillPath.lineTo(lastX, size.height - padding);
      fillPath.lineTo(padding, size.height - padding);
      fillPath.close();
    }

    // Determine color based on trend
    final isPositive = data.last > data.first;
    paint.color = isPositive ? positiveColor : negativeColor;

    // Draw gradient fill if enabled
    if (showGradient && pointsToShow > 0) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isPositive ? positiveColor : negativeColor).withOpacity(0.3),
          (isPositive ? positiveColor : negativeColor).withOpacity(0.05),
        ],
      );
      fillPaint.shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw dots at each point
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isPositive ? positiveColor : negativeColor;

    for (int i = 0; i < pointsToShow; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final y = padding + (1 - (data[i] - minValue) / range) * chartHeight;
      
      canvas.drawCircle(
        Offset(x, y),
        2.0,
        dotPaint,
      );
    }

    // Highlight the last point
    if (pointsToShow > 0) {
      final lastX = padding + ((pointsToShow - 1) / (data.length - 1)) * chartWidth;
      final lastY = padding + (1 - (data[pointsToShow - 1] - minValue) / range) * chartHeight;
      
      final highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;
      
      canvas.drawCircle(
        Offset(lastX, lastY),
        4.0,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        2.5,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.data != data ||
           oldDelegate.positiveColor != positiveColor ||
           oldDelegate.negativeColor != negativeColor ||
           oldDelegate.showGradient != showGradient;
  }
}
