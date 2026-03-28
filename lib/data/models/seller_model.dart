// lib/data/models/seller_model.dart

class SellerProfile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? address;
  final String? category;
  final String? description;
  final String? photoUrl;
  final String storeStatus;
  final int viewsCount;
  final int
      storeVisits; 
  final double growthRate; 

  SellerProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.role = 'seller',
    this.address,
    this.category,
    this.description,
    this.photoUrl,
    this.storeStatus = 'Closed',
    this.viewsCount = 0,
    this.storeVisits = 0,
    this.growthRate = 0.0, 
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role,
        'address': address,
        'category': category,
        'description': description,
        'photoUrl': photoUrl,
        'storeStatus': storeStatus,
        'viewsCount': viewsCount,
        'storeVisits': storeVisits, 
        'growthRate': growthRate, 
      };

  factory SellerProfile.fromMap(Map<String, dynamic> map, String id) {
    return SellerProfile(
      uid: id,
      name: map['name'] ?? (map['storeName'] ?? ''),
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? (map['phone'] ?? ''),
      role: map['role'] ?? 'seller',
      address: map['address'] ?? map['storeAddress'],
      category: map['category'] ?? map['storeCategory'],
      description: map['description'],
      photoUrl: map['photoUrl'],
      storeStatus: map['storeStatus'] ?? 'Closed',
      viewsCount: map['viewsCount'] ?? 0,
      //  قراءة الزيارات (دعم التسمية القديمة والجديدة لضمان عدم ضياع الداتا)
      storeVisits: map['storeVisits'] ?? (map['visitsCount'] ?? 0),
      //  قراءة نسبة النمو وتحويلها لـ double بأمان
      growthRate: (map['growthRate'] ?? 0.0).toDouble(),
    );
  }

  SellerProfile copyWith({
    String? name,
    String? phoneNumber,
    String? address,
    String? category,
    String? description,
    String? photoUrl,
    String? storeStatus,
    int? viewsCount,
    int? storeVisits,
    double? growthRate,
  }) {
    return SellerProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      address: address ?? this.address,
      category: category ?? this.category,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      storeStatus: storeStatus ?? this.storeStatus,
      viewsCount: viewsCount ?? this.viewsCount,
      storeVisits: storeVisits ?? this.storeVisits,
      growthRate: growthRate ?? this.growthRate,
    );
  }
}
