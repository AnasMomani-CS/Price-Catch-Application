// lib/ui/screens/user/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/search_provider.dart';
import 'store_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    "All",
    "Grocery",
    "Electronics",
    "Coffee Shops",
    "Supermarkets",
    "Supermarkets + Grocery",
    "Restaurants",
    "Bakery",
    "Butcher Shop",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    final searchProv = context.watch<SearchProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Explore Stores",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isDark ? Colors.white : Colors.black87)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. شريط البحث عن المحلات
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => searchProv.filterStores(
                  query: val, category: selectedCategory),
              style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black87), // 🟢 لون نص البحث
              decoration: InputDecoration(
                hintText: "Search for a store name...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.userPrimary),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. (Horizontal List)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(categories[index],
                        style: TextStyle(
                            color: isDark && !isSelected
                                ? Colors.white70
                                : (isSelected
                                    ? AppColors.userPrimary
                                    : Colors.black87))),
                    selected: isSelected,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
                    selectedColor: AppColors.userPrimary.withOpacity(0.2),
                    checkmarkColor: AppColors.userPrimary,
                    onSelected: (bool value) {
                      setState(() => selectedCategory = categories[index]);
                      searchProv.filterStores(
                          category: categories[index],
                          query: _searchController.text);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          //   filteredStores 
          Expanded(
            child: searchProv.filteredStores.isEmpty
                ? _buildNoResults(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchProv.filteredStores.length,
                    itemBuilder: (context, index) {
                      //  القائمة تحتوي على بيانات المحل مباشرة
                      final seller = searchProv.filteredStores[index];
                      return _buildStoreRectangleCard(seller, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreRectangleCard(Map<String, dynamic> seller, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StoreDetailScreen(seller: seller))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black
                    .withOpacity(isDark ? 0.2 : 0.05), // 🟢 ظل متناسق
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
              child: Image.network(
                seller['photoUrl'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(Icons.store,
                        color: isDark ? Colors.white54 : Colors.grey)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seller['name'] ?? "Store Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 5),
                  Text(seller['category'] ?? "General",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(seller['rating']?.toString() ?? "4.5",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 60, color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 10),
          Text("No stores found", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
