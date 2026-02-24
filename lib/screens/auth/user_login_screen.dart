import 'package:flutter/material.dart';
import 'dart:math' as math;
// استيراد ملفات المشروع الخاصة بك
import '../../core/auth_ui/widgets/user_login_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth_ui/background/center_widget.dart';

enum Screens { createAccount, welcomeBack }

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  // الـ Widget العلوي (المربع المائل)
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
            colors: [
              AppColors.userDeepDark, // البرتقالي الأغمق
              AppColors.userPrimary, // البرتقالي الأساسي
            ],
          ),
        ),
      ),
    );
  }

  // الـ Widget السفلي (الدائرة)
  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [AppColors.userPrimary, AppColors.userDeepDark],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // جعل الخلفية بيضاء مائلة للرمادي الفاتح ليعبر البرتقالي بوضوح
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // العناصر الديكورية في الخلفية
          Positioned(top: -160, left: -30, child: topWidget(screenSize.width)),
          Positioned(
            bottom: -180,
            left: -40,
            child: bottomWidget(screenSize.width),
          ),

          // 3. باقي المحتوى
          CenterWidget(
            size: screenSize,
            color1: AppColors.userLight,
            color2: AppColors.userLight,
          ),
          const SingleChildScrollView(child: UserLoginContent()),
        ],
      ),
    );
  }
}
