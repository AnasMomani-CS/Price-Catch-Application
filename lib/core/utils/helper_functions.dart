import 'package:flutter/material.dart';
import '../enums/auth_role.dart';
import '../theme/app_colors.dart';

class HelperFunctions {
  // جلب اللون الأساسي حسب الدور
  static Color getPrimaryColor(AuthRole role) {
    return role == AuthRole.user
        ? AppColors.userPrimary
        : AppColors.sellerPrimary;
  }

  // جلب اللون الأغمق (للعناوين أو الأزرار التي تحتاج تباين عالي)
  static Color getDeepDarkColor(AuthRole role) {
    return role == AuthRole.user
        ? AppColors.userDeepDark
        : AppColors.sellerDeepDark;
  }

  // جلب اللون الأفتح (لخلفيات العناصر الصغيرة أو  Containers)
  static Color getLightColor(AuthRole role) {
    return role == AuthRole.user ? AppColors.userLight : AppColors.sellerLight;
  }

  // جلب خلفية الصفحة (ممكن توحدها أو تخليها تميل لدرجة الدور)
  static Color getPageBackgroundColor(AuthRole role) {
    // إذا كنت تريد خلفية فاتحة جداً ولكن مائلة قليلاً لثيم الدور
    return role == AuthRole.user
        ? AppColors.userLight.withOpacity(0.3) // برتقالي خفيف جداً
        : AppColors.backgroundLight; // رمادي التطبيق العام
  }

  // جلب نص العنوان المترجم
  static String getRoleTitle(AuthRole role) {
    return role == AuthRole.user ? "User" : "Seller";
  }

  // دالة إضافية مفيدة جداً لرسائل الترحيب
  static String getWelcomeMessage(AuthRole role) {
    return role == AuthRole.user
        ? "Find the best prices around you!"
        : "Manage your store and offers easily.";
  }
}
