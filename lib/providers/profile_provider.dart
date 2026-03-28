import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/seller_model.dart';
import '../data/services/cloudinary_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // جلب بيانات البروفايل
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
          _sellerProfile = SellerProfile.fromMap(data, uid);
        }
      }
    } catch (e) {
      _errorMessage = "Failed to load profile: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // رفع صورة البروفايل
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
      String? imageUrl = await CloudinaryService.uploadImage(pickedFile.path);

      if (imageUrl == null) {
        _errorMessage = "Failed to upload image to Cloudinary.";
        return false;
      }

      return await updateSingleField(
        uid: uid,
        role: role,
        fieldKey: 'photoUrl',
        value: imageUrl,
      );
    } catch (e) {
      _errorMessage = "Image upload failed: $e";
      debugPrint("Upload Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث حقل ديناميكياً
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

      await _db.collection(collection).doc(uid).set(
        {fieldKey: value},
        SetOptions(merge: true),
      );

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

  // زيادة عداد مشاهدات المتجر
  Future<void> incrementStoreViews(String sellerUid) async {
    try {
      await _db.collection('sellers').doc(sellerUid).update({
        'viewsCount': FieldValue.increment(1),
      });
      if (_sellerProfile != null && _sellerProfile!.uid == sellerUid) {
        _sellerProfile = _sellerProfile!.copyWith(
          viewsCount: _sellerProfile!.viewsCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error incrementing store views: $e");
    }
  }

  // زيادة عداد زيارات المتجر
  Future<void> incrementStoreVisits(String sellerUid) async {
    try {
      await _db.collection('sellers').doc(sellerUid).update({
        'storeVisits': FieldValue.increment(1),
      });

      if (_sellerProfile != null && _sellerProfile!.uid == sellerUid) {
        _sellerProfile = _sellerProfile!.copyWith(
          storeVisits: _sellerProfile!.storeVisits + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error incrementing store visits: $e");
    }
  }

  void clearProfile() {
    _userProfile = null;
    _sellerProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}

// التوسعات (Extensions)
extension UserProfileExt on UserProfile {
  UserProfile copyWithField(String key, dynamic value) {
    Map<String, dynamic> map = toMap();
    map[key] = value;
    return UserProfile.fromMap(map);
  }
}

extension SellerProfileExt on SellerProfile {
  SellerProfile copyWithField(String key, dynamic value) {
    Map<String, dynamic> map = toMap();
    map[key] = value;
    return SellerProfile.fromMap(map, uid);
  }
}
