// lib/ui/screens/user/my_catches_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/catches_provider.dart';
import '../../../../data/models/catch_item.dart';

class MyCatchesScreen extends StatefulWidget {
  const MyCatchesScreen({super.key});

  @override
  State<MyCatchesScreen> createState() => _MyCatchesScreenState();
}

class _MyCatchesScreenState extends State<MyCatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        final catchesProv =
            Provider.of<CatchesProvider>(context, listen: false);

        // البدء بالاستماع للتغييرات (Stream)
        catchesProv.listenToCatches(auth.user!.uid);

        // تشغيل المزامنة لضمان تحديث السعر إذا تغير عند التاجر
        catchesProv.startLivePriceSync(auth.user!.uid);
      }
    });
  }

  void _showEditTargetPriceDialog(CatchItem item, String userId) {
    final TextEditingController priceController =
        TextEditingController(text: item.targetPrice.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Target Price",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Price: ${item.currentPrice} JOD",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87), 
              decoration: InputDecoration(
                labelText: "New Target Price (JOD)",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.attach_money_rounded,
                    color: AppColors.userPrimary),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.userPrimary),
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              double? newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                Provider.of<CatchesProvider>(context, listen: false)
                    .updateTargetPrice(userId, item.id, newPrice);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.userPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Save",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🟢 دالة تأكيد الحذف
  void _confirmDelete(String catchId, String userId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor, // 🟢 مرونة لون النافذة
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove Catch?",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text("Are you sure you want to stop tracking this product?",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CatchesProvider>(context, listen: false)
                  .removeCatch(userId, catchId);
              Navigator.pop(context);
            },
            child: const Text("Remove",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catchesProv = context.watch<CatchesProvider>();
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, 
        elevation: 0,
        centerTitle: true,
        title: Text("My Catches 🛒",
            style: TextStyle(
                color:
                    isDark ? Colors.white : Colors.black87, 
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: catchesProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.userPrimary))
          : catchesProv.catches.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: catchesProv.catches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final item = catchesProv.catches[index];
                    return _buildCatchCard(item, userId, catchesProv, isDark);
                  },
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 100,
              color: isDark
                  ? Colors.grey[700]
                  : Colors.grey[300]), // 🟢 مرونة لون الأيقونة
          const SizedBox(height: 20),
          Text("Your Watchlist is Empty",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white70
                      : Colors.black54)), 
          const SizedBox(height: 10),
          Text(
              "Search for products and tap the heart\nicon to track their prices.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCatchCard(
      CatchItem item, String userId, CatchesProvider catchesProv, bool isDark) {
    bool isTargetReached = item.currentPrice <= item.targetPrice;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isTargetReached
                ? Colors.green.withOpacity(0.5)
                : Colors.grey
                    .withOpacity(isDark ? 0.2 : 0.1), 
            width: isTargetReached ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black
                  .withOpacity(isDark ? 0.2 : 0.03), 
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: isDark
                            ? Colors.grey[800]
                            : Colors.grey[100], //  مرونة لون الـ Placeholder
                        child: const Icon(Icons.image, color: Colors.grey))),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87), 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.sellerName,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Current: ",
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text("${item.currentPrice.toStringAsFixed(2)} JOD",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87, 
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                onPressed: () => _confirmDelete(item.id, userId),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.grey[800]
                    : Colors.grey[200]), 
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showEditTargetPriceDialog(item, userId),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.userPrimary.withOpacity(
                          0.1), 
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.track_changes_rounded,
                            size: 18, color: AppColors.userPrimary),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Target Price",
                                style: TextStyle(
                                    color: AppColors.userPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            Text("${item.targetPrice.toStringAsFixed(2)} JOD",
                                style: const TextStyle(
                                    color: AppColors.userPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_rounded,
                            size: 16, color: AppColors.userPrimary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: item.isAlertActive
                      ? Colors.orange.withOpacity(0.1)
                      : (isDark
                          ? Colors.grey[800]
                          : Colors.grey[100]), // 🟢 مرونة لون زر الإشعارات
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    item.isAlertActive
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: item.isAlertActive ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    catchesProv.toggleAlert(
                        userId, item.id, item.isAlertActive);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(item.isAlertActive
                            ? "Alerts paused for this item."
                            : "Alerts activated! We'll notify you."),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (isTargetReached) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text("Target Reached! Catch it now.",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
