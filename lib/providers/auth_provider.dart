import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:price_catch_project/core/enums/auth_role.dart' show AuthRole;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  AuthRole? _role;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AuthRole? get role => _role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _initializeUser();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      var userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) return 'user';

      var sellerDoc = await _db.collection('sellers').doc(uid).get();
      if (sellerDoc.exists) return 'seller';
    } catch (e) {
      debugPrint("Error in getUserRole: $e");
    }
    return null;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required AuthRole role,
    String? category,
  }) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      if (credential.user != null) {
        String uid = credential.user!.uid;

        Map<String, dynamic> userData = {
          'uid': uid,
          'name': name,
          'email': email.trim(),
          'role': role.name,
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (role == AuthRole.seller) {
          userData['category'] = category ?? '';
          userData['phoneNumber'] = '';
          userData['address'] = '';
          userData['description'] = '';
        }

        String collectionPath = (role == AuthRole.user) ? 'users' : 'sellers';
        await _db.collection(collectionPath).doc(uid).set(userData);

        await _auth.signOut();
        _user = null;
        _role = null;
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      _user = credential.user;
      if (_user != null) await _fetchUserRole(_user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle({AuthRole preferredRole = AuthRole.user}) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        //  التأكد من الرتبة أولاً قبل اتخاذ أي قرار
        await _fetchUserRole(_user!.uid);

        // لا يتم إنشاء بيانات جديدة إلا إذا كان المستخدم غير موجود فعلياً
        if (_role == null) {
          String collection =
              (preferredRole == AuthRole.user) ? 'users' : 'sellers';

          Map<String, dynamic> data = {
            'uid': _user!.uid,
            'name': _user!.displayName ?? 'New User',
            'email': _user!.email ?? '',
            'role': preferredRole.name,
            'photoUrl': _user!.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          };

          if (preferredRole == AuthRole.seller) {
            data['category'] = '';
            data['phoneNumber'] = _user!.phoneNumber ?? '';
            data['address'] = '';
            data['description'] = '';
          }

          // استخدام merge: true لضمان الأمان التام
          await _db
              .collection(collection)
              .doc(_user!.uid)
              .set(data, SetOptions(merge: true));
          _role = preferredRole;
        }
      }
      return true;
    } catch (e) {
      _errorMessage = "Google Sign-In failed.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      var userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _role = AuthRole.user;
      } else {
        var sellerDoc = await _db.collection('sellers').doc(uid).get();
        if (sellerDoc.exists) {
          _role = AuthRole.seller;
        } else {
          _role = null; // للتأكد من حالة المستخدم الجديد
        }
      }
    } catch (e) {
      debugPrint("Role Fetch Error: $e");
    }
    notifyListeners();
  }

  Future<void> _initializeUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _fetchUserRole(_user!.uid);
    }
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    _clearError();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _errorMessage = _handleAuthError(e);
          onError(_errorMessage!);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError("Phone verification failed.");
    }
  }

  Future<bool> verifyOTP(String verificationId, String smsCode,
      {AuthRole preferredRole = AuthRole.user}) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        await _fetchUserRole(_user!.uid);

        if (_role == null) {
          String collection =
              (preferredRole == AuthRole.user) ? 'users' : 'sellers';

          Map<String, dynamic> data = {
            'uid': _user!.uid,
            'name': '',
            'email': '',
            'phoneNumber': _user!.phoneNumber,
            'role': preferredRole.name,
            'photoUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          };

          if (preferredRole == AuthRole.seller) {
            data['category'] = '';
            data['address'] = '';
            data['description'] = '';
          }

          // استخدام merge: true لضمان عدم حذف البيانات
          await _db
              .collection(collection)
              .doc(_user!.uid)
              .set(data, SetOptions(merge: true));
          _role = preferredRole;
        }
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _user = null;
    _role = null;
    notifyListeners();
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'network-request-failed':
          return 'Network error, check connection.';
        case 'invalid-verification-code':
          return 'Incorrect OTP.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
