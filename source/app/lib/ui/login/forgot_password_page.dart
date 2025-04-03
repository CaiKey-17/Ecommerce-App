import 'package:flutter/material.dart';
import 'verify_otp_register.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool isButtonEnabled = false;
  bool isLoading = false;

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  void _validateInput(String input) {
    String? error;

    if (input.isEmpty) {
      error = "Vui lòng nhập email!";
    } else if (!isValidEmail(input)) {
      error = "Email không hợp lệ!";
    }

    setState(() {
      _errorMessage = error;
      isButtonEnabled = (error == null);
    });
  }

  void sendResetPassword(String email) async {
    final dio = Dio();
    final apiService = ApiService(dio);
    setState(() {
      isLoading = true;
    });
    try {
      await apiService.sendResetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email đặt lại mật khẩu đã được gửi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: Không thể gửi email!"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Khôi phục tài khoản",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        centerTitle: true,
        elevation: 7,
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nhập email để đặt lại mật khẩu.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
                errorText: _errorMessage,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: _validateInput,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isButtonEnabled && !isLoading
                        ? () => sendResetPassword(_controller.text.trim())
                        : null,

                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor:
                      isButtonEnabled ? Colors.blue : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Text("Xác nhận"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
