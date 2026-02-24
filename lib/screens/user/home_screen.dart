import 'package:flutter/material.dart';
//import 'package:price_catch_project/screens/splash/splash_screen.dart'; // لاحقاً ننشأه
//import 'package:google_maps_flutter/google_maps_flutter.dart'; // لو بدنا خرائط
// لاحقًا: import 'package:your_project/screens/store_details_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool isDarkMode = false; // للتحويل بين Dark/Light
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // بيانات تجريبية للمحلات
  final List<Map<String, dynamic>> stores = [
    {
      "name": "Super Mart",
      "rating": 4.5,
      "status": "Open",
      "distance": "1.2 km",
      "image": "assets/images/store1.png",
      "offers": ["10% off", "Buy 1 Get 1"],
    },
    {
      "name": "Fresh Fruits",
      "rating": 4.0,
      "status": "Closed",
      "distance": "0.8 km",
      "image": "assets/images/store2.png",
      "offers": [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(), // الشريط الجانبي
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(), // الهيدر مع اسم المستخدم وأيقونة الهامبرغر
              _buildSearchBar(), // حقل البحث والفلاتر
              Expanded(child: _buildStoreCards()), // قائمة المحلات
            ],
          ),
        ),
      ),
    );
  }

  // ================= Header =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(width: 10),
              const Text(
                'Welcome, Anas', // لاحقًا نبدلها باسم المستخدم الحقيقي
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  // ================= Drawer / Sidebar =================
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange.shade800),
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _drawerItem('Profile', Icons.person),
          _drawerItem('Filters', Icons.filter_list),
          _drawerItem(
            'Dark/Light Mode',
            Icons.brightness_6,
            onTap: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          _drawerItem('General Settings', Icons.settings),
          _drawerItem(
            'Logout',
            Icons.logout,
            onTap: () {
              // TODO: تنفيذ تسجيل الخروج
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: onTap ?? () {},
      hoverColor: Colors.orange.shade800,
      selectedTileColor: Colors.orange.shade800.withOpacity(0.2),
    );
  }

  // ================= Search Bar =================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search stores...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // TODO: عرض فلاتر
            },
          ),
        ),
      ),
    );
  }

  // ================= Store Cards =================
  Widget _buildStoreCards() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return GestureDetector(
          onTap: () {
            // TODO: فتح شاشة تفاصيل المحل
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Image.asset(
                    store['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Rating: ${store['rating']} ⭐'),
                        Text('Status: ${store['status']}'),
                        Text('Distance: ${store['distance']}'),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
