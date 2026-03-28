// lib/ui/screens/user/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../providers/search_provider.dart';
import '../../../../providers/catches_provider.dart';
import '../../../../data/models/catch_item.dart';
import '../auth/user_login_screen.dart';
import 'store_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentUserPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final searchProv = Provider.of<SearchProvider>(context, listen: false);
    final catchesProv = Provider.of<CatchesProvider>(context, listen: false);

    if (auth.user != null) {
      await Provider.of<ProfileProvider>(context, listen: false)
          .fetchProfile(auth.user!.uid, 'user');

      catchesProv.listenToCatches(auth.user!.uid);
      catchesProv.startLivePriceSync(auth.user!.uid);
    }

    await _loadSellers();

    if (mounted) {
      await searchProv.fetchTopCatches();
    }
  }

  Future<void> _loadSellers() async {
    try {
      LocationPermission permission;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;
      setState(() => _currentUserPosition = position);

      await Provider.of<SearchProvider>(context, listen: false)
          .fetchNearbySellers(
        userLat: position.latitude,
        userLng: position.longitude,
      );
    } catch (e) {
      debugPrint("❌ Location Error: $e");
      if (mounted) {
        Provider.of<SearchProvider>(context, listen: false)
            .fetchNearbySellers();
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    final searchProv = Provider.of<SearchProvider>(context, listen: false);
    searchProv.searchAndCompareProducts(
      query,
      userLat: _currentUserPosition?.latitude,
      userLng: _currentUserPosition?.longitude,
    );
  }

  Future<void> _openMap(String urlString) async {
    if (urlString.isEmpty || urlString == "Not Set") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Store location link is not set")),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final user = profileProv.userProfile;
    final searchProv = context.watch<SearchProvider>();
    final catchesProv = context.watch<CatchesProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.user?.uid ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(
              userName: user?.name ?? "User",
              photoUrl: user?.photoUrl,
              isDark: isDark),
          Expanded(
            child: searchProv.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.userPrimary))
                : searchProv.errorMessage != null
                    ? _buildErrorWidget(searchProv.errorMessage!)
                    : searchProv.searchResults.isEmpty
                        ? _buildHomeDashboard(searchProv, isDark)
                        : _buildSearchResultsList(searchProv.searchResults,
                            userId, catchesProv, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      {required String userName, String? photoUrl, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color:
            AppColors.userPrimary, 
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome Back",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  Text(userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const UserLoginScreen()),
                    (route) => false,
                  );
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSearchField(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black
                  .withOpacity(isDark ? 0.3 : 0.12), 
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: TextStyle(
            color: isDark ? Colors.white : Colors.black87), 
        onSubmitted: _onSearchSubmitted,
        onChanged: (value) {
          if (value.trim().isEmpty) {
            Provider.of<SearchProvider>(context, listen: false)
                .searchAndCompareProducts("");
          }
        },
        decoration: InputDecoration(
          hintText: "Search for Products...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.userPrimary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          suffixIcon: null,
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(SearchProvider searchProv, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildSectionHeader("Nearby Stores", isDark),
        const SizedBox(height: 15),
        _buildNearbyStoresList(searchProv, isDark),
        const SizedBox(height: 30),
        _buildSectionHeader("Top Catches 🔥", isDark),
        const SizedBox(height: 15),
        searchProv.topCatches.isEmpty
            ? const Center(
                child: Text("No big discounts found today!",
                    style: TextStyle(color: Colors.grey)))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: searchProv.topCatches
                      .map((product) =>
                          _buildDiscountedProductCard(product, isDark))
                      .toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildDiscountedProductCard(
      Map<String, dynamic> product, bool isDark) {
    double oldPrice = double.tryParse(product['originalPrice']?.toString() ??
            product['price']?.toString() ??
            '0.0') ??
        0.0;
    double discount =
        double.tryParse(product['discountPercentage']?.toString() ?? '0.0') ??
            0.0;
    double newPrice =
        double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(product['imageUrl'] ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? "Product",
                    style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black87, 
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(product['storeName'] ?? "Store",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${newPrice.toStringAsFixed(2)} JOD",
                        style: const TextStyle(
                            color: AppColors.userPrimary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(oldPrice.toStringAsFixed(2),
                        style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(12)),
            child: Text("-${discount.toInt()}%",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 🟢 تم التعديل لحذف الزر والإبقاء على العنوان فقط بشكل أنظف
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildNearbyStoresList(SearchProvider searchProv, bool isDark) {
    return SizedBox(
      height: 200,
      child: searchProv.nearbySellers.isEmpty
          ? const Center(
              child: Text("Searching for stores...",
                  style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: searchProv.nearbySellers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final seller = searchProv.nearbySellers[index];
                return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StoreDetailScreen(seller: seller))),
                  child: _buildStoreCard(seller, isDark),
                );
              },
            ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> seller, bool isDark) {
    String name = seller['name'] ?? "Store";
    String status = seller['storeStatus'] ?? "Open";
    String? photoUrl = seller['photoUrl'];
    double distance = (seller['distance'] ?? 999.0).toDouble();

    Color statusColor = status == "Open"
        ? Colors.green
        : (status == "Busy" ? Colors.orange : Colors.red);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), // 🟢 ظل مرن
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : Colors.grey[100], // 🟢 مكان الصورة إذا فارغة
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18))),
                  child: (photoUrl != null && photoUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18)),
                          child: Image.network(photoUrl, fit: BoxFit.cover))
                      : const Center(
                          child: Icon(Icons.storefront_rounded,
                              size: 40, color: Colors.grey)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(status,
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
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black87, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 16, color: AppColors.userPrimary),
                    const SizedBox(width: 4),
                    Text(
                        distance > 900
                            ? "Calculating..."
                            : "${distance.toStringAsFixed(1)} km",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(List<Map<String, dynamic>> results,
      String userId, CatchesProvider catchesProv, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) =>
          _buildProductCatchCard(results[index], userId, catchesProv, isDark),
    );
  }

  Widget _buildProductCatchCard(Map<String, dynamic> result, String userId,
      CatchesProvider catchesProv, bool isDark) {
    final product = result['product'];
    final seller = result['seller'];

    String productId = result['productId'] ?? '';

    bool isFavorite =
        catchesProv.catches.any((item) => item.productId == productId);

    String catchId = isFavorite
        ? catchesProv.catches
            .firstWhere((item) => item.productId == productId)
            .id
        : '';

    double oldPrice = double.tryParse(product['originalPrice']?.toString() ??
            product['price']?.toString() ??
            '0.0') ??
        0.0;
    double discount =
        double.tryParse(product['discountPercentage']?.toString() ?? '0.0') ??
            0.0;
    double finalPrice =
        double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // 🟢 مرونة الكرت
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1))),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(product['imageUrl'] ?? '',
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          width: 75,
                          height: 75,
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          child: const Icon(Icons.image, color: Colors.grey)))),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] ?? "",
                        style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.black87, 
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    Text(seller['name'] ?? "",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                    if (discount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text("Save ${discount.toInt()}%",
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                  size: 26,
                ),
                onPressed: () async {
                  if (userId.isEmpty) return;

                  if (isFavorite) {
                    await catchesProv.removeCatch(userId, catchId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: const Text("Removed from My Catches"),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.grey[800]),
                      );
                    }
                  } else {
                    CatchItem newItem = CatchItem(
                      id: '',
                      productId: productId,
                      name: product['name'] ?? '',
                      imageUrl: product['imageUrl'] ?? '',
                      sellerName: seller['name'] ?? '',
                      currentPrice: finalPrice,
                      targetPrice: finalPrice,
                      isAlertActive: true,
                    );

                    await catchesProv.addCatch(userId, newItem);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Added to My Catches 🛒"),
                            duration: Duration(seconds: 1),
                            backgroundColor: AppColors.userPrimary),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (discount > 0)
                    Text("${oldPrice.toStringAsFixed(2)} JOD",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough)),
                  Text("${finalPrice.toStringAsFixed(2)} JOD",
                      style: const TextStyle(
                          color: AppColors.userPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  String sellerId = product['sellerId'] ?? '';

                  if (sellerId.isNotEmpty) {
                    Provider.of<SearchProvider>(context, listen: false)
                        .incrementStoreVisit(sellerId);
                  }

                  String mapUrl = seller['address'] ?? seller['location'] ?? '';
                  _openMap(mapUrl);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text("Catch Price",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Text(error, style: const TextStyle(color: Colors.red)));
  }
}
