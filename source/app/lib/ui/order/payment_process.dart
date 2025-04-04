import 'dart:convert';

import 'package:app/globals/convert_money.dart';
import 'package:app/keys/shipping.dart';
import 'package:app/models/cart_info.dart';
import 'package:app/models/coupon_info.dart';
import 'package:app/services/api_service.dart';
import 'package:app/ui/login/UpdateAddressScreen.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/productTest.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final int orderId;
  final List<CartInfo> cartItems;

  const PaymentConfirmationScreen({
    super.key,
    required this.orderId,
    required this.cartItems,
  });

  @override
  _PaymentConfirmationScreenState createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _couponController = TextEditingController();
  String email = "";
  String address = "";
  String code = "";
  String address_codes = "";
  int points = 0;
  late ApiService apiService;
  bool isLoading = true;
  Coupon? apiResponseCoupon;
  CouponData? couponData;
  int selectedDistrict = 0;
  int selectedWard = 0;
  double shippingFee = 0;

  double discount = 0;
  bool isCouponApplied = false;
  bool isMemberPointsUsed = false;
  double get tax => totalProductPrice * 0.02;

  double get totalProductPrice {
    return widget.cartItems.fold(
      0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  }

  // List<Product> products = [
  //   Product(
  //     name: "Apple TV 4K (3rd Gen) Wifi + Ethernet",
  //     imageUrl:
  //         "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/apple-tv-4k-hero-select-202210_FMT_WHH?wid=640&hei=640&fmt=jpeg&qlt=95&.v=1664896361380",
  //     price: 3890000,
  //     originalPrice: 5123000,
  //     quantity: 1,
  //   ),
  //   Product(
  //     name: "MacBook Air M2 2023",
  //     imageUrl:
  //         "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/macbook-air-midnight-config-20220606?wid=900&hei=820&fmt=jpeg&qlt=95&.v=1654122899519",
  //     price: 28900000,
  //     originalPrice: 31900000,
  //     quantity: 1,
  //   ),
  //   Product(
  //     name: "iPhone 15 Pro Max 256GB",
  //     imageUrl:
  //         "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/macbook-air-midnight-config-20220606?wid=900&hei=820&fmt=jpeg&qlt=95&.v=1654122899519",
  //     price: 31990000,
  //     originalPrice: 34990000,
  //     quantity: 2,
  //   ),
  //   Product(
  //     name: "iPhone 15 Pro Max 256GB",
  //     imageUrl:
  //         "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/macbook-air-midnight-config-20220606?wid=900&hei=820&fmt=jpeg&qlt=95&.v=1654122899519",
  //     price: 31990000,
  //     originalPrice: 34990000,
  //     quantity: 3,
  //   ),
  // ];

  double get totalAmount {
    double subtotal = totalProductPrice + tax;
    double total = subtotal - totalDiscount + shippingFee;
    return total < 0 ? 0 : total;
  }

  Future<void> getShippingFee() async {
    setState(() {
      var temp = code.split(",");
      selectedDistrict = int.parse(temp[1]);
      selectedWard = int.parse(temp[0]);
    });

    int totalWeight = widget.cartItems.fold(
      0,
      (sum, item) => sum + (400 * item.quantity),
    );

    final url = Uri.parse(
      "https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/fee",
    );

    final body = jsonEncode({
      "to_district_id": selectedDistrict,
      "to_ward_code": selectedWard.toString(),
      "service_id": 53321,
      "service_type_id": 2,
      "weight": totalWeight,
      "length": 30,
      "width": 20,
      "height": 10,
      "insurance_value": 0,
      "coupon": null,
      "items":
          widget.cartItems.map((item) {
            return {
              "name": item.nameVariant,
              "quantity": item.quantity,
              "weight": 400,
              "length": 30,
              "width": 20,
              "height": 10,
            };
          }).toList(),
    });
    Shipping shipping = Shipping();
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Token": shipping.apiKey,
        "ShopId": shipping.shopId,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        shippingFee = (data['data']['total'] as num).toDouble();
      });
      print("Phí vận chuyển: ${shippingFee}đ");
    } else {
      setState(() {
        shippingFee = 0;
      });
      print("Áp dụng Freeship!");
    }
  }

  double get totalDiscount {
    double appliedDiscount = isCouponApplied ? discount : 0;
    double appliedMemberPoints = isMemberPointsUsed ? points.toDouble() : 0;
    return appliedDiscount + appliedMemberPoints;
  }

  Future<void> fetchCoupon(String name) async {
    try {
      final response = await apiService.findCoupon(name);

      setState(() {
        isLoading = false;
      });

      apiResponseCoupon = response;
      if (response.code == 200) {
        setState(() {
          couponData = response.data;
          discount = couponData!.couponValue ?? 0;
          isCouponApplied = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${response.message}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: "Đóng",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiResponseCoupon!.message)));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isCouponApplied = false;
      });

      if (e is DioException) {
        print("DioException: ${e.response?.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${e.response?.data['message']}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: "Đóng",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        print("Lỗi khi gọi API: $e");
      }
    }
  }

  void _changeAddress() async {
    final newAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAddressScreen(currentAddress: address),
      ),
    );

    if (newAddress != null && newAddress.isNotEmpty) {
      setState(() {
        address = newAddress;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? "";
      points = prefs.getInt('points') ?? 0;

      List<String>? codes = prefs.getStringList('codes');
      if (codes != null && codes.isNotEmpty) {
        code = codes[0];
      } else {
        code = "Chưa có địa chỉ";
      }

      List<String>? addresses = prefs.getStringList('addresses');
      if (addresses != null && addresses.isNotEmpty) {
        address = addresses[0];
      } else {
        address = "Chưa có địa chỉ";
      }
      getShippingFee();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    apiService = ApiService(Dio());
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

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
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoEmailRow("Email: ", email, isBold: true),

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
                  "Hình thức thanh toán:",
                  "Thanh toán khi nhận hàng",
                  isBold: true,
                ),

                Divider(height: 30, thickness: 1),

                Text(
                  "Sản phẩm",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildProductList(widget.cartItems),

                Divider(height: 30, thickness: 1),

                Text(
                  "Khuyến mãi đơn hàng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildCouponInput(),

                if (points > 0) _buildMemberPointsSwitch(),

                Divider(height: 30, thickness: 1),

                _buildSummaryRow("Tổng tạm tính:", totalProductPrice),
                _buildSummaryRow("Phí vận chuyển:", shippingFee),
                _buildSummaryRow("Thuế (2%):", tax),
                _buildSummaryRow("Giảm giá từ mã khuyến mãi:", -discount),
                _buildSummaryRow(
                  "Giảm giá điểm thành viên:",
                  isMemberPointsUsed ? -points.toDouble() : 0,
                ),

                if (totalDiscount > 0)
                  _buildSummaryRow(
                    "Tổng giảm giá:",
                    -totalDiscount,
                    isDiscountTotal: true,
                  ),

                _buildSummaryRow(
                  "Tổng thanh toán:",
                  totalAmount,
                  isTotal: true,
                ),

                SizedBox(height: 30),

                _buildPayButton(),
              ],
            ),
          ),
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
            "Địa chỉ: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Mặc định",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
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

  Widget _buildInfoEmailRow(String label, String value, {bool isBold = false}) {
    bool isValueEmpty = value == null || value.isEmpty;
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
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value),
              textAlign: TextAlign.right,
              enabled: isValueEmpty,
              decoration: InputDecoration(
                border: InputBorder.none, // Không hiển thị viền
                hintText: isValueEmpty ? 'Vui lòng điền email' : '${value}',
              ),
              onChanged: (newValue) {
                // Xử lý khi giá trị thay đổi ở đây
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<CartInfo> products) {
    return SingleChildScrollView(
      child: Column(
        children:
            products.map((product) => _buildProductItem(product)).toList(),
      ),
    );
  }

  Widget _buildProductItem(CartInfo product) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameVariant,
                  style: TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  "${ConvertMoney.currencyFormatter.format(product.price)} đ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "${ConvertMoney.currencyFormatter.format(product.originalPrice)} đ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            "x${product.quantity}",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            child: TextField(
              controller: _couponController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Nhập mã code ",
                hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                _couponController.notifyListeners();
              },
              onSubmitted: (value) => fetchCoupon(value),
            ),
          ),
        ),

        SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _couponController,
          builder: (context, value, child) {
            return SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed:
                    value.text.isNotEmpty
                        ? () {
                          FocusScope.of(context).unfocus();
                          fetchCoupon(value.text);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      value.text.isNotEmpty ? Colors.blue : Colors.black,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Áp dụng",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
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
                "🪙 " + ConvertMoney.currencyFormatter.format(points),
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
        "${ConvertMoney.currencyFormatter.format(amount)} đ",
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
            "${ConvertMoney.currencyFormatter.format(amount)} đ",
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color:
                  isTotal
                      ? Colors.green
                      : (isDiscountTotal ? Colors.blue : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, "/success");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size(double.infinity, 50),
        elevation: 0,
      ),
      child: Text(
        "Thanh toán",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
