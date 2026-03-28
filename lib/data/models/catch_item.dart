// lib/data/models/catch_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CatchItem {
  final String id; // الـ ID تبع ملف المراقبة في الفايربيس
  final String productId; // الـ ID تبع المنتج الأصلي
  final String name;
  final String imageUrl;
  final String sellerName;
  final double currentPrice;
  final double targetPrice; // 🟢 السعر اللي المشتري بيحلم يوصله
  final bool isAlertActive; // 🟢 حالة التنبيه (شغال/طافي)

  CatchItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.sellerName,
    required this.currentPrice,
    required this.targetPrice,
    this.isAlertActive = true, 
  });

  factory CatchItem.fromMap(Map<String, dynamic> data, String documentId) {
    return CatchItem(
      id: documentId,
      productId: data['productId'] ?? '',
      name: data['name'] ?? 'Product',
      imageUrl: data['imageUrl'] ?? '',
      sellerName: data['sellerName'] ?? 'Store',
      currentPrice:
          double.tryParse(data['currentPrice']?.toString() ?? '0.0') ?? 0.0,
      targetPrice:
          double.tryParse(data['targetPrice']?.toString() ?? '0.0') ?? 0.0,
      isAlertActive: data['isAlertActive'] ?? true,
    );
  }

  // تجهيز البيانات عشان نرفعها للفايربيس
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'sellerName': sellerName,
      'currentPrice': currentPrice,
      'targetPrice': targetPrice,
      'isAlertActive': isAlertActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
