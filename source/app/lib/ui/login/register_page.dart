import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';
import '../../models/register_request.dart';
import '../../services/api_service.dart';
import '../../models/register_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreeToTerms = false;
  bool _isLoading = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _specificAddressController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _register() async {
    if (_selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null) {
      Fluttertoast.showToast(msg: "Vui lòng chọn đầy đủ địa chỉ");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String fullName = _fullNameController.text.trim();

    String fullAddress =
        "$_selectedProvince, $_selectedDistrict, $_selectedWard, ${_specificAddressController.text}";

    // if (email.isEmpty || !RegExp(r"^[A-Za-z0-9+_.-]+@(.+)$").hasMatch(email)) {
    //   Fluttertoast.showToast(msg: "Email không hợp lệ");
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập mật khẩu");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final dio = Dio();
    final apiService = ApiService(dio);

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        address: fullAddress,
        fullname: fullName,
      );

      final response = await apiService.register(request);

      if (response.code == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setString('address', fullAddress);
        await prefs.setString('fullName', fullName);

        Navigator.pushReplacementNamed(context, "/otp");
        Fluttertoast.showToast(msg: response.message);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      if (e is DioException) {
        Fluttertoast.showToast(
          msg: e.response?.data['message'] ?? "Lỗi server",
        );
      } else {
        Fluttertoast.showToast(msg: "Lỗi kết nối đến server: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProvinces() async {
    final url = 'https://vn-public-apis.fpo.vn/provinces/getAll?limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _provinces = data['data']['data'];
        });
      } else {
        throw Exception('Không thể tải danh sách tỉnh/thành phố');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy tỉnh: $e');
    }
  }

  Future<void> _fetchDistricts(String provinceCode) async {
    final url =
        'https://vn-public-apis.fpo.vn/districts/getByProvince?provinceCode=$provinceCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districts = data['data']['data'];
          _wards.clear();
          _selectedDistrict = null;
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách quận/huyện');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy quận/huyện: $e');
    }
  }

  Future<void> _fetchWards(String districtCode) async {
    final url =
        'https://vn-public-apis.fpo.vn/wards/getByDistrict?districtCode=$districtCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _wards = data['data']['data'];
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách xã/phường');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy xã/phường: $e');
    }
  }

  // bool _isValidEmail(String email) {
  //   final RegExp regex = RegExp(
  //     r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
  //   );
  //   return regex.hasMatch(email);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Text(
              "Chào bạn\nĐăng ký ngay!",
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Tạo tài khoản mới",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Họ tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập họ tên';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: 'Địa chỉ Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Vui lòng nhập email của bạn';
                          // if (!_isValidEmail(value))
                          //   return 'Định dạng email không hợp lệ';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Xác nhận mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedProvince,
                        items:
                            _provinces.map((province) {
                              return DropdownMenuItem<String>(
                                value: province['name'],
                                child: Text(province['name']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProvince = value;
                            _districts.clear();
                            _wards.clear();
                          });
                          if (value != null) {
                            String? provinceCode =
                                _provinces.firstWhere(
                                  (p) => p['name'] == value,
                                  orElse: () => null,
                                )?['code'];
                            if (provinceCode != null)
                              _fetchDistricts(provinceCode);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Tỉnh/Thành phố',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        items:
                            _districts.map((district) {
                              return DropdownMenuItem<String>(
                                value: district['name'],
                                child: Text(district['name']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _wards.clear();
                          });
                          final selectedDistrict = _districts.firstWhere(
                            (d) => d['name'] == value,
                            orElse: () => null,
                          );
                          if (selectedDistrict != null)
                            _fetchWards(selectedDistrict['code']);
                        },
                        decoration: InputDecoration(
                          labelText: 'Quận/Huyện',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedWard,
                        items:
                            _wards.map((ward) {
                              return DropdownMenuItem<String>(
                                value: ward['name'],
                                child: Text(ward['name']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWard = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Xã/Phường',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: _specificAddressController,
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ cụ thể',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "Tôi đồng ý với Điều khoản và Chính sách bảo mật.",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_agreeToTerms && !_isLoading)
                                  ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      await _register();
                                      setState(() => _isLoading = false);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Vui lòng kiểm tra lại thông tin!",
                                      );
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor:
                                (_agreeToTerms && !_isLoading)
                                    ? Colors.blue
                                    : Colors.grey[300],
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
                                    "Đăng ký",
                                    style: TextStyle(fontSize: 18),
                                  ),
                        ),
                      ),
                      SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Đã có tài khoản? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: "Đăng nhập",
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
