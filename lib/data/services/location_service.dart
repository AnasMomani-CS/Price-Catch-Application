import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  /// دالة لجلب الموقع الحالي للمستخدم (المشتري)
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      //  فحص صلاحيات التطبيق للوصول للموقع
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'Location permissions are permanently denied, we cannot request permissions.');
        return null;
      }

      //  جلب الإحداثيات الدقيقة إذا كل شيء سليم
      return await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // دقة عالية لضمان حساب المسافات صح
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  static double calculateDistanceInMeters(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
