import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // الإضافة 1: استدعاء البروفايدر
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart'; // الإضافة 2: عشان نجيب الـ UID تبع البائع
import '../../../../providers/offers_provider.dart'; // الإضافة 3: عشان نجيب ونحفظ العروض

class ManageOffersScreen extends StatefulWidget {
  const ManageOffersScreen({super.key});

  @override
  State<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<ManageOffersScreen> {
  // تم حذف القائمة المحلية المكتوبة يدوياً لأننا سنعتمد على الفايربيس الآن

  @override
  void initState() {
    super.initState();
    // الإضافة 4: جلب العروض من الفايربيس فور فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<OffersProvider>(context, listen: false)
            .fetchOffers(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // الإضافة 5: مراقبة العروض القادمة من الفايربيس
    final offersProv = context.watch<OffersProvider>();
    final offers = offersProv.offers;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.sellerDeepDark),
        title: const Text(
          "Manage Offers",
          style: TextStyle(
            color: AppColors.sellerDeepDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: () => _showAddEditBottomSheet(
                  context, null, null), // إضافة عرض جديد
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.userPrimary, // اللون البرتقالي
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(),

          // الإضافة 6: إظهار مؤشر تحميل أثناء جلب البيانات من الفايربيس
          if (offersProv.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.userPrimary),
              ),
            )
          // إذا كانت القائمة فارغة، نظهر رسالة لطيفة
          else if (offers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 15),
                    Text(
                      "No offers yet!",
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Tap the + button above to add your first offer.",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          // إذا كان فيها عروض، نعرضها
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: offers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return _buildOfferCard(offer, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.userPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.userPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.userPrimary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined,
                color: AppColors.userPrimary, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Attract More Customers!",
                  style: TextStyle(
                    color: AppColors.sellerDeepDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add your store's active deals and let users catch them.",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    bool isActive = offer["isActive"] ?? true;
    String offerId = offer["id"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.successGreen.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        color: isActive ? AppColors.successGreen : Colors.grey,
                        size: 10),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? "Active" : "Inactive",
                      style: TextStyle(
                        color: isActive
                            ? AppColors.successGreen
                            : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  //  تفعيل / إيقاف العرض من الفايربيس
                  Provider.of<OffersProvider>(context, listen: false)
                      .toggleOfferStatus(offerId, isActive);
                },
                child: Text(
                  isActive ? "Deactivate" : "Activate",
                  style: TextStyle(
                    color: isActive ? Colors.grey : AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            offer["text"] ?? "",
            style: const TextStyle(
              color: AppColors.sellerDeepDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  bgColor: const Color(0xFFE3F2FD),
                  textColor: Colors.blue[700]!,
                  onTap: () =>
                      _showAddEditBottomSheet(context, offer["text"], offerId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.delete_outline,
                  label: "Delete",
                  bgColor: const Color(0xFFFFEBEE),
                  textColor: Colors.red[700]!,
                  onTap: () {
                    // الإضافة 8: حذف العرض من الفايربيس
                    Provider.of<OffersProvider>(context, listen: false)
                        .deleteOffer(offerId);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditBottomSheet(
      BuildContext context, String? currentText, String? offerId) {
    final TextEditingController controller =
        TextEditingController(text: currentText ?? "");
    final bool isEditing = currentText != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "Edit Offer" : "Add New Offer",
              style: const TextStyle(
                color: AppColors.sellerDeepDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: "Example: 20% off on all beverages...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.userPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.userPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  // استدعاء التحديث أو الإضافة من الفايربيس
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  final offersProv =
                      Provider.of<OffersProvider>(context, listen: false);

                  if (auth.user != null) {
                    if (isEditing) {
                      await offersProv.updateOffer(
                          offerId!, controller.text.trim());
                    } else {
                      await offersProv.addOffer(
                          auth.user!.uid, controller.text.trim());
                    }
                  }

                  if (mounted) Navigator.pop(context);
                },
                child: Text(
                  isEditing ? "Save Changes" : "Add Offer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
