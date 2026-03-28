import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OffersProvider with ChangeNotifier {
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get offers => _offers;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  جلب العروض الخاصة بتاجر معين (تستخدم في صفحة المحل)
  Future<void> fetchOffers(String sellerUid) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('offers')
          .where('sellerId', isEqualTo: sellerUid)
          .get();

      List<Map<String, dynamic>> loadedOffers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      loadedOffers.sort((a, b) {
        Timestamp? timeA = a['createdAt'] as Timestamp?;
        Timestamp? timeB = b['createdAt'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        return timeB.compareTo(timeA);
      });

      _offers = loadedOffers;
    } catch (e) {
      debugPrint("Error fetching offers: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  //  جلب كل العروض الفعالة (تستخدم في شاشة الـ Home - Top Catches)
  Future<void> fetchAllActiveOffers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // جلب العروض اللي حالتها Active فقط من كل المحلات
      QuerySnapshot snapshot = await _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> tempOffers = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // جلب اسم المحل بناءً على الـ sellerId المخزن في العرض
        String sellerId = data['sellerId'] ?? '';
        if (sellerId.isNotEmpty) {
          DocumentSnapshot sellerDoc =
              await _firestore.collection('sellers').doc(sellerId).get();

          if (sellerDoc.exists) {
            data['storeName'] =
                (sellerDoc.data() as Map<String, dynamic>)['name'] ?? "Store";
          }
        }
        tempOffers.add(data);
      }

      // ترتيب العروض محلياً (الأحدث أولاً)
      tempOffers.sort((a, b) {
        Timestamp? timeA = a['createdAt'] as Timestamp?;
        Timestamp? timeB = b['createdAt'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        return timeB.compareTo(timeA);
      });

      _offers = tempOffers;
    } catch (e) {
      debugPrint("Error fetching all active offers: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  //  إضافة عرض جديد
  Future<bool> addOffer(String sellerUid, String text) async {
    try {
      DocumentReference docRef = await _firestore.collection('offers').add({
        'sellerId': sellerUid,
        'text': text,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _offers.insert(0, {
        'id': docRef.id,
        'sellerId': sellerUid,
        'text': text,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding offer: $e");
      return false;
    }
  }

  //  تعديل نص العرض
  Future<bool> updateOffer(String offerId, String newText) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({
        'text': newText,
      });

      int index = _offers.indexWhere((o) => o['id'] == offerId);
      if (index != -1) {
        _offers[index]['text'] = newText;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating offer: $e");
      return false;
    }
  }

  //  تفعيل أو إيقاف العرض
  Future<bool> toggleOfferStatus(String offerId, bool currentStatus) async {
    try {
      await _firestore.collection('offers').doc(offerId).update({
        'isActive': !currentStatus,
      });

      int index = _offers.indexWhere((o) => o['id'] == offerId);
      if (index != -1) {
        _offers[index]['isActive'] = !currentStatus;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error toggling offer status: $e");
      return false;
    }
  }

  // حذف العرض نهائياً
  Future<bool> deleteOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).delete();
      _offers.removeWhere((o) => o['id'] == offerId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting offer: $e");
      return false;
    }
  }
}
