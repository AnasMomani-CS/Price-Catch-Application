import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double originalPrice; 
  final double discountPercentage; 
  final double price; 
  final bool isActive;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.originalPrice,
    this.discountPercentage = 0.0,
    required this.price,
    this.isActive = true,
    this.createdAt,
  });

  // Firebase إلى Object
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      sellerId: map['sellerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'General',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'price': price, 
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // (Logic Helper)
  static double calculateDiscountedPrice(double original, double discount) {
    if (discount <= 0) return original;
    return original - (original * (discount / 100));
  }
}
