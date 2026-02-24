import 'package:flutter/material.dart';
import '../../enums/auth_role.dart'; 

class ChangeScreenAnimationSeller {
  static late AnimationController topTextController;
  static late Animation<Offset> topTextAnimation;
  static late AnimationController bottomTextController;
  static late Animation<Offset> bottomTextAnimation;

  static final List<AnimationController> createAccountControllers = [];
  static final List<Animation<Offset>> createAccountAnimations = [];
  static final List<AnimationController> loginControllers = [];
  static final List<Animation<Offset>> loginAnimations = [];

  static var isPlaying = false;
  // التغيير السحري هنا: تعريف حالة حقيقية بدلاً من => null
  static var currentScreen = SellerAuthState.login; 
  static bool _initialized = false;

  static void initialize({
    required TickerProvider vsync,
    required int createAccountItems,
    required int loginItems,
  }) {
    if (_initialized) dispose();

    topTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    topTextAnimation = Tween(begin: Offset.zero, end: const Offset(-1.2, 0))
        .animate(CurvedAnimation(parent: topTextController, curve: Curves.easeInOut));

    bottomTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    bottomTextAnimation = Tween(begin: Offset.zero, end: const Offset(0, 1.7))
        .animate(CurvedAnimation(parent: bottomTextController, curve: Curves.easeInOut));

    createAccountControllers.clear();
    createAccountAnimations.clear();
    for (var i = 0; i < createAccountItems; i++) {
      final c = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );
      createAccountControllers.add(c);
      createAccountAnimations.add(
        Tween(begin: const Offset(-1.2, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
      );
    }

    loginControllers.clear();
    loginAnimations.clear();
    for (var i = 0; i < loginItems; i++) {
      final c = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );
      loginControllers.add(c);
      loginAnimations.add(
        Tween(begin: Offset.zero, end: const Offset(1.2, 0))
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
      );
    }
    _initialized = true;
  }

  static void dispose() {
    if (!_initialized) return;
    topTextController.dispose();
    bottomTextController.dispose();
    for (var c in createAccountControllers) {
      c.dispose();
    }
    for (var c in loginControllers) {
      c.dispose();
    }
    _initialized = false;
  }

  static Future<void> forward() async {
    if (isPlaying) return;
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    // تحديث الحالة لـ signup أثناء اختفاء العناوين
    currentScreen = SellerAuthState.signup; 

    for (var i = 0; i < loginControllers.length; i++) {
      loginControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 50));
    }
    for (var i = 0; i < createAccountControllers.length; i++) {
      createAccountControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    bottomTextController.reverse();
    await topTextController.reverse();
    isPlaying = false;
  }

  static Future<void> reverse() async {
    if (isPlaying) return;
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    // إرجاع الحالة لـ login
    currentScreen = SellerAuthState.login; 

    for (var i = createAccountControllers.length - 1; i >= 0; i--) {
      createAccountControllers[i].reverse();
      await Future.delayed(const Duration(milliseconds: 50));
    }
    for (var i = loginControllers.length - 1; i >= 0; i--) {
      loginControllers[i].reverse();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    bottomTextController.reverse();
    await topTextController.reverse();
    isPlaying = false;
  }
}