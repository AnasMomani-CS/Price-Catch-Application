// lib/providers/catches_provider.dart

import 'dart:async'; //  لإدارة الـ StreamSubscriptions
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/catch_item.dart';
import '../data/services/notification_service.dart'; 

class CatchesProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<CatchItem> _catches = [];
  bool _isLoading = false;

  StreamSubscription? _catchesSubscription;
  StreamSubscription? _priceSyncSubscription;

  List<CatchItem> get catches => _catches;
  bool get isLoading => _isLoading;

  void listenToCatches(String userId) {
    if (userId.isEmpty) return;

    _isLoading = true;

    _catchesSubscription?.cancel();

    _catchesSubscription = _db
        .collection('users')
        .doc(userId)
        .collection('catches')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _catches = snapshot.docs
          .map((doc) => CatchItem.fromMap(doc.data(), doc.id))
          .toList();

      for (var item in _catches) {
        if (item.isAlertActive && item.currentPrice <= item.targetPrice) {
          NotificationService.showPriceAlert(item.name, item.currentPrice);
        }
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("❌ Stream Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  void startLivePriceSync(String userId) {
    if (userId.isEmpty) return;

    _priceSyncSubscription?.cancel();

    // نراقب المنتجات الفعالة فقط
    _priceSyncSubscription = _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((productsSnapshot) {
      // عمل خريطة (Map) سريعة للأسعار الحالية من جدول المنتجات
      Map<String, double> currentMarketPrices = {
        for (var doc in productsSnapshot.docs)
          doc.id: (doc.data()['price'] ?? 0.0).toDouble()
      };

      for (var myCatch in _catches) {
        if (currentMarketPrices.containsKey(myCatch.productId)) {
          double latestMarketPrice = currentMarketPrices[myCatch.productId]!;

          if (latestMarketPrice != myCatch.currentPrice) {
            _db
                .collection('users')
                .doc(userId)
                .collection('catches')
                .doc(myCatch.id)
                .update({'currentPrice': latestMarketPrice});
          }
        }
      }
    });
  }

  Future<bool> addCatch(String userId, CatchItem item) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('catches')
          .add(item.toMap());
      return true;
    } catch (e) {
      debugPrint("❌ Error adding catch: $e");
      return false;
    }
  }

  Future<bool> removeCatch(String userId, String catchId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('catches')
          .doc(catchId)
          .delete();
      return true;
    } catch (e) {
      debugPrint("❌ Error removing catch: $e");
      return false;
    }
  }

  Future<void> toggleAlert(
      String userId, String catchId, bool currentStatus) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('catches')
          .doc(catchId)
          .update({'isAlertActive': !currentStatus});
    } catch (e) {
      debugPrint("❌ Error toggling alert: $e");
    }
  }

  Future<void> updateTargetPrice(
      String userId, String catchId, double newTarget) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('catches')
          .doc(catchId)
          .update({'targetPrice': newTarget});
    } catch (e) {
      debugPrint("❌ Error updating target price: $e");
    }
  }

  // إغلاق الاشتراكات عند مسح الـ Provider من الذاكرة
  @override
  void dispose() {
    _catchesSubscription?.cancel();
    _priceSyncSubscription?.cancel();
    super.dispose();
  }
}
