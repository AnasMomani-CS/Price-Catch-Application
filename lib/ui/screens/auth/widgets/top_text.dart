import 'package:flutter/material.dart';
import '../../../../core/enums/auth_role.dart'; // لتمييز بائع أو مستخدم
import '../../../../core/theme/app_colors.dart';
import '../animations/change_screen_animation_user.dart';
import '../animations/change_screen_animation_seller.dart';

class TopText extends StatelessWidget {
  final AuthRole role;
  const TopText({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isUser = role == AuthRole.user;
    final controller = isUser
        ? ChangeScreenAnimationUser.topTextController
        : ChangeScreenAnimationSeller.topTextController;
    final animation = isUser
        ? ChangeScreenAnimationUser.topTextAnimation
        : ChangeScreenAnimationSeller.topTextAnimation;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // التحقق من حالة اللوجن بناءً على Enum الخاص بكل طرف
        final bool isLogin = isUser
            ? ChangeScreenAnimationUser.currentScreen == UserAuthState.login
            : ChangeScreenAnimationSeller.currentScreen ==
                  SellerAuthState.login;

        final title = isUser
            ? (isLogin ? "Welcome\nBack" : "Create\nAccount")
            : (isLogin ? "Welcome\nBack" : "Register\nStore");

        final subtitle = isUser
            ? (isLogin ? "Login to continue" : "Sign up to get started")
            : (isLogin ? "Seller Portal Login" : "Create your store account");

        return SlideTransition(
          position: animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isUser
                      ? AppColors.sellerPrimary
                      : AppColors.sellerDeepDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
