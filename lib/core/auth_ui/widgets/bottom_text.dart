import 'package:flutter/material.dart';
import '../../enums/auth_role.dart';
import '../../theme/app_colors.dart';
import '../animations/change_screen_animation_user.dart';
import '../animations/change_screen_animation_seller.dart';

class BottomText extends StatefulWidget {
  final AuthRole role;
  const BottomText({super.key, required this.role});

  @override
  State<BottomText> createState() => _BottomTextState();
}

class _BottomTextState extends State<BottomText> {
  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == AuthRole.user;

    // التحقق من الحالة لعرض النص الصحيح (Sign up / Log in)
    // بما أننا بدأنا بالـ Login، فالقيمة الافتراضية هنا ستكون true
    final bool isLogin = isUser
        ? ChangeScreenAnimationUser.currentScreen == UserAuthState.login
        : ChangeScreenAnimationSeller.currentScreen == SellerAuthState.login;

    final animation = isUser
        ? ChangeScreenAnimationUser.bottomTextAnimation
        : ChangeScreenAnimationSeller.bottomTextAnimation;

    return SlideTransition(
      position: animation,
      child: GestureDetector(
        onTap: () async {
          if (isUser) {
            if (ChangeScreenAnimationUser.isPlaying) return;

            // التعديل هنا: إذا كانت الشاشة الحالية هي Login (وهي البداية)
            // نضغط عشان نروح للـ Signup باستخدام forward()
            if (ChangeScreenAnimationUser.currentScreen ==
                UserAuthState.login) {
              await ChangeScreenAnimationUser.forward();
            } else {
              await ChangeScreenAnimationUser.reverse();
            }
          } else {
            if (ChangeScreenAnimationSeller.isPlaying) return;

            // التعديل هنا للسيلر أيضاً:
            // إذا كنا بالـ Login، ننتقل للـ Signup بـ forward()
            if (ChangeScreenAnimationSeller.currentScreen ==
                SellerAuthState.login) {
              await ChangeScreenAnimationSeller.forward();
            } else {
              await ChangeScreenAnimationSeller.reverse();
            }
          }
          if (mounted) setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
              children: [
                TextSpan(
                  text: isLogin
                      ? "Don't have an account? "
                      : "Already have an account? ",
                  style: const TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: isLogin ? 'Sign Up' : 'Log In',
                  style: TextStyle(
                    color: isUser ? AppColors.userLight : AppColors.sellerLight,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
