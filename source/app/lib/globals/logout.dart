import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutHelper {
  static Future<void> logout(
    BuildContext context,
    VoidCallback onLogout,
  ) async {
    onLogout(); // Gọi callback để cập nhật state nếu cần
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  static void confirmLogout(BuildContext context, VoidCallback onLogout) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận đăng xuất"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  logout(context, onLogout);
                },
                child: const Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
