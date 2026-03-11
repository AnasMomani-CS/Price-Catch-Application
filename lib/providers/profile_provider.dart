import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? _userProfile;
  SellerProfile? _sellerProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  SellerProfile? get sellerProfile => _sellerProfile;

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  //  تخزين بيانات البروفايل 
  Future<void> fetchProfile(String uid, String role) async {
    _isLoading = true;
    _clearError();

    try {
      String collection = (role == 'user') ? 'users' : 'sellers';
      DocumentSnapshot doc = await _db.collection(collection).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        if (role == 'user') {
          _userProfile = UserProfile.fromMap(data);
        } else {
          _sellerProfile = SellerProfile.fromMap(data);
        }
      }
    } catch (e) {
      _errorMessage = "Failed to load profile: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  رفع صورة البروفايل
  Future<bool> uploadProfileImage({
    required String uid,
    required String role,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) return false;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      File file = File(pickedFile.path);
      String folder = (role == 'user') ? 'users' : 'sellers';

      // مرجع الصورة في التخزين
      Reference ref = _storage
          .ref()
          .child('profile_images')
          .child(folder)
          .child('$uid.jpg');

      // الرفع
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Timestamp
      String timestampUrl =
          "$downloadUrl&t=${DateTime.now().millisecondsSinceEpoch}";

      // التحديث في Firestore 
      return await updateSingleField(
        uid: uid,
        role: role,
        fieldKey: 'photoUrl',
        value: timestampUrl,
      );
    } catch (e) {
      _errorMessage = "Image upload failed: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  تحديث حقل ديناميكياً 
  Future<bool> updateSingleField({
    required String uid,
    required String role,
    required String fieldKey,
    required dynamic value,
  }) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      String collection = (role == 'user') ? 'users' : 'sellers';

      // استخدام set مع merge: true لضمان تحديث الحقل دون المساس ببقية البيانات
      await _db.collection(collection).doc(uid).set(
        {fieldKey: value},
        SetOptions(merge: true),
      );

      // تحديث الحالة المحلية (Local State) فوراً ليعكس التغيير في الواجهة
      if (role == 'user') {
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWithField(fieldKey, value);
        } else {
          await fetchProfile(uid, role);
        }
      } else if (role == 'seller') {
        if (_sellerProfile != null) {
          _sellerProfile = _sellerProfile!.copyWithField(fieldKey, value);
        } else {
          await fetchProfile(uid, role);
        }
      }

      return true;
    } catch (e) {
      _errorMessage = "Field update failed: $e";
      debugPrint("Firestore Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _userProfile = null;
    _sellerProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}

//  التوسعات (Extensions)
extension UserProfileExt on UserProfile {
  UserProfile copyWithField(String key, dynamic value) {
    Map<String, dynamic> map = this.toMap();
    map[key] = value;
    return UserProfile.fromMap(map);
  }
}

extension SellerProfileExt on SellerProfile {
  SellerProfile copyWithField(String key, dynamic value) {
    Map<String, dynamic> map = this.toMap();
    map[key] = value;
    return SellerProfile.fromMap(map);
  }
}
