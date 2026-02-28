import 'package:flutter/material.dart';
import '../reset_password_screen.dart';
import '../user_seller_choice.dart';
import '../../../../core/enums/auth_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../animations/change_screen_animation_seller.dart';
import 'top_text.dart';
import 'bottom_text.dart';

class SellerLoginContent extends StatefulWidget {
  const SellerLoginContent({super.key});
  @override
  State<SellerLoginContent> createState() => _SellerLoginContentState();
}

class _SellerLoginContentState extends State<SellerLoginContent>
    with TickerProviderStateMixin {
  // شلنا متغير isLoginView لأنه ما إله داعي

  @override
  void initState() {
    super.initState();
    ChangeScreenAnimationSeller.initialize(
      vsync: this,
      createAccountItems: 4,
      loginItems: 4,
    );
  }

  @override
  void dispose() {
    ChangeScreenAnimationSeller.dispose();
    super.dispose();
  }

  Widget inputField(
    String hint,
    IconData icon,
    Animation<Offset> anim, {
    bool pass = false,
  }) {
    return SlideTransition(
      position: anim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          child: TextFormField(
            obscureText: pass,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.sellerPrimary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget actionButton(
    String title,
    Animation<Offset> anim,
    VoidCallback onPressed,
  ) {
    return SlideTransition(
      position: anim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: AppColors.sellerPrimary,
            shape: const StadiumBorder(),
            elevation: 8,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: Stack(
        children: [
          // سهم الرجوع
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                ChangeScreenAnimationSeller.dispose();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserSellerChoiceScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),

          Positioned(top: 130, left: 30, child: TopText(role: AuthRole.seller)),

          Padding(
            padding: const EdgeInsets.only(top: 260),
            child: Stack(
              children: [
                // طبقة تسجيل الدخول (بدون Opacity)
                Column(
                  children: [
                    inputField(
                      'Store Email',
                      Icons.store_mall_directory_outlined,
                      ChangeScreenAnimationSeller.loginAnimations[0],
                    ),
                    inputField(
                      'Password',
                      Icons.lock_outline,
                      ChangeScreenAnimationSeller.loginAnimations[1],
                      pass: true,
                    ),
                    SlideTransition(
                      position: ChangeScreenAnimationSeller
                          .loginAnimations[2], // تأكد من الـ Index حسب ترتيبك
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                        ), // السر الأول: نفس مسافة الخانات
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ResetPasswordScreen(),
                                ),
                              );
                            },
                            // السر الثاني: إزالة الفراغ الداخلي للزر لتكون المحاذاة 100% دقيقة
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    actionButton(
                      'LOG IN',
                      ChangeScreenAnimationSeller.loginAnimations[3],
                      () {},
                    ),
                  ],
                ),
                // طبقة إنشاء الحساب (بدون Opacity)
                Column(
                  children: [
                    inputField(
                      'Store Name',
                      Icons.store_outlined,
                      ChangeScreenAnimationSeller.createAccountAnimations[0],
                    ),
                    inputField(
                      'Business Email',
                      Icons.mail_outline,
                      ChangeScreenAnimationSeller.createAccountAnimations[1],
                    ),
                    inputField(
                      'Password',
                      Icons.lock_outline,
                      ChangeScreenAnimationSeller.createAccountAnimations[2],
                      pass: true,
                    ),
                    actionButton(
                      'REGISTER STORE',
                      ChangeScreenAnimationSeller.createAccountAnimations[3],
                      () async {
                        // أضفت لك كود الرجوع هنا للزر إذا حبيت تشغله زي اليوزر
                        if (ChangeScreenAnimationSeller.isPlaying) return;
                        await ChangeScreenAnimationSeller.reverse();
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(child: BottomText(role: AuthRole.seller)),
          ),
        ],
      ),
    );
  }
}
