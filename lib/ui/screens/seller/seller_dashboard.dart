// lib/ui/screens/seller/seller_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import 'products.dart';
import 'seller_drawer.dart';
import 'offers.dart';
import 'store_status.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // دالة لتحديث البيانات يدوياً عند الحاجة
  void _refreshData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<ProfileProvider>(context, listen: false)
          .fetchProfile(auth.user!.uid, 'seller');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final seller = profile.sellerProfile;
    final authProv = context.watch<AuthProvider>();
    final currentStatus = authProv.storeStatus;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      // 🟢 التعديل الأول: endDrawer بتخلي القائمة تطلع من اليمين
      endDrawer: const SellerDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                name: seller?.name ?? "Loading...",
                category: seller?.category ?? "Category...",
                status: currentStatus,
              ),
              const SizedBox(height: 20),
              //  تمرير بيانات السيلر كاملة لقسم الإحصائيات
              _buildOverviewSection(seller),
              const SizedBox(height: 25),
              _buildQuickActionsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      {required String name,
      required String category,
      required String status}) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'Open':
        badgeColor = Colors.teal;
        badgeText = "Store is Open";
        break;
      case 'Busy':
        badgeColor = Colors.orange;
        badgeText = "Store is Busy";
        break;
      case 'Closed':
        badgeColor = Colors.red[400]!;
        badgeText = "Store is Closed";
        break;
      default:
        badgeColor = Colors.teal;
        badgeText = "Store is Open";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.sellerDeepDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Seller Dashboard",
                style: TextStyle(
                    color: AppColors.sellerLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2),
              ),
              IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
          Text(
            category,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: badgeColor, size: 10),
                const SizedBox(width: 6),
                Text(
                  badgeText,
                  style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(var seller) {
    //  ربط القيم بأسماء الحقول الحقيقية من الفايربيس
    int views = seller?.viewsCount ?? 0;
    int visits =
        seller?.storeVisits ?? 0; // تم التعديل من visitsCount لـ storeVisits
    double growth = seller?.growthRate?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "OVERVIEW",
            style: TextStyle(
                color: AppColors.sellerPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            title: "Total Views",
            value: views.toString(),
            icon: Icons.visibility_outlined,
            iconColor: Colors.blueAccent,
            isFullWidth: true,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "Store Visits",
                  value: visits.toString(),
                  icon: Icons.storefront_outlined,
                  iconColor: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  title: "Growth",
                  value:
                      "${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%",
                  icon: growth >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  iconColor:
                      growth >= 0 ? Colors.purpleAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              if (isFullWidth)
                const Icon(Icons.show_chart,
                    color: AppColors.sellerLight, size: 24),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.sellerDeepDark,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "QUICK ACTIONS",
            style: TextStyle(
                color: AppColors.sellerPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),
          _buildActionCard(
            title: "Manage Offers",
            subtitle: "Create or edit your active catches",
            icon: Icons.local_offer_outlined,
            isHighlighted: true,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageOffersScreen()));
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: "Manage Products",
            subtitle: "Add or update your store items",
            icon: Icons.inventory_2_outlined,
            cardBgColor: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1976D2),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageProductsScreen()));
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: "Store Status",
            subtitle: "Update open hours and details",
            icon: Icons.store_rounded,
            cardBgColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF388E3C),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StoreStatusScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isHighlighted = false,
    Color? cardBgColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.userPrimary
              : (cardBgColor ?? Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
          border: isHighlighted
              ? null
              : Border.all(color: AppColors.sellerLight, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.white.withOpacity(0.2)
                    : (iconColor?.withOpacity(0.1) ??
                        AppColors.backgroundLight),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isHighlighted
                      ? Colors.white
                      : (iconColor ?? AppColors.sellerPrimary),
                  size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: isHighlighted
                              ? Colors.white
                              : AppColors.sellerPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color:
                              isHighlighted ? Colors.white70 : Colors.grey[600],
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isHighlighted
                    ? Colors.white
                    : (iconColor ?? AppColors.sellerPrimary)),
          ],
        ),
      ),
    );
  }
}
