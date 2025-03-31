import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hỗ trợ khách hàng")),
      drawer: SideBar(),
      body: Center(
        child: Text(
          "Trang hỗ trợ khách hàng đang phát triển...",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
