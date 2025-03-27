import 'UpdateAddressScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({Key? key}) : super(key: key);
  @override
  _PaymentConfirmationScreenState createState() =>
      _PaymentConfirmationScreenState();
}

final TextEditingController _couponController = TextEditingController();

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  String email = "mainhu3304@gmail.com";
  String address = "160/91/41 Nguyễn Văn Quỳ, Phường Phú Thuận, Quận 7, TP HCM";

  double productPrice = 3890000;
  double shippingFee = 25000;
  double discount = 0;
  bool isCouponApplied = false;
  bool isMemberPointsUsed = false;

  final currencyFormatter = NumberFormat("#,###", "vi_VN");

  double get totalDiscount {
    double appliedDiscount = isCouponApplied ? discount : 0;
    double appliedMemberPoints = isMemberPointsUsed ? 50000 : 0;
    return appliedDiscount + appliedMemberPoints;
  }

  double get totalAmount {
    double subtotal = productPrice;
    double total = subtotal - totalDiscount + shippingFee;
    return total < 0 ? 0 : total;
  }

  void _applyCoupon(String code) {
    setState(() {
      if (code == "GIAM1800") {
        discount = 1800000;
        isCouponApplied = true;
      } else {
        discount = 0;
        isCouponApplied = false;
      }
    });
  }

  // void _toggleMemberPoints(bool value) {
  //   setState(() {
  //     isMemberPointsUsed = value;
  //   });
  // }

  void _changeAddress() async {
    final newAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAddressScreen(currentAddress: address),
      ),
    );

    if (newAddress != null) {
      setState(() {
        address = newAddress;
      });
    }
  }

  // @override
  // void dispose() {
  //   _couponController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Xác nhận đơn hàng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoRow("Email:", email, isBold: true),

            _buildAddressRow(),

            Divider(height: 30, thickness: 1),

            _buildInfoRow(
              "Phương thức giao hàng:",
              "Phí giao tiêu chuẩn",
              isBold: true,
            ),
            _buildPriceRow(shippingFee),

            SizedBox(height: 20),

            _buildInfoRow(
              "Phương thức thanh toán:",
              "Thanh toán khi nhận hàng",
              isBold: true,
            ),

            Divider(height: 30, thickness: 1),

            Text(
              "Sản phẩm",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildProductItem(),

            Divider(height: 30, thickness: 1),

            Text(
              "Khuyến mãi đơn hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildCouponInput(),

            _buildMemberPointsSwitch(),

            Divider(height: 30, thickness: 1),

            _buildSummaryRow("Tổng tạm tính:", productPrice),
            _buildSummaryRow("Phí vận chuyển:", shippingFee),
            _buildSummaryRow("Giảm giá từ mã khuyến mãi:", discount),
            _buildSummaryRow(
              "Giảm giá điểm thành viên:",
              isMemberPointsUsed ? -50000 : 0,
            ),

            if (totalDiscount > 0)
              _buildSummaryRow(
                "Tổng giảm giá:",
                -totalDiscount,
                isDiscountTotal: true,
              ),

            _buildSummaryRow("Tổng thanh toán:", totalAmount, isTotal: true),

            SizedBox(height: 30),

            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow() {
    return GestureDetector(
      onTap: _changeAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Địa chỉ:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/apple-tv-4k-hero-select-202210_FMT_WHH?wid=640&hei=640&fmt=jpeg&qlt=95&.v=1664896361380",
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
      title: Text(
        "Apple TV 4K (3rd Gen) Wifi + Ethernet",
        style: TextStyle(fontSize: 16),
      ),
      trailing: Text(
        "${currencyFormatter.format(productPrice)} đ",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCouponInput() {
    return TextField(
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: "Chọn hoặc nhập khuyến mãi",
        labelStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_drop_down),
              SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _applyCoupon(_couponController.text);
                },
                child: Text(
                  "Áp dụng",
                  style: TextStyle(
                    fontSize: 16,
                    color: isMemberPointsUsed ? Colors.blue : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      controller: _couponController,
      onSubmitted: (value) => _applyCoupon(value),
    );
  }

  Widget _buildMemberPointsSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Sử dụng điểm thành viên", style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(
                "(-50.000 đ)",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(width: 8),
              Switch(
                value: isMemberPointsUsed,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    isMemberPointsUsed = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(double amount) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        "${currencyFormatter.format(amount)} đ",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscountTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${currencyFormatter.format(amount)} đ",
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color:
                  isTotal
                      ? Colors.red
                      : (isDiscountTotal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed:
          totalAmount > 0
              ? () {
                print("Thanh toán thành công!");
              }
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: totalAmount > 0 ? Colors.blue : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        "Thanh toán",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
