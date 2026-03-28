// lib/ui/screens/user/store_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/products_provider.dart';
import '../../../../providers/offers_provider.dart';
import '../../../../providers/search_provider.dart';
import '../../../../core/theme/app_colors.dart';

class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> seller;
  const StoreDetailScreen({super.key, required this.seller});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sellerId = widget.seller['uid'] ?? '';
      if (sellerId.isNotEmpty) {
        Provider.of<SearchProvider>(context, listen: false)
            .incrementStoreView(sellerId);
        Provider.of<ProductsProvider>(context, listen: false)
            .fetchProducts(sellerId);
        Provider.of<OffersProvider>(context, listen: false)
            .fetchOffers(sellerId);
      }
    });
  }

  Future<void> _openMap(String urlString) async {
    if (urlString.isEmpty || urlString == "Not Set") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Store location link is not set")),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductsProvider>();
    final offersProv = context.watch<OffersProvider>();

    final activeOffers =
        offersProv.offers.where((o) => o['isActive'] == true).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.seller['photoUrl'] != null &&
                      widget.seller['photoUrl'].isNotEmpty
                  ? Image.network(widget.seller['photoUrl'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.storefront_rounded,
                          size: 60, color: Colors.grey)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(widget.seller['name'] ?? "Store",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold))),
                        _buildStatusBadge(widget.seller['storeStatus']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.userPrimary, size: 18),
                            Text(
                              " ${widget.seller['distance'] != null && widget.seller['distance'] < 900 ? widget.seller['distance'].toStringAsFixed(1) + ' km away' : 'Location not set'}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Dist: ${widget.seller['distance']} | Lat: ${widget.seller['lat']}",
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildInfoCard(
                      icon: Icons.info_outline_rounded,
                      label: "ABOUT STORE",
                      value: widget.seller['description'] ??
                          "No description provided",
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.phone_in_talk_outlined,
                            label: "CALL",
                            value: widget.seller['phoneNumber'] ??
                                widget.seller['phone'] ??
                                "N/A",
                            onTap: () {
                              String? phone = widget.seller['phoneNumber'] ??
                                  widget.seller['phone'];
                              if (phone != null) _makeCall(phone);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.category_outlined,
                            label: "CATEGORY",
                            value: widget.seller['category'] ?? "General",
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    if (activeOffers.isNotEmpty) ...[
                      const Text("Active Offers 🏷️",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...activeOffers
                          .map((offer) => _buildOfferItem(offer['text'] ?? '')),
                      const SizedBox(height: 25),
                    ],
                    const Text("Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    if (productProv.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productProv.activeProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12),
                        itemBuilder: (context, index) => _buildProductCard(
                            productProv.activeProducts[index]),
                      ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final sellerId = widget.seller['uid'] ?? '';
                          if (sellerId.isNotEmpty) {
                            Provider.of<SearchProvider>(context, listen: false)
                                .incrementStoreVisit(sellerId);
                          }
                          _openMap(widget.seller['address'] ?? '');
                        },
                        icon: const Icon(Icons.navigation_rounded,
                            color: Colors.white),
                        label: const Text("Go to Store",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.userPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isFullWidth = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints: const BoxConstraints(minHeight: 85),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: isFullWidth
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.userPrimary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      maxLines: isFullWidth ? 10 : 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    if (status == "Open") {
      color = Colors.green;
    } else if (status == "Busy") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(status ?? "Closed",
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    double oldPrice = double.tryParse(product['originalPrice']?.toString() ??
            product['price']?.toString() ??
            '0.0') ??
        0.0;
    double discount =
        double.tryParse(product['discountPercentage']?.toString() ?? '0.0') ??
            0.0;
    double finalPrice =
        double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[200]!, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: product['imageUrl'] != null &&
                          product['imageUrl'].isNotEmpty
                      ? Image.network(product['imageUrl'],
                          width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[100],
                          child: const Center(
                              child: Icon(Icons.image, color: Colors.grey))),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("-${discount.toInt()}%",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? "Product",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (discount > 0)
                  Text("${oldPrice.toStringAsFixed(2)} JOD",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough)),
                Text("${finalPrice.toStringAsFixed(2)} JOD",
                    style: const TextStyle(
                        color: AppColors.userPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
