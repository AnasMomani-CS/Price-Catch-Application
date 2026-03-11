import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'widgets/seller_login_content.dart';
import '../../../core/theme/app_colors.dart';
import 'background/center_widget.dart';

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({super.key});

  @override
  State<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<SellerLoginScreen> {
  // Widget العلوي 
  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [AppColors.sellerDeepDark, AppColors.sellerPrimary],
          ),
        ),
      ),
    );
  }

  // Widget السفلي
  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [AppColors.sellerPrimary, AppColors.sellerDeepDark],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // الخلفية الديكورية (الدوائر)
          Positioned(top: -160, left: -30, child: topWidget(screenSize.width)),
          Positioned(
            bottom: -180,
            left: -40,
            child: bottomWidget(screenSize.width),
          ),

          // CenterWidget الخلفي
          CenterWidget(
            size: screenSize,
            color1: AppColors.sellerLight,
            color2: AppColors.sellerLight,
          ),

          // المحتوى الأساسي مع حل مشكلة  RenderBox
          SingleChildScrollView(
            child: SizedBox(
              height: screenSize.height, 
              child: const SellerLoginContent(),
            ),
          ),
        ],
      ),
    );
  }
}
