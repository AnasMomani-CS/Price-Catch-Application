// Profile User
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String? phoneNumber;
  final String? gender;
  final String? birthDate;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.photoUrl,
    this.phoneNumber,
    this.gender,
    this.birthDate,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'birthDate': birthDate,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'] ?? (map['phone'] ?? ''),
      gender: map['gender'],
      birthDate: map['birthDate'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? gender,
    String? birthDate,
  }) {
    return UserProfile(
      uid: this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

// Profile Seller
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
      };

  factory SellerProfile.fromMap(Map<String, dynamic> map) {
    return SellerProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? (map['storeName'] ?? ''), // دعم للبيانات القديمة
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? (map['phone'] ?? ''),
      role: map['role'] ?? 'seller',
      address: map['address'] ?? map['storeAddress'],
      category: map['category'] ?? map['storeCategory'],
      description: map['description'],
      photoUrl: map['photoUrl'],
    );
  }

  SellerProfile copyWith({
    String? name,
    String? phoneNumber,
    String? address,
    String? category,
    String? description,
    String? photoUrl,
  }) {
    return SellerProfile(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: this.role,
      address: address ?? this.address,
      category: category ?? this.category,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}