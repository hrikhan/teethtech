import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../extensions/context_extension.dart';
import '../../theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _restockAlerts = true;
  bool _promotionalOffers = false;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final themeMode = context.watch<ThemeCubit>().state;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Push Notifications
          Text(
            'Notifications',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _orderNotifications,
                  onChanged: (v) => setState(() => _orderNotifications = v),
                  title: const Text('Order & Shipment Updates'),
                  subtitle: const Text('Live status notifications for dispatched orders'),
                  activeTrackColor: cs.primary,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _restockAlerts,
                  onChanged: (v) => setState(() => _restockAlerts = v),
                  title: const Text('Inventory Restock Alerts'),
                  subtitle: const Text('Get notified when out-of-stock items return'),
                  activeTrackColor: cs.primary,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _promotionalOffers,
                  onChanged: (v) => setState(() => _promotionalOffers = v),
                  title: const Text('Clinic B2B Flash Deals'),
                  subtitle: const Text('Exclusive discounts on equipment and materials'),
                  activeTrackColor: cs.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme & Appearance
          Text(
            'Appearance',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_6_rounded, color: cs.primary),
                  title: const Text('Theme Mode'),
                  subtitle: Text(
                    themeMode == ThemeMode.system
                        ? 'System Default'
                        : themeMode == ThemeMode.dark
                            ? 'Dark Theme'
                            : 'Light Theme',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legal & About
          Text(
            'About TeethTech',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Version'),
                  trailing: Text(
                    '1.0.0 (Phase 1 Foundation)',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('Terms of Service & Clinical Policy'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('Privacy Policy'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
