import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  //  القوائم المنفصلة لمنع تضارب البيانات
  List<Map<String, dynamic>> _searchResults =
      []; // لنتائج بحث المنتجات (HomeScreen)
  List<Map<String, dynamic>> _nearbySellers =
      []; // للمحلات القريبة (Home Dashboard)
  List<Map<String, dynamic>> _allSellers =
      []; // نسخة الذاكرة الشاملة للمحلات (Master List)
  List<Map<String, dynamic>> _filteredStores =
      []; // نتائج شاشة الاستكشاف الجديدة (ExploreScreen)
  List<Map<String, dynamic>> _topCatches = []; // قائمة التخفيضات الكبرى

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get nearbySellers => _nearbySellers;
  List<Map<String, dynamic>> get filteredStores =>
      _filteredStores; // الجيتر المخصص للاكسبلور
  List<Map<String, dynamic>> get topCatches => _topCatches;

  void _clearState() {
    _errorMessage = null;
    _searchResults = [];
    notifyListeners();
  }

  //  جلب المتاجر وتعبئة القوائم الأساسية
  Future<void> fetchNearbySellers({double? userLat, double? userLng}) async {
    try {
      _isLoading = true;
      _nearbySellers = [];
      notifyListeners();

      QuerySnapshot snapshot = await _db.collection('sellers').get();
      List<Map<String, dynamic>> tempSellers = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;

        double? sLat = double.tryParse(data['lat']?.toString() ?? '');
        double? sLng = double.tryParse(data['lng']?.toString() ?? '');

        if (sLat != null &&
            sLng != null &&
            userLat != null &&
            userLng != null) {
          double distance = _calculateDistance(userLat, userLng, sLat, sLng);
          data['distance'] = distance;
          if (distance <= 50.0) tempSellers.add(data);
        } else {
          data['distance'] = 999.0;
          tempSellers.add(data);
        }
      }

      tempSellers.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));

      _nearbySellers = tempSellers;
      _allSellers = tempSellers; // تخزين الكل للذاكرة للفلترة السريعة
      _filteredStores = tempSellers; // القائمة الابتدائية لشاشة Explore
    } catch (e) {
      debugPrint("❌ Error fetching nearby sellers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //   فلترة المحلات (خاصة بشاشة Explore فقط)
  void filterStores({String? category, String? query}) {
    _filteredStores = _allSellers.where((seller) {
      bool matchesCategory = category == null ||
          category == "All" ||
          seller['category'] == category;
      bool matchesQuery = query == null ||
          query.isEmpty ||
          seller['name'].toString().toLowerCase().contains(query.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();

    notifyListeners(); // تحدث فقط شاشة Explore
  }

  //  جلب الـ Top Catches (التخفيضات)
  Future<void> fetchTopCatches() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      QuerySnapshot querySnapshot = await _db
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('discountPercentage', isGreaterThan: 0.0)
          .orderBy('discountPercentage', descending: true)
          .limit(15)
          .get();

      List<Map<String, dynamic>> tempCatches = [];

      for (var doc in querySnapshot.docs) {
        var productData = doc.data() as Map<String, dynamic>;
        productData['id'] = doc.id;

        String sellerId = productData['sellerId'] ?? '';
        if (sellerId.isNotEmpty) {
          DocumentSnapshot sellerDoc =
              await _db.collection('sellers').doc(sellerId).get();
          if (sellerDoc.exists) {
            productData['storeName'] = sellerDoc['name'] ?? 'Store';
          }
        }
        tempCatches.add(productData);
      }
      _topCatches = tempCatches;
    } catch (e) {
      debugPrint("❌ Error fetching top catches: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  زيادة المشاهدات والزيارات 
  Future<void> incrementStoreView(String sellerId) async {
    if (sellerId.isEmpty) return;
    try {
      await _db
          .collection('sellers')
          .doc(sellerId)
          .update({'viewsCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint("Error view: $e");
    }
  }

  Future<void> incrementStoreVisit(String sellerId) async {
    if (sellerId.isEmpty) return;
    try {
      DocumentReference sellerRef = _db.collection('sellers').doc(sellerId);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(sellerRef);
        if (!snapshot.exists) return;
        var data = snapshot.data() as Map<String, dynamic>;

        int currentVisits = (data['storeVisits'] ?? 0) + 1;
        int views = data['viewsCount'] ?? 1;
        double engagementGrowth = (currentVisits / views) * 2;

        transaction.update(sellerRef, {
          'storeVisits': currentVisits,
          'growthRate': double.parse(engagementGrowth.toStringAsFixed(1)),
          'lastVisitTimestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint("Error visit: $e");
    }
  }

  //  البحث والمقارنة (خاص بـ HomeScreen)
  Future<void> searchAndCompareProducts(String query,
      {double? userLat, double? userLng}) async {
    if (query.trim().isEmpty) {
      _clearState();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String searchQuery = query.trim().toLowerCase();
      List<Map<String, dynamic>> tempResults = [];
      Set<String> uniqueSellerIds = {};

      QuerySnapshot productsSnapshot = await _db
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in productsSnapshot.docs) {
        final productData = doc.data() as Map<String, dynamic>;
        final String productName =
            (productData['name'] ?? '').toString().toLowerCase();

        if (productName.contains(searchQuery)) {
          String sellerId = productData['sellerId'] ?? '';
          if (sellerId.isNotEmpty) {
            DocumentSnapshot sellerDoc =
                await _db.collection('sellers').doc(sellerId).get();
            if (sellerDoc.exists) {
              final sellerData = sellerDoc.data() as Map<String, dynamic>;
              uniqueSellerIds.add(sellerId);

              double distance = _calculateDistance(
                  userLat,
                  userLng,
                  double.tryParse(sellerData['lat']?.toString() ?? ''),
                  double.tryParse(sellerData['lng']?.toString() ?? ''));

              tempResults.add({
                'product': productData,
                'productId': doc.id,
                'seller': sellerData,
                'distance': distance,
              });
            }
          }
        }
      }

      tempResults.sort((a, b) {
        double priceA =
            double.tryParse(a['product']['price'].toString()) ?? 0.0;
        double priceB =
            double.tryParse(b['product']['price'].toString()) ?? 0.0;
        return priceA.compareTo(priceB);
      });

      _searchResults = tempResults;
      _incrementViewsBatch(uniqueSellerIds);
    } catch (e) {
      _errorMessage = "Error searching: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _incrementViewsBatch(Set<String> sellerIds) async {
    if (sellerIds.isEmpty) return;
    try {
      WriteBatch batch = _db.batch();
      for (String uid in sellerIds) {
        batch.update(_db.collection('sellers').doc(uid),
            {'viewsCount': FieldValue.increment(1)});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Batch error: $e");
    }
  }

  double _calculateDistance(
      double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null)
      return double.infinity;
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
