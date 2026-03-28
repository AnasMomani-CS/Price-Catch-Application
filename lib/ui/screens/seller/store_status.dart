import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';

class StoreStatusScreen extends StatefulWidget {
  const StoreStatusScreen({super.key});

  @override
  State<StoreStatusScreen> createState() => _StoreStatusScreenState();
}

class _StoreStatusScreenState extends State<StoreStatusScreen> {
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    _selectedStatus = authProv.storeStatus;
  }

  Color _getActiveColor() {
    switch (_selectedStatus) {
      case "Open":
        return Colors.teal;
      case "Busy":
        return Colors.orange;
      case "Closed":
        return Colors.red[400]!;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.sellerDeepDark),
        title: const Text(
          "Store Status",
          style: TextStyle(
            color: AppColors.sellerDeepDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 البانر باللون البنفسجي الفخم
            _buildInfoBanner(),
            const SizedBox(height: 30),

            // --- خيارات الحالة ---
            _buildStatusOption(
              title: "Open",
              subtitle: "Accepting new orders normally",
              value: "Open",
              icon: Icons.storefront_outlined,
              activeColor: Colors.teal, // الأخضر البارد
            ),
            const SizedBox(height: 15),
            _buildStatusOption(
              title: "Busy",
              subtitle: "High traffic, delivery might take longer",
              value: "Busy",
              icon: Icons.access_time_rounded,
              activeColor: Colors.orange, // برتقالي للزحمة
            ),
            const SizedBox(height: 15),
            _buildStatusOption(
              title: "Closed",
              subtitle: "Not accepting orders currently",
              value: "Closed",
              icon: Icons.door_front_door_outlined,
              activeColor: Colors.red[400]!, // أحمر للإغلاق
            ),

            const Spacer(),

            // --- زر الحفظ (صار لونه يتغير ديناميكياً) ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActiveColor(), // 🟢 اللون المتغير
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  disabledBackgroundColor: _getActiveColor().withOpacity(0.5),
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);

                        final authProv =
                            Provider.of<AuthProvider>(context, listen: false);

                        bool success =
                            await authProv.updateStoreStatus(_selectedStatus);

                        setState(() => _isSaving = false);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Store status updated to $_selectedStatus!"),
                              backgroundColor:
                                  _getActiveColor(), // لون الإشعار كمان بيتغير!
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Save Status",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.08), // خلفية بنفسجية هادية
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_mall_directory_rounded,
                color: Colors.deepPurple, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Set your store availability",
                  style: TextStyle(
                    color: AppColors.sellerDeepDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Let customers know if you are ready to receive orders right now.",
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

  Widget _buildStatusOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color activeColor,
  }) {
    bool isSelected = _selectedStatus == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.2)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[500],
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected ? activeColor : AppColors.sellerDeepDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
