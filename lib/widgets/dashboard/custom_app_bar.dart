import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
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
          ),
          
          const SizedBox(width: 12),
          
          // Dashboard Title
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
          ),
          
          const Spacer(),
          
          // Search Icon
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
            },
            icon: Icon(
              Icons.search,
              size: 22,
              color: Theme.of(context).iconTheme.color,
            ),
            splashRadius: 20,
          ),
          
          const SizedBox(width: 4),
          
          // Theme Toggle
          Consumer(
            builder: (context, ref, child) {
              final themePreference = ref.watch(themeProvider);
              return PopupMenuButton<ThemePreference>(
                icon: Icon(
                  themePreference == ThemePreference.dark ? Icons.dark_mode : Icons.light_mode,
                  size: 22,
                  color: Theme.of(context).iconTheme.color,
                ),
                onSelected: (ThemePreference preference) async {
                  await ref.read(themeProvider.notifier).setTheme(preference);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ThemePreference.light,
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          size: 20,
                          color: themePreference == ThemePreference.light
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text('Light'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemePreference.dark,
                    child: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          size: 20,
                          color: themePreference == ThemePreference.dark
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text('Dark'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemePreference.system,
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_brightness,
                          size: 20,
                          color: themePreference == ThemePreference.system
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text('System'),
                      ],
                    ),
                  ),
                ],
                splashRadius: 20,
              );
            },
          ),
          
          const SizedBox(width: 4),
          
          // Drawer Icon
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(
              Icons.menu,
              size: 22,
              color: Theme.of(context).iconTheme.color,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
