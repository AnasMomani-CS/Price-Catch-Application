import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/cloudinary_service.dart';

class ProductsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  // القائمة الكاملة (تُستخدم للتاجر عشان يقدر يعدل ويفعل منتجاته)
  List<Map<String, dynamic>> get products => _products;

  //  الحل الذكي: قائمة مفلترة تلقائياً (تُستخدم للمشتري في صفحة المحل)
  List<Map<String, dynamic>> get activeProducts =>
      _products.where((p) => p['isActive'] == true).toList();

  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String placeholderImg =
      "https://cdn-icons-png.flaticon.com/512/3144/3144456.png";

  //  جلب المنتجات
  Future<void> fetchProducts(String sellerUid) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerUid)
          .get();

      List<Map<String, dynamic>> loadedProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      loadedProducts.sort((a, b) {
        Timestamp? timeA = a['createdAt'] as Timestamp?;
        Timestamp? timeB = b['createdAt'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        return timeB.compareTo(timeA);
      });

      _products = loadedProducts;
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  //  إضافة منتج
  Future<bool> addProduct({
    required String sellerUid,
    required String name,
    required String description,
    required double originalPrice,
    required double discountPercentage,
    required double price,
    dynamic imageFile,
  }) async {
    try {
      String finalImageUrl = placeholderImg;

      if (imageFile != null && imageFile is File) {
        String? uploadedUrl =
            await CloudinaryService.uploadImage(imageFile.path);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      final productData = {
        'sellerId': sellerUid,
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
        'price': price,
        'imageUrl': finalImageUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef =
          await _firestore.collection('products').add(productData);

      Map<String, dynamic> localProduct = Map.from(productData);
      localProduct['id'] = docRef.id;
      localProduct['createdAt'] = Timestamp.now();
      _products.insert(0, localProduct);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error adding product: $e");
      return false;
    }
  }

  // 3. تعديل المنتج
  Future<bool> updateProduct({
    required String productId,
    required String sellerUid,
    required String name,
    required String description,
    required double originalPrice,
    required double discountPercentage,
    required double price,
    String? currentImageUrl,
    dynamic newImageFile,
  }) async {
    try {
      String finalImageUrl = currentImageUrl ?? placeholderImg;

      if (newImageFile != null && newImageFile is File) {
        String? uploadedUrl =
            await CloudinaryService.uploadImage(newImageFile.path);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      final updateData = {
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
        'price': price,
        'imageUrl': finalImageUrl,
      };

      await _firestore.collection('products').doc(productId).update(updateData);

      int index = _products.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        _products[index].addAll(updateData);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating product: $e");
      return false;
    }
  }

  //  تفعيل أو إيقاف المنتج
  Future<bool> toggleProductStatus(String productId, bool currentStatus) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': !currentStatus,
      });

      int index = _products.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        _products[index]['isActive'] = !currentStatus;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error toggling status: $e");
      return false;
    }
  }

  //  حذف المنتج
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p['id'] == productId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting product: $e");
      return false;
    }
  }
}
