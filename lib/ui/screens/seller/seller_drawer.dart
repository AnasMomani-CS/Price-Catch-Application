// lib/ui/screens/seller/seller_drawer.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:price_catch_project/ui/screens/seller/seller_dashboard.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/settings_provider.dart';
import 'products.dart';
import 'seller_profile_screen.dart';
import '../auth/seller_login_screen.dart';
import 'offers.dart';
import 'store_status.dart';

class SellerDrawer extends StatelessWidget {
  const SellerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final seller = profile.sellerProfile;
    final settings = context.watch<SettingsProvider>();
    final currentPhotoUrl = seller?.photoUrl;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sellerColor = const Color(0xFF64748B);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // 🟢 Custom Header: موسط مع الحفاظ على المقاسات الأصلية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom:
                    BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //  الأنيميشن المطاطي 
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: CircleAvatar(
                    radius: 36, // 🟢 رجعنا الحجم الطبيعي للـ Avatar
                    backgroundColor: sellerColor.withOpacity(0.2),
                    backgroundImage:
                        (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty)
                            ? (currentPhotoUrl.startsWith('http')
                                ? NetworkImage(currentPhotoUrl) as ImageProvider
                                : FileImage(File(currentPhotoUrl)))
                            : null,
                    child: (currentPhotoUrl == null || currentPhotoUrl.isEmpty)
                        ? Text(
                            seller?.name.isNotEmpty == true
                                ? seller!.name[0].toUpperCase()
                                : "S",
                            style: TextStyle(
                                fontSize: 24, 
                                color: sellerColor,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                //  الاسم 
                Text(
                  seller?.name ?? settings.translate('loading'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                //  الإيميل 
                Text(
                  seller?.email ?? "",
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _buildAnimatedListTile(
                  icon: Icons.home_filled,
                  title: settings.translate('Home'),
                  iconColor: sellerColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SellerDashboardScreen()),
                    );
                  },
                ),
                _buildAnimatedListTile(
                  icon: Icons.person_outline,
                  title: settings.translate('profile'),
                  iconColor: sellerColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SellerProfileScreen()),
                    );
                  },
                ),
                _buildAnimatedListTile(
                  icon: Icons.local_offer_outlined,
                  title: "Manage Offers",
                  iconColor: sellerColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageOffersScreen()),
                    );
                  },
                ),
                _buildAnimatedListTile(
                  icon: Icons.inventory_2_outlined,
                  title: "Manage Products",
                  iconColor: sellerColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageProductsScreen()),
                    );
                  },
                ),
                _buildAnimatedListTile(
                  icon: Icons.store_rounded,
                  title: "Store Status",
                  iconColor: sellerColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StoreStatusScreen()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SwitchListTile(
                    activeColor: sellerColor,
                    secondary:
                        Icon(Icons.dark_mode_outlined, color: sellerColor),
                    title: Text(settings.translate('dark_mode'),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87)),
                    value: settings.isDarkMode,
                    onChanged: (bool value) {
                      settings.toggleTheme(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildAnimatedListTile(
            icon: Icons.logout_rounded,
            title: settings.translate('logout'),
            iconColor: AppColors.errorRed,
            isDark: isDark,
            textColor: AppColors.errorRed,
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SellerLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnimatedListTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: textColor != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
