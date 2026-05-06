import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../drawer/app_drawer.dart';
import '../../providers/theme_provider.dart';

class UnifiedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String title;
  final bool showSearch;
  final VoidCallback? onSearchPressed;

  const UnifiedAppBar({
    super.key,
    this.scaffoldKey,
    this.title = 'Investing App',
    this.showSearch = true,
    this.onSearchPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIcon = ref.watch(themeIconProvider);
    final themePreference = ref.watch(themeProvider);

    return AppBar(
      title: Row(
        children: [
          // App Logo/Icon
        /*  Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
          ),*/
/*
          const SizedBox(width: 12),
*/
          // App Name
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: onSearchPressed ?? () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
        ),
        // Theme Toggle
        PopupMenuButton<ThemePreference>(
          icon: Icon(themeIcon),
          tooltip: 'Change Theme',
          onSelected: (ThemePreference theme) async {
            await ref.read(themeProvider.notifier).setTheme(theme);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8),
                  const Text('Light'),
                  if (themePreference == ThemePreference.light)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8),
                  const Text('Dark'),
                  if (themePreference == ThemePreference.dark)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuItem<ThemePreference>(
              value: ThemePreference.system,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_auto,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8),
                  const Text('System'),
                  if (themePreference == ThemePreference.system)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () {
          if (scaffoldKey != null) {
            scaffoldKey!.currentState?.openDrawer();
          } else {
            // Fallback to find scaffold ancestor
            final scaffold = Scaffold.of(context);
            scaffold.openDrawer();
          }
        },
      ),
    );
  }
}
