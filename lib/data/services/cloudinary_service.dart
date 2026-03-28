import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CloudinaryService {
  // بياناتك جاهزة
  static const String cloudName = "dlcznjfy2"; 
  static const String uploadPreset = "price_catch_preset"; 

  static Future<String?> uploadImage(String imagePath) async {
    try {
      final dio = Dio();
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
      
      //  تجهيز البيانات والصورة بطريقة نظيفة جداً
      FormData formData = FormData.fromMap({
        "upload_preset": uploadPreset,
        "file": await MultipartFile.fromFile(imagePath),
      });

      //  إرسال الطلب
      final response = await dio.post(url, data: formData);
      
      if (response.statusCode == 200) {
        //  dio بحول الـ JSON لحاله بدون ما نحتاج jsonDecode
        return response.data['secure_url']; 
      } else {
        debugPrint("Cloudinary Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Upload Exception: $e");
      return null;
    }
  }
}