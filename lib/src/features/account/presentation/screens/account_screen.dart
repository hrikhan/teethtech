import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../theme/theme_cubit.dart';
import '../../../auth/presentation/providers/session_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _showThemeDialog(BuildContext context) {
    final currentTheme = context.read<ThemeCubit>().state;
    final cs = context.theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Choose App Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('System Default'),
                leading: Icon(
                  currentTheme == ThemeMode.system
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: currentTheme == ThemeMode.system
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                onTap: () {
                  context.read<ThemeCubit>().setTheme(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Light Theme'),
                leading: Icon(
                  currentTheme == ThemeMode.light
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: currentTheme == ThemeMode.light
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                onTap: () {
                  context.read<ThemeCubit>().setTheme(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Dark Theme'),
                leading: Icon(
                  currentTheme == ThemeMode.dark
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: currentTheme == ThemeMode.dark
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                onTap: () {
                  context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    final cs = context.theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text(
              'Are you sure you want to log out of your TeethTech account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context
                    .read<SessionBloc>()
                    .add(const SessionLogoutRequested());
                context.go(AppRoutes.welcome);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final isAuthenticated = session.status == SessionStatus.authenticated;
    final user = session.user;

    final isB2b = isAuthenticated && (user?.isB2b ?? false);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // User Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: !isAuthenticated
                          ? const Color(0xFFD97706).withValues(alpha: 0.15)
                          : (isB2b
                              ? cs.primaryContainer
                              : const Color(0xFF00897B).withValues(alpha: 0.15)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        !isAuthenticated
                            ? Icons.person_outline_rounded
                            : (isB2b
                                ? Icons.local_hospital_rounded
                                : Icons.person_rounded),
                        color: !isAuthenticated
                            ? const Color(0xFFD97706)
                            : (isB2b ? cs.primary : const Color(0xFF00897B)),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          !isAuthenticated
                              ? 'Guest User'
                              : ((user?.name?.isNotEmpty ?? false)
                                  ? user!.name!
                                  : (isB2b
                                      ? 'Apex Dental Care & Implant'
                                      : 'Dr. Tanvir Ahmed, BDS')),
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          !isAuthenticated
                              ? 'Browsing Mode • Sign in to order'
                              : (user?.email ?? 'dr.tanvir@teethtech.com'),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Account Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: !isAuthenticated
                                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                                : (isB2b
                                    ? cs.primaryContainer
                                    : const Color(0xFF00897B)
                                        .withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                !isAuthenticated
                                    ? Icons.lock_outline_rounded
                                    : Icons.verified_user_rounded,
                                size: 12,
                                color: !isAuthenticated
                                    ? const Color(0xFFD97706)
                                    : (isB2b
                                        ? cs.primary
                                        : const Color(0xFF00897B)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                !isAuthenticated
                                    ? 'GUEST (UNVERIFIED)'
                                    : (isB2b
                                        ? 'B2B CLINIC MEMBER'
                                        : 'RETAIL CUSTOMER (B2C)'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: !isAuthenticated
                                      ? const Color(0xFFD97706)
                                      : (isB2b
                                          ? cs.primary
                                          : const Color(0xFF00897B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Guest Sign In CTA Card (if not logged in)
            if (!isAuthenticated) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D2A)
                      : const Color(0xFFE8F2FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services_rounded,
                            color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Unlock Full Dental Purchasing',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to place orders, access order tracking, register equipment warranties, and download official VAT invoices.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => context.push(AppRoutes.login),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () => context.push(AppRoutes.signup),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: cs.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // B2C to B2B Upgrade Banner (if B2C)
            if (isAuthenticated && !isB2b) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFD97706), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upgrade to B2B Dental Clinic Tier',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Submit your clinic license to unlock wholesale bulk rates on 5+ piece orders.',
                            style: tt.bodySmall?.copyWith(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Shopping Section
            _buildSection(
              context: context,
              title: 'Shopping',
              tiles: [
                _buildTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  subtitle: 'Track shipments & past invoices',
                  onTap: () => context.push(AppRoutes.orders),
                ),
                if (isB2b)
                  _buildTile(
                    icon: Icons.request_quote_outlined,
                    title: 'Clinic Quotations & RFQ',
                    subtitle: 'Custom bulk pricing & proforma requests',
                    onTap: () => context.push(AppRoutes.quotations),
                  ),
                _buildTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Wishlist',
                  subtitle: 'Saved dental products & kits',
                  onTap: () => context.push(AppRoutes.wishlist),
                ),
                _buildTile(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Addresses',
                  subtitle: 'Clinic and warehouse locations',
                  onTap: () => context.push(AppRoutes.addresses),
                ),
                _buildTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Product Reviews',
                  subtitle: 'Ratings you gave for instruments',
                  onTap: () => context.push(AppRoutes.reviews),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support & Services Section
            _buildSection(
              context: context,
              title: 'Support & Services',
              tiles: [
                _buildTile(
                  icon: Icons.assignment_return_outlined,
                  title: 'Returns & Replacements',
                  subtitle: 'Medical supply return requests',
                  onTap: () => context.push(AppRoutes.returns),
                ),
                _buildTile(
                  icon: Icons.verified_outlined,
                  title: 'Equipment Warranty',
                  subtitle: 'Register handpieces & curing lights',
                  onTap: () => context.push(AppRoutes.warranty),
                ),
                _buildTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Center & FAQs',
                  subtitle: 'Payment, delivery, and ordering info',
                  onTap: () => context.push(AppRoutes.helpCenter),
                ),
                _buildTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Contact Dental Support',
                  subtitle: '+880 9612-TEETH (83384)',
                  onTap: () => context.push(AppRoutes.helpCenter),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Settings & Preferences
            _buildSection(
              context: context,
              title: 'App Settings',
              tiles: [
                _buildTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance / Theme',
                  subtitle: 'Switch between light, dark, or system',
                  onTap: () => _showThemeDialog(context),
                ),
                _buildTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Settings',
                  subtitle: 'Order updates and stock alerts',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _buildTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy & Terms',
                  subtitle: 'Medical data and transaction safety',
                  onTap: () => context.push(AppRoutes.helpCenter),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sign Out / Sign In Action Button
            if (isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(
                        color: cs.error.withValues(alpha: 0.5), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Sign Out of TeethTech',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text(
                    'Sign In to TeethTech Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // App Version Footer
            Text(
              'TeethTech Platform v1.0.0 (Production Build)\nCertified Dental Supply Marketplace',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> tiles,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
