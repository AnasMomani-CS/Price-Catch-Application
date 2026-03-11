import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../user/user_profile_screen.dart';
import '../reset_password_screen.dart';
import '../user_seller_choice.dart';
import '../../../../core/enums/auth_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../animations/change_screen_animation_user.dart';
import '../../../../providers/auth_provider.dart';
import 'top_text.dart';
import 'bottom_text.dart';

class UserLoginContent extends StatefulWidget {
  const UserLoginContent({super.key});

  @override
  State<UserLoginContent> createState() => _UserLoginContentState();
}

class _UserLoginContentState extends State<UserLoginContent>
    with TickerProviderStateMixin {
  bool isObscureLogin = true;
  bool isObscureSignUp = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailLogin = TextEditingController();
  final _passLogin = TextEditingController();
  final _nameSign = TextEditingController();
  final _emailSign = TextEditingController();
  final _passSign = TextEditingController();
  final _confirmPassSign = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChangeScreenAnimationUser.initialize(
      vsync: this,
      createAccountItems: 7,
      loginItems: 4,
    );
  }

  @override
  void dispose() {
    _emailLogin.dispose();
    _passLogin.dispose();
    _nameSign.dispose();
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
              prefixIcon: Icon(icon, color: AppColors.userPrimary),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              errorStyle: const TextStyle(height: 0, fontSize: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
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
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: AppColors.userPrimary,
            shape: const StadiumBorder(),
            elevation: 8,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }

  Widget _socialIconWidget(
      {String? imagePath, IconData? icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
          ],
        ),
        child: imagePath != null
            ? Image.asset(imagePath, height: 25, width: 25)
            : Icon(icon, color: Colors.black87, size: 25),
      ),
    );
  }

  void _showPhoneNumberDialog(BuildContext context, AuthProvider authProvider) {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sign in with Phone"),
        content: TextField(
          controller: phoneController,
          maxLength: 9,
          decoration: InputDecoration(
            hintText: "7XXXXXXXX",
            counterText: "",
            prefixIcon: const Icon(Icons.phone_android),
            prefixText: "+962 ",
            prefixStyle: TextStyle(
                color: AppColors.userPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.userPrimary,
                shape: const StadiumBorder()),
            onPressed: () {
              final fullPhone = "+962${phoneController.text.trim()}";
              if (phoneController.text.length < 9) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter 9 digits")));
                return;
              }
              authProvider.loginWithPhone(fullPhone, (verificationId) {
                Navigator.pop(context);
                _showOTPSheet(context, authProvider, verificationId);
              }, (error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              });
            },
            child:
                const Text("Send Code", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOTPSheet(
      BuildContext context, AuthProvider authProvider, String verificationId) {
    final otpController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter 6-digit Code",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 15, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "000000",
                counterText: "",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: AppColors.userPrimary, width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            actionButton(
                "Verify & Login", const AlwaysStoppedAnimation(Offset.zero),
                () async {
              bool success = await authProvider.verifyOTP(
                  verificationId, otpController.text);
              if (success && context.mounted) {
                Navigator.pop(context); // إغلاق الـ BottomSheet
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserProfileScreen()),
                    (route) => false);
              }
            }, authProvider.isLoading),
            const SizedBox(height: 20),
          ],
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
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                ChangeScreenAnimationUser.dispose();
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
          Positioned(top: 120, left: 30, child: TopText(role: AuthRole.user)),
          Padding(
            padding: const EdgeInsets.only(top: 240),
            child: Stack(
              children: [
                // --- LOGIN SECTION ---
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      inputField(
                        'Email',
                        Icons.mail_outline,
                        ChangeScreenAnimationUser.loginAnimations[0],
                        controller: _emailLogin,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter email";
                          if (!val.contains("@")) return "Invalid email";
                          return null;
                        },
                      ),
                      inputField(
                        'Password',
                        Icons.lock_outline,
                        ChangeScreenAnimationUser.loginAnimations[1],
                        isPass: isObscureLogin,
                        controller: _passLogin,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => isObscureLogin = !isObscureLogin),
                          icon: Icon(isObscureLogin
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter pass";
                          return null;
                        },
                      ),
                      SlideTransition(
                        position: ChangeScreenAnimationUser.loginAnimations[2],
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
                                            ResetPasswordScreen()));
                              },
                              child: const Text("Forgot Password?",
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      actionButton('Log In',
                          ChangeScreenAnimationUser.loginAnimations[3],
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
                                        const UserProfileScreen()),
                                (route) => false);
                          }
                        }
                      }, authProvider.isLoading),
                    ],
                  ),
                ),
                // --- SIGN UP SECTION ---
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      inputField('Full Name', Icons.person_outline,
                          ChangeScreenAnimationUser.createAccountAnimations[0],
                          controller: _nameSign),
                      inputField(
                        'Email',
                        Icons.mail_outline,
                        ChangeScreenAnimationUser.createAccountAnimations[1],
                        controller: _emailSign,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter email";
                          if (!val.contains("@")) return "Invalid email";
                          return null;
                        },
                      ),
                      inputField(
                        'Password',
                        Icons.lock_outline,
                        ChangeScreenAnimationUser.createAccountAnimations[2],
                        isPass: isObscureSignUp,
                        controller: _passSign,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => isObscureSignUp = !isObscureSignUp),
                          icon: Icon(isObscureSignUp
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 6) return "6+ chars";
                          return null;
                        },
                      ),
                      inputField(
                        'Confirm Password',
                        Icons.lock_reset_rounded,
                        ChangeScreenAnimationUser.createAccountAnimations[3],
                        isPass: isObscureSignUp,
                        controller: _confirmPassSign,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => isObscureSignUp = !isObscureSignUp),
                          icon: Icon(isObscureSignUp
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        validator: (val) {
                          if (val != _passSign.text) return "No match";
                          return null;
                        },
                      ),
                      actionButton('Sign Up',
                          ChangeScreenAnimationUser.createAccountAnimations[4],
                          () async {
                        if (_signUpFormKey.currentState!.validate()) {
                          bool success = await authProvider.register(
                            name: _nameSign.text,
                            email: _emailSign.text,
                            password: _passSign.text,
                            role: AuthRole.user,
                          );
                          if (success) {
                            _emailLogin.text = _emailSign.text;
                            await ChangeScreenAnimationUser.reverse();
                          }
                        }
                      }, authProvider.isLoading),
                      SlideTransition(
                        position: ChangeScreenAnimationUser
                            .createAccountAnimations[4],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 10),
                          child: Row(
                            children: const [
                              Expanded(
                                  child: Divider(
                                      color: Colors.black45, thickness: 1)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Colors.black45, thickness: 1)),
                            ],
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: ChangeScreenAnimationUser
                            .createAccountAnimations[5],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialIconWidget(
                              imagePath: 'assets/images/google.png',
                              onTap: () async {
                                bool success =
                                    await authProvider.loginWithGoogle();
                                if (success && mounted) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserProfileScreen()),
                                      (route) => false);
                                }
                              },
                            ),
                            const SizedBox(width: 25),
                            _socialIconWidget(
                                icon: Icons.phone_android,
                                onTap: () => _showPhoneNumberDialog(
                                    context, authProvider)),
                          ],
                        ),
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
              child: Center(child: BottomText(role: AuthRole.user))),
        ],
      ),
    );
  }
}
