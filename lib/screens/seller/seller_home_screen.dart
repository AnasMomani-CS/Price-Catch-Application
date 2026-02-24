import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid; // البائع الحالي
  final storeRef = FirebaseFirestore.instance.collection('stores');

  // التحكم في حالة المحل (Open/Closed/Busy)
  void updateStoreStatus(String status) async {
    await storeRef.doc(uid).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: storeRef.doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final storeData = snapshot.data!;
        final storeName = storeData['name'];
        final storeStatus = storeData['status'];
        final products = List.from(storeData['products'] ?? []);
        final offers = List.from(storeData['offers'] ?? []);
        final reviews = List.from(storeData['reviews'] ?? []);

        return Scaffold(
          appBar: AppBar(
            title: Text("$storeName • $storeStatus"),
            backgroundColor: Colors.blueGrey.shade600,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blueGrey.shade600),
                  child: Text(
                    storeName,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Store Settings'),
                  onTap: () {
                    // فتح إعدادات المحل
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Manage Products'),
                  onTap: () {
                    // فتح صفحة إدارة المنتجات
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer),
                  title: const Text('Manage Offers'),
                  onTap: () {
                    // فتح صفحة إدارة العروض
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Store Status'),
                  trailing: DropdownButton<String>(
                    value: storeStatus,
                    items: const [
                      DropdownMenuItem(value: 'Open', child: Text('Open')),
                      DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                      DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    ],
                    onChanged: (value) {
                      if (value != null) updateStoreStatus(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.reviews),
                  title: const Text('View Reviews'),
                  onTap: () {
                    // فتح صفحة المراجعات
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Dark / Light Mode'),
                  onTap: () {
                    // Toggle ثيم
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/auth_choice');
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // بطاقات الإحصاءات
                Card(
                  child: ListTile(
                    title: Text("Products: ${products.length}"),
                    subtitle: const Text("Manage your products"),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: Text("Offers: ${offers.length}"),
                    subtitle: const Text("Manage your offers"),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: Text("Reviews: ${reviews.length}"),
                    subtitle: const Text("Check customer reviews"),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
