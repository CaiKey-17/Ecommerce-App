import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../models/login_request.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ApiService _apiService;

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(Dio());
    _loadSavedLogin();
  }

  void _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      _autoLogin(savedEmail, savedPassword);
    }
  }

  void _autoLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = LoginRequest(
        username: email.trim(),
        password: password.trim(),
      );

      final response = await _apiService.login(request);

      if (response.code == 200) {
        onLoginSuccess(response.token.toString(), response.role.toString());
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng nhập tự động thất bại, vui lòng thử lại"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi kết nối đến server")));
    }
  }

  void onLoginSuccess(String token, String role) async {
    final authRepo = AuthRepository();
    bool success = await authRepo.fetchUserInfo(token);

    if (success) {
      print("Lấy thông tin người dùng thành công!");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      if (role == 'ROLE_CUSTOMER') {
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
      if (role == 'ROLE_ADMIN') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/manager",
          (route) => false,
        );
      }
    } else {
      print("Không thể lấy thông tin người dùng.");
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập tài khoản và mật khẩu")),
      );
      return;
    }

    try {
      final request = LoginRequest(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final response = await _apiService.login(request);

      setState(() {
        _isLoading = false;
      });

      if (response.code == 200) {
        onLoginSuccess(response.token.toString(), response.role.toString());
      } else if (response.code == 401) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")));
      } else if (response.code == 403) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tài khoản đã bị cấm")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
          );
        } else if (e.response?.statusCode == 403) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Tài khoản đã bị cấm")));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi kết nối đến server")));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi không xác định")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF64B5F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Chào bạn\nĐăng nhập ngay!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Chào mừng bạn trở lại",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                "Đăng Nhập",
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ),
                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/main");
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: Text(
                        "Mua hàng không cần đăng nhập",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            "Đăng nhập với",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              'assets/images/facebook.png',
                              'Facebook',
                            ),
                            SizedBox(width: 15),
                            _buildSocialButton(
                              'assets/images/google.webp',
                              'Google',
                            ),
                            SizedBox(width: 15),
                            _buildSocialButton(
                              'assets/images/apple.png',
                              'Apple',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Bạn chưa có tài khoản? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Đăng ký",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, String name) {
    return GestureDetector(
      onTap: () {
        debugPrint("Đã nhấn vào $name");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Đã nhấn vào $name")));
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Image.asset(imagePath, width: 40, height: 40),
        ),
      ),
    );
  }
}
