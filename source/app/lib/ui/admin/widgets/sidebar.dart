import 'package:app/ui/admin/screens/brand_screen.dart';
import 'package:app/ui/admin/screens/category_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_screen.dart';
import '../screens/user_screen.dart';
import '../screens/order_screen.dart';
import '../screens/coupon_screen.dart';
import '../screens/support_screen.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[700]),
            child: Center(
              child: Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }),
          _buildDrawerItem(Icons.shopping_cart, 'Quản lý loại sản phẩm', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryScreen()),
            );
          }),

          _buildDrawerItem(Icons.shopping_cart, 'Quản lý thương hiệu', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BrandScreen()),
            );
          }),
          _buildDrawerItem(Icons.shopping_cart, 'Quản lý sản phẩm', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductScreen()),
            );
          }),
          _buildDrawerItem(Icons.person, 'Quản lý người dùng', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          }),
          _buildDrawerItem(Icons.receipt, 'Quản lý đơn hàng', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderScreen()),
            );
          }),
          _buildDrawerItem(Icons.card_giftcard, 'Phiếu giảm giá', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CouponScreen()),
            );
          }),
          _buildDrawerItem(Icons.support_agent, 'Hỗ trợ khách hàng', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
