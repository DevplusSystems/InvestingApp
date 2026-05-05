import 'package:flutter/material.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../widgets/common/unified_app_bar.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../dashboard/dashboard_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../ask_iris/ask_iris_screen.dart';
import '../timeline/timeline_screen.dart';
import '../watchlist/watchlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PortfolioScreen(),
    AskIrisScreen(),
    TimelineScreen(),
    WatchlistScreen(),
  ];

  final List<String> _screenTitles = const [
    'Dashboard',
    'Portfolio',
    'Ask Iris',
    'Timeline',
    'Watchlist',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: UnifiedAppBar(
        scaffoldKey: _scaffoldKey,
        title: _screenTitles[_currentIndex],
      ),
      drawer: const AppDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
