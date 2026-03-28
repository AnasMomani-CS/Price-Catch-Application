import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Offset> _logoAnimation;

  late AnimationController _appNameController;
  late Animation<Offset> _appNameAnimation;

  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    // اللوغو يتحرك من اليسار → وسط
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _logoAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoController.forward();

    // الاسم يتحرك من اليمين → جنب اللوغو
    _appNameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _appNameAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: const Offset(0, 0),
    ).animate(_appNameController);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _appNameController.forward();
    });

    // النص العربي يظهر تدريجيًا
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) _textController.forward();
    });

    // وقت كافي للمشاهدة ثم الانتقال  AuthWrapper
    // قللت الوقت لـ 5 ثواني عشان اليوزر ما يمل 
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  void _navigateAfterSplash() {
    // ننتقل للـ AuthWrapper الموجود في الـ main.dart وهو اللي بقرر وين يروح اليوزر
    Navigator.pushReplacementNamed(context, '/auth_wrapper');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _appNameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double logoWidth = screenWidth * 0.35;
    double appNameWidth = screenWidth * 0.45;

    return Scaffold(
      backgroundColor: Colors.grey.shade500,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _logoAnimation,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: logoWidth,
                  ),
                ),
                SlideTransition(
                  position: _appNameAnimation,
                  child: Image.asset(
                    'assets/images/app_name.png',
                    width: appNameWidth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _textController,
              child: Text(
                'إلتقط أفضل الأسعار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
