import 'dart:math';
import 'package:flutter/material.dart';

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  List<Map<String, dynamic>> coupons = [
    {
      "id": "#001",
      "code": "SD95V",
      "value": "10%",
      "created_at": DateTime(2025, 03, 24, 20, 00, 28),
      "used_count": 4,
      "max_usage": 100,
      "orders": ["#ORD0", "#ORD1", "#ORD2"],
    },
    {
      "id": "#002",
      "code": "GT57X",
      "value": "15%",
      "created_at": DateTime(2025, 02, 10, 15, 30, 45),
      "used_count": 10,
      "max_usage": 50,
      "orders": ["#ORD3", "#ORD4"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Quản lý phiếu giảm giá",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _buildTableHeader(),
            Expanded(child: _buildCouponTable()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm mã giảm giá",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          _showCouponDialog(isEdit: false);
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerCell("ID", flex: 1),
          _headerCell("Mã giảm giá", flex: 2),
          _headerCell("Giá trị", flex: 1),
          _headerCell("Đã dùng", flex: 1), // Cột mới: số lần đã sử dụng
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCouponTable() {
    return ListView.builder(
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return GestureDetector(
          onTap: () => _showCouponDetail(coupon),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tableCell(coupon["id"]!, flex: 1),
                _tableCell(coupon["code"]!, flex: 2),
                _tableCell(coupon["value"]!, flex: 1),
                _tableCell(
                  coupon["used_count"].toString(),
                  flex: 1,
                ), // Hiển thị số lần sử dụng
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showCouponDetail(Map<String, dynamic> coupon) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chi tiết mã ${coupon["code"]}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  "Thời gian tạo: ${coupon["created_at"].toString().split(' ')[0]}",
                  style: _detailTextStyle(),
                ),
                Text("Giá trị: ${coupon["value"]}", style: _detailTextStyle()),
                Text(
                  "Số lần đã sử dụng: ${coupon["used_count"]}",
                  style: _detailTextStyle(),
                ),
                Text(
                  "Số lần sử dụng tối đa: ${coupon["max_usage"]}",
                  style: _detailTextStyle(),
                ),
                SizedBox(height: 12),
                Text("Danh sách đơn hàng áp dụng:", style: _boldTextStyle()),

                // Kiểm tra xem "orders" có tồn tại và là danh sách không
                if (coupon.containsKey("orders") &&
                    coupon["orders"] is List<String> &&
                    (coupon["orders"] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        (coupon["orders"] as List<String>).map((order) {
                          return Text(order, style: TextStyle(fontSize: 16));
                        }).toList(),
                  )
                else
                  Text(
                    "Chưa có đơn hàng nào sử dụng mã này.",
                    style: _detailTextStyle(),
                  ),

                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Đóng",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCouponDialog({required bool isEdit, int? couponIndex}) {
    TextEditingController valueController = TextEditingController();
    TextEditingController maxUsageController = TextEditingController();

    if (isEdit && couponIndex != null) {
      final coupon = coupons[couponIndex];
      valueController.text = coupon["value"]!;
      maxUsageController.text = coupon["max_usage"].toString();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thêm",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(labelText: "Giá trị"),
                ),
                TextField(
                  controller: maxUsageController,
                  decoration: InputDecoration(
                    labelText: "Số lần sử dụng tối đa",
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    setState(() {
                      int newId = coupons.length + 1;
                      coupons.add({
                        "id": "#${newId.toString().padLeft(3, '0')}",
                        "code": _generateRandomCode(),
                        "value": valueController.text,
                        "created_at": DateTime.now(),
                        "used_count": 0,
                        "max_usage": int.parse(maxUsageController.text),
                        "orders": [],
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Thêm"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _generateRandomCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
  }

  TextStyle _detailTextStyle() => TextStyle(fontSize: 16);
  TextStyle _boldTextStyle() =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}
