import 'package:flutter/material.dart';
import '../../../../core/enums/auth_role.dart'; // تأكد أن ملف الـ Enum يحتوي على UserAuthState

class ChangeScreenAnimationUser {
  static late AnimationController controller;
  static late AnimationController topTextController;
  static late Animation<Offset> topTextAnimation;
  static late AnimationController bottomTextController;
  static late Animation<Offset> bottomTextAnimation;

  static final List<AnimationController> createAccountControllers = [];
  static final List<Animation<Offset>> createAccountAnimations = [];
  static final List<AnimationController> loginControllers = [];
  static final List<Animation<Offset>> loginAnimations = [];

  static var isPlaying = false;
  // 1. البداية الآن هي الـ Login لليوزر
  static var currentScreen = UserAuthState.login;
  static bool _initialized = false;

  static void initialize({
    required TickerProvider vsync,
    required int createAccountItems,
    required int loginItems,
  }) {
    if (_initialized) dispose();

    // نصوص العنوان تبدأ من مكانها وتخرج لليسار عند التبديل
    topTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    topTextAnimation =
        Tween(begin: Offset.zero, end: const Offset(-1.2, 0)).animate(
      CurvedAnimation(parent: topTextController, curve: Curves.easeInOut),
    );

    bottomTextController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    bottomTextAnimation =
        Tween(begin: Offset.zero, end: const Offset(0, 1.7)).animate(
      CurvedAnimation(
        parent: bottomTextController,
        curve: Curves.easeInOut,
      ),
    );

    // 2. خانات الـ Sign up لليوزر تبدأ من خارج الشاشة (جهة اليسار)
    createAccountControllers.clear();
    createAccountAnimations.clear();
    for (var i = 0; i < createAccountItems; i++) {
      final c = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );
      createAccountControllers.add(c);
      createAccountAnimations.add(
        Tween(
          begin: const Offset(-1.2, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
      );
    }

    // 3. خانات الـ Login لليوزر تبدأ من مكانها الطبيعي وتخرج لليمين عند التبديل
    loginControllers.clear();
    loginAnimations.clear();
    for (var i = 0; i < loginItems; i++) {
      final c = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );
      loginControllers.add(c);
      loginAnimations.add(
        Tween(
          begin: Offset.zero,
          end: const Offset(1.2, 0),
        ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
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

  // التبديل من Login إلى Sign up
  static Future<void> forward() async {
    if (isPlaying) return;
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    currentScreen = UserAuthState.signup;

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

  // العودة من Sign up إلى Login
  static Future<void> reverse() async {
    if (isPlaying) return;
    isPlaying = true;

    topTextController.forward();
    await bottomTextController.forward();

    currentScreen = UserAuthState.login;

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
