import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: AnimatedIcon(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.dashboard,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: AnimatedIcon(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.account_balance_wallet,
          ),
          label: 'Portfolio',
        ),
        BottomNavigationBarItem(
          icon: AnimatedIcon(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.chat,
          ),
          label: 'Ask Iris',
        ),
        BottomNavigationBarItem(
          icon: AnimatedIcon(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.timeline,
          ),
          label: 'Timeline',
        ),
        BottomNavigationBarItem(
          icon: AnimatedIcon(
            index: 4,
            currentIndex: currentIndex,
            icon: Icons.star_border,
          ),
          label: 'Watchlist',
        ),
      ],
    );
  }
}

class AnimatedIcon extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;

  const AnimatedIcon({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(
        begin: isSelected ? 0.8 : 1.0,
        end: isSelected ? 1.2 : 1.0,
      ),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        );
      },
    );
  }
}
