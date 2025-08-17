import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Settings screen with various app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
        leading: IconButton( // Explicitly add a back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/'); // Navigate back to the home screen
          },
        ),
      ),
      body: ListView(
        children: [
          // Edit User settings
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(context.tr('edit_profile')), // Assuming 'edit_profile' localization key
            subtitle: Text(context.tr('edit_profile_description')), // Assuming 'edit_profile_description' localization key
            onTap: () => context.go('/user_detail'),
          ),

          const Divider(),

          // Language settings
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            subtitle: Text(context.tr('change_language')),
            onTap: () => context.go(AppConstants.languageSettingsRoute),
          ),

          const Divider(),

          // Theme settings
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(context.tr('theme')),
            subtitle: Text(context.tr('change_theme')),
            onTap: () {
              // Theme settings (to be implemented)
            },
          ),

          const Divider(),

          // Other settings...
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(context.tr('notifications')),
            subtitle: Text(context.tr('notification_settings')),
            onTap: () {
              // Notification settings (to be implemented)
            },
          ),
        ],
      ),
    );
  }
}
