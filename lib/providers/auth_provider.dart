import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    await _authService.login(email, password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    await _authService.registerUser(name, email, password);

    isLoading = false;
    notifyListeners();
  }

  Future<void> registerSeller({
    required String storeName,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading = true;
    notifyListeners();

    await _authService.registerSeller(storeName, email, password, phone);

    isLoading = false;
    notifyListeners();
  }
}
