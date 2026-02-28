import 'package:flutter/material.dart';
import 'user_login_screen.dart';
import 'seller_login_screen.dart';

class UserSellerChoiceScreen extends StatefulWidget {
  const UserSellerChoiceScreen({super.key});

  @override
  State<UserSellerChoiceScreen> createState() => _UserSellerChoiceScreenState();
}

class _UserSellerChoiceScreenState extends State<UserSellerChoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _slideAnimation;

  double _userScale = 1.0;
  double _sellerScale = 1.0;

  void navigate(bool isUser) {
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isUser ? -1 : 1, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isUser ? const UserLoginScreen() : const SellerLoginScreen(),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _choiceButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isUserButton,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          if (isUserButton) {
            _userScale = 0.95;
          } else {
            _sellerScale = 0.95;
          }
        });
      },
      onTapUp: (_) {
        setState(() {
          if (isUserButton) {
            _userScale = 1.0;
          } else {
            _sellerScale = 1.0;
          }
        });
        navigate(isUserButton);
      },
      onTapCancel: () {
        setState(() {
          if (isUserButton) {
            _userScale = 1.0;
          } else {
            _sellerScale = 1.0;
          }
        });
      },
      child: AnimatedScale(
        scale: isUserButton ? _userScale : _sellerScale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              _choiceButton(
                title: 'User',
                icon: Icons.person,
                color: Colors.amber.shade700,
                isUserButton: true,
              ),
              const SizedBox(height: 20),
              _choiceButton(
                title: 'Seller',
                icon: Icons.storefront,
                color: Colors.blueGrey.shade700,
                isUserButton: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
