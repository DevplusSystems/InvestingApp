import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Value Shimmer
          ShimmerContainer(
            width: 120,
            height: 20,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          ShimmerContainer(
            width: 200,
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          ShimmerContainer(
            width: 150,
            height: 16,
            margin: const EdgeInsets.only(bottom: 24),
          ),
          
          // Top Holdings Title
          ShimmerContainer(
            width: 100,
            height: 24,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          
          // Holdings List Shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Stock info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerContainer(
                                width: 100,
                                height: 16,
                                margin: const EdgeInsets.only(bottom: 4),
                              ),
                              ShimmerContainer(
                                width: 60,
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                        // Price info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShimmerContainer(
                              width: 80,
                              height: 16,
                              margin: const EdgeInsets.only(bottom: 4),
                            ),
                            ShimmerContainer(
                              width: 50,
                              height: 12,
                            ),
                          ],
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
  }
}

class ChatMessageShimmer extends StatelessWidget {
  final bool isUser;

  const ChatMessageShimmer({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ShimmerContainer(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: double.infinity,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      ShimmerContainer(
                        width: double.infinity * 0.8,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      ShimmerContainer(
                        width: double.infinity * 0.6,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                ShimmerContainer(
                  width: 60,
                  height: 12,
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            ShimmerContainer(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ],
      ),
    );
  }
}

class PortfolioCardShimmer extends StatelessWidget {
  const PortfolioCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerContainer(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: 120,
                        height: 16,
                        margin: const EdgeInsets.only(bottom: 4),
                      ),
                      ShimmerContainer(
                        width: 80,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerContainer(
                  width: 80,
                  height: 20,
                ),
                ShimmerContainer(
                  width: 60,
                  height: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
