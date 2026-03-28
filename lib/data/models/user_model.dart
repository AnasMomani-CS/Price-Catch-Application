// Profile User Only
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
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
