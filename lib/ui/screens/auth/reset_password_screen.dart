import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String selectedRole = 'User';

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.userPrimary, AppColors.sellerPrimary],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.sellerPrimary, AppColors.userPrimary],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -screenSize.width * 0.4,
            left: -screenSize.width * 0.1,
            child: topWidget(screenSize.width),
          ),
          Positioned(
            bottom: -screenSize.width * 0.4,
            right: -screenSize.width * 0.1,
            child: bottomWidget(screenSize.width),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize.height * 0.08),
                    const Text(
                      "Reset\nPassword",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.userPrimary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 45,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Enter your registered email to receive the reset link",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedRole = 'User'),
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: selectedRole == 'User' ? AppColors.userPrimary : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: selectedRole == 'User' ? AppColors.userPrimary : Colors.grey[300]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "User",
                                      style: TextStyle(
                                        color: selectedRole == 'User' ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedRole = 'Seller'),
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: selectedRole == 'Seller' ? AppColors.sellerPrimary : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: selectedRole == 'Seller' ? AppColors.sellerPrimary : Colors.grey[300]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Seller",
                                      style: TextStyle(
                                        color: selectedRole == 'Seller' ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Material(
                            elevation: 5,
                            shadowColor: Colors.black12,
                            borderRadius: BorderRadius.circular(30),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.sellerPrimary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(colors: [AppColors.userPrimary, AppColors.sellerPrimary]),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: authProvider.isLoading 
                                ? null 
                                : () async {
                                  String email = emailController.text.trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please enter a valid email containing '@'"), backgroundColor: Colors.redAccent),
                                    );
                                    return;
                                  }

                                  try {
                                    await authProvider.resetPassword(email);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Reset link sent successfully to $email"), backgroundColor: Colors.green),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                                      );
                                    }
                                  }
                                },
                                child: authProvider.isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("SEND LINK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 250),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}