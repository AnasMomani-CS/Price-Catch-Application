import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:price_catch_project/ui/screens/auth/user_seller_choice.dart';
import 'package:price_catch_project/ui/screens/user/home_screen.dart';
import 'package:price_catch_project/ui/screens/seller/seller_home_screen.dart';

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
    _logoAnimation =
        Tween<Offset>(
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
      _appNameController.forward();
    });

    // النص العربي يظهر تدريجيًا
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(const Duration(milliseconds: 2300), () {
      _textController.forward();
    });

    // وقت كافي للمشاهدة ثم الانتقال
    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      _navigateAfterSplash();
    });
  }

  Future<void> _navigateAfterSplash() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserSellerChoiceScreen()),
      );
    } else {
      try {
        final docUser = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final docSeller = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(user.uid)
            .get();
        if (docUser.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
        } else if (docSeller.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SellerHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserSellerChoiceScreen()),
          );
        }
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserSellerChoiceScreen()),
        );
      }
    }
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

    // الأحجام المناسبة للشاشة
    double logoWidth = screenWidth * 0.35;
    double appNameWidth = screenWidth * 0.45;

    return Scaffold(
      backgroundColor: Colors.grey.shade500,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row تحتوي اللوغو والاسم جنب بعض
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

            // النص العربي يظهر تدريجيًا
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
