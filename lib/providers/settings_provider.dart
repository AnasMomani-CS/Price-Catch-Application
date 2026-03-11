import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Locale _currentLocale = const Locale('en');

  bool get isDarkMode => _isDarkMode;
  Locale get currentLocale => _currentLocale;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'profile': 'Profile',
      'settings': 'Settings',
      'more': 'More',
      'about': 'About Price Catch',
      'logout': 'Logout',
      'save': 'Save Changes',
      'edit': 'Edit',
      'cancel': 'Cancel',
      'dark_mode': 'Dark Mode',
      'lang': 'Language',

      // User Profile
      'my_info': 'My Information',
      'name': 'Name',
      'email': 'Email',
      'phone': 'Phone',
      'gender': 'Gender',
      'birth': 'Birth Date',
      'my_catches': 'My Catches',

      // Seller Profile 
      'seller_profile': 'Seller Profile',
      'store_info': 'Store Information',
      'store_name': 'Store Name',
      'category': 'Category',
      'address': 'Store Location (Link)',
      'description': 'Description',
      'my_offers': 'My Offers',
    },
    'ar': {
      // عام
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'more': 'المزيد',
      'about': 'حول Price Catch',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ التعديلات',
      'edit': 'تعديل',
      'cancel': 'إلغاء',
      'dark_mode': 'الوضع الليلي',
      'lang': 'اللغة',

      // ملف المستخدم
      'my_info': 'معلوماتي',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'gender': 'الجنس',
      'birth': 'تاريخ الميلاد',
      'my_catches': 'قائمة مراقبتي',

      'seller_profile': 'بروفايل المتجر',
      'store_info': 'معلومات المتجر',
      'store_name': 'اسم المتجر',
      'category': 'الفئة',
      'address': 'موقع المحل (رابط)',
      'description': 'الوصف',
      'my_offers': 'عروضي',
    }
  };

  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }


  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    String lang = prefs.getString('langCode') ?? 'en';
    _currentLocale = Locale(lang);
    notifyListeners();
  }

  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langCode', langCode);
  }

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'ar') {
      changeLanguage('en');
    } else {
      changeLanguage('ar');
    }
  }
}
