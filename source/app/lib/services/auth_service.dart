import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_info.dart';

class AuthRepository {
  final Dio _dio = Dio();
  late ApiService _apiService;

  AuthRepository() {
    _apiService = ApiService(_dio);
  }

  Future<bool> fetchUserInfo(String token) async {
    try {
      UserInfo userInfo = await _apiService.getUserInfo("Bearer $token");

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setInt('user_id', userInfo.id);
      await prefs.setString('email', userInfo.email);
      await prefs.setString('fullName', userInfo.fullName);
      await prefs.setString('role', userInfo.role);
      await prefs.setStringList('addresses', userInfo.addresses);
      await prefs.setBool('active', userInfo.active == 1);
      await prefs.setString('createdAt', userInfo.createdAt);
      await prefs.setInt('points', userInfo.points);
      return true;
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
      return false;
    }
  }
}
