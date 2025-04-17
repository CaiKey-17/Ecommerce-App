import 'package:app/providers/profile_image_picker.dart';
import 'package:app/ui/login/change_password_page.dart';
import 'package:app/ui/login/edit_profile_page.dart';
import 'package:app/ui/login/login_page.dart';
import 'package:app/ui/login/register_page.dart';
import 'package:app/ui/profile/address_list_screen.dart';
import 'package:app/ui/login/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "";
  int points = 0;
  String token = "";
  bool check = false;
  String formattedPoints = "";
  String image_url = "";
  String email = "";

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      points = prefs.getInt('points') ?? 0;
      token = prefs.getString('token') ?? "";
      image_url = prefs.getString('image') ?? "";
      email = prefs.getString('email') ?? "";
      if (token.isNotEmpty) {
        check = true;
      } else {
        check = false;
      }
      formattedPoints = NumberFormat("#,###", "de_DE").format(points);
    });
  }

  void _logout() async {
    setState(() {
      check = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _confirmLogout() {
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
                  _logout();
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
          Column(
            children: [
              _buildHeader(token),
              Expanded(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(children: _buildMenuItems()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String token) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/nenprofile.jpg"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: ProfileImagePicker(imageUrl: image_url),
              ),
              const SizedBox(width: 10),
              token.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Điểm tích lũy:",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "🪙 $formattedPoints",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  : GestureDetector(onTap: () {}, child: const Text("")),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [
      _buildMenuItem(Icons.bar_chart, "Lịch sử điểm tích lũy", () {
        print("Nhấn vào Quản lý chi tiêu");
      }),

      _buildMenuItem(Icons.calendar_today, "Quản lý đơn hàng", () {
        print("Nhấn vào Kế hoạch di chuyển");
      }),
      SizedBox(height: 10),
      _buildMenuItem(Icons.person, "Thay đổi thông tin cá nhân", () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EditProfilePage(fullName: fullName, email: email),
          ),
        ).then((_) => _loadUserData());
      }),
      _buildMenuItem(Icons.location_history_outlined, "Sổ địa chỉ", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressListScreen()),
        );
      }),
      _buildMenuItem(Icons.language, "Thay đổi ngôn ngữ", () {
        print("Nhấn vào Home PayLater");
      }),
      _buildMenuItem(Icons.password_rounded, "Thay đổi mật khẩu", () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(token: token),
          ),
        );
      }),
      _buildMenuItem(Icons.security, "Chính sách và điều khoản", () {
        print("Nhấn vào Liên kết tài khoản");
      }),
      SizedBox(height: 10),
      check
          ? Column(
            children: [
              _buildMenuItem(Icons.password_rounded, "Đổi mật khẩu", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(token: token),
                  ),
                );
              }),
              _buildMenuItem(Icons.logout, "Đăng xuất", () {
                _confirmLogout();
              }),
            ],
          )
          : _buildMenuItem(Icons.account_circle_outlined, "Đăng nhập", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }),
    ];

    List<Widget> result = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i] is Column) {
        Column column = items[i] as Column;
        for (int j = 0; j < column.children.length; j++) {
          result.add(column.children[j]);
          if (j < column.children.length - 1) {
            result.add(
              const Divider(color: Colors.grey, thickness: 0.5, height: 0),
            );
          }
        }
      } else {
        result.add(items[i]);
      }

      if (i < items.length - 1 && items[i + 1] is! SizedBox) {
        if (items[i] is! Column ||
            (items[i] is Column && items[i + 1] is! Column)) {
          result.add(
            const Divider(color: Colors.grey, thickness: 0.5, height: 0),
          );
        }
      }
    }
    return result;
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }
}
