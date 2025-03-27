import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đổi Mật Khẩu", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPasswordField("Mật khẩu hiện tại", _isOldPasswordVisible, () {
              setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
            }),
            SizedBox(height: 15),
            _buildPasswordField("Mật khẩu mới", _isNewPasswordVisible, () {
              setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
            }),
            SizedBox(height: 15),
            _buildPasswordField("Xác nhận mật khẩu", _isConfirmPasswordVisible, () {
              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
            }),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: Text("Xác nhận", style: TextStyle(fontSize: 18, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, bool isVisible, VoidCallback toggleVisibility) {
    return TextField(
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
