import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../seller/seller_profile_screen.dart';
import '../reset_password_screen.dart';
import '../user_seller_choice.dart';
import '../../../../core/enums/auth_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../animations/change_screen_animation_seller.dart';
import '../../../../providers/auth_provider.dart';
import 'top_text.dart';
import 'bottom_text.dart';

class SellerLoginContent extends StatefulWidget {
  const SellerLoginContent({super.key});
  @override
  State<SellerLoginContent> createState() => _SellerLoginContentState();
}

class _SellerLoginContentState extends State<SellerLoginContent>
    with TickerProviderStateMixin {
  bool isObscureLogin = true;
  bool isObscureSignUp = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailLogin = TextEditingController();
  final _passLogin = TextEditingController();
  final _storeNameSign = TextEditingController();
  final _emailSign = TextEditingController();
  final _passSign = TextEditingController();
  final _confirmPassSign = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChangeScreenAnimationSeller.initialize(
      vsync: this,
      createAccountItems: 5,
      loginItems: 4,
    );
  }

  @override
  void dispose() {
    _emailLogin.dispose();
    _passLogin.dispose();
    _storeNameSign.dispose();
    _emailSign.dispose();
    _passSign.dispose();
    _confirmPassSign.dispose();
    super.dispose();
  }

  Widget inputField(String hint, IconData icon, Animation<Offset> anim,
      {bool isPass = false,
      TextEditingController? controller,
      String? Function(String?)? validator,
      Widget? suffixIcon}) {
    return SlideTransition(
      position: anim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          child: TextFormField(
            controller: controller,
            obscureText: isPass,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.sellerPrimary),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              errorStyle: const TextStyle(height: 0, fontSize: 12),
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

  Widget actionButton(String title, Animation<Offset> anim,
      VoidCallback onPressed, bool isLoading) {
    return SlideTransition(
      position: anim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: AppColors.sellerPrimary,
            shape: const StadiumBorder(),
            elevation: 8,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(
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
    final authProvider = Provider.of<AuthProvider>(context);
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
                      builder: (context) => const UserSellerChoiceScreen()),
                  (route) => false,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 25),
              ),
            ),
          ),

          Positioned(top: 120, left: 30, child: TopText(role: AuthRole.seller)),

          Padding(
            padding: const EdgeInsets.only(top: 240),
            child: Stack(
              children: [
                //  LOGIN SECTION
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      inputField(
                        'Store Email',
                        Icons.store_mall_directory_outlined,
                        ChangeScreenAnimationSeller.loginAnimations[0],
                        controller: _emailLogin,
                        validator: (val) => (val == null || !val.contains("@"))
                            ? "Invalid Email"
                            : null,
                      ),
                      inputField(
                        'Password',
                        Icons.lock_outline,
                        ChangeScreenAnimationSeller.loginAnimations[1],
                        isPass: isObscureLogin,
                        controller: _passLogin,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => isObscureLogin = !isObscureLogin),
                          icon: Icon(isObscureLogin
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) => (val == null || val.isEmpty)
                            ? "Enter password"
                            : null,
                      ),
                      SlideTransition(
                        position:
                            ChangeScreenAnimationSeller.loginAnimations[2],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ResetPasswordScreen()));
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      actionButton(
                        'LOG IN',
                        ChangeScreenAnimationSeller.loginAnimations[3],
                        () async {
                          if (_loginFormKey.currentState!.validate()) {
                            bool success =
                                await authProvider.loginWithEmailAndPassword(
                                    _emailLogin.text, _passLogin.text);

                            if (success && context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SellerProfileScreen()),
                                (route) => false,
                              );
                            } else if (authProvider.errorMessage != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(authProvider.errorMessage!),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        authProvider.isLoading,
                      ),
                    ],
                  ),
                ),

                // SIGN UP SECTION
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      inputField(
                        'Store Name',
                        Icons.store_outlined,
                        ChangeScreenAnimationSeller.createAccountAnimations[0],
                        controller: _storeNameSign,
                        validator: (val) => (val == null || val.isEmpty)
                            ? "Enter store name"
                            : null,
                      ),
                      inputField(
                        'Business Email',
                        Icons.mail_outline,
                        ChangeScreenAnimationSeller.createAccountAnimations[1],
                        controller: _emailSign,
                        validator: (val) => (val == null || !val.contains("@"))
                            ? "Invalid Email"
                            : null,
                      ),
                      inputField(
                        'Password',
                        Icons.lock_outline,
                        ChangeScreenAnimationSeller.createAccountAnimations[2],
                        isPass: isObscureSignUp,
                        controller: _passSign,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => isObscureSignUp = !isObscureSignUp),
                          icon: Icon(isObscureSignUp
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) => (val == null || val.length < 6)
                            ? "Min 6 characters"
                            : null,
                      ),
                      inputField(
                        'Confirm Password',
                        Icons.lock_reset_rounded,
                        ChangeScreenAnimationSeller.createAccountAnimations[3],
                        isPass: isObscureSignUp,
                        controller: _confirmPassSign,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => isObscureSignUp = !isObscureSignUp),
                          icon: Icon(isObscureSignUp
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) =>
                            (val != _passSign.text) ? "Not matching" : null,
                      ),
                      actionButton(
                        'REGISTER STORE',
                        ChangeScreenAnimationSeller.createAccountAnimations[4],
                        () async {
                          if (_signUpFormKey.currentState!.validate()) {
                            bool success = await authProvider.register(
                              name: _storeNameSign.text,
                              email: _emailSign.text,
                              password: _passSign.text,
                              role: AuthRole.seller,
                            );
                            if (success) {
                              // نقل الإيميل لشاشة تسجيل الدخول تلقائياً
                              _emailLogin.text = _emailSign.text;
                              await ChangeScreenAnimationSeller.reverse();
                            }
                          }
                        },
                        authProvider.isLoading,
                      ),
                    ],
                  ),
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
