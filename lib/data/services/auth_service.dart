import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/auth_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  // تسجيل الدخول بجوجل 
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken ?? '',
        idToken: googleAuth.idToken ?? '',
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'No Name',
          'email': user.email,
          'role': AuthRole.user.name,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print("Google Auth Error: $e");
      return null;
    }
  }

  //  تسجيل مستخدم جديد (بائع أو مستخدم) بالإيميل
  Future<void> register({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
    required AuthRole role,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    profileData['uid'] = cred.user!.uid;
    profileData['createdAt'] = FieldValue.serverTimestamp();

    String collectionName = role == AuthRole.seller ? 'sellers' : 'users';

    await _db.collection(collectionName).doc(cred.user!.uid).set(profileData);
  }

  //  تسجيل الدخول برقم الهاتف (إرسال الكود) 
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  //  تأكيد كود  OTP اللي وصل برسالة 
  Future<UserCredential?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // إذا المستخدم جديد، بنسجله كمستخدم (User) تلقائياً في Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'phone': userCredential.user!.phoneNumber,
          'role': AuthRole.user.name,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      return userCredential;
    } catch (e) {
      print("Phone Auth Error: $e");
      return null;
    }
  }

  //  تسجيل الخروج 
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}