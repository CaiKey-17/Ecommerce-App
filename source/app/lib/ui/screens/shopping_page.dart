import 'package:app/models/cart_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingCartPage extends StatefulWidget {
  final bool isFromTab; // Thêm tham số isFromTab

  const ShoppingCartPage({super.key, this.isFromTab = true});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late ApiService apiService;
  List<CartInfo> cartItems = [];
  bool isLoading = true;
  String token = "";
  int? userId;

  @override
  void didPopNext() {
    _loadUserData();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    apiService = ApiService(Dio());
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
      userId = prefs.getInt('userId') ?? -1;
      print(token);
      print(userId);
    });
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      List<CartInfo> response;
      if (token.isNotEmpty && userId == -1) {
        response = await apiService.getItemInCart(token: token);
        print("Sử dụng token");
      } else if (token == "" && userId != -1) {
        response = await apiService.getItemInCart(id: userId);
        print("Sử dụng userID");
      } else {
        response = await apiService.getItemInCart(token: token, id: userId);
        print("Cả token và userID được cung cấp");
      }
      // Xử lý response nếu cần
      setState(() {
        cartItems = response;
        isLoading = false;
      });
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  // List<Map<String, dynamic>> cartItems = [
  //   {
  //     "image": "assets/images/laptop.webp",
  //     "name": "Máy giặt Toshiba Inverter 9.5 kg TW-BK105S3V(SK)",
  //     "color": "Xám, 9.5 kg",
  //     "price": 7289000,
  //     "quantity": 1,
  //     "selected": false,
  //   },
  //   {
  //     "image": "assets/images/laptop.webp",
  //     "name": "Laptop Dell Inspiron 14",
  //     "color": "Bạc, 14 inch",
  //     "price": 14990000,
  //     "quantity": 1,
  //     "selected": false,
  //   },
  // ];

  void _toggleSelection(int index, bool? value) {
    setState(() {
      cartItems[index].selected = value!;
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      // cartItems[index].quantity++;
    });
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).updateItem(cartItems[index].orderDetailId, cartItems[index].quantity);
  }

  void _decrementQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      setState(() {
        // cartItems[index]["quantity"]--;
      });
      Provider.of<CartProvider>(
        context,
        listen: false,
      ).updateItem(cartItems[index].orderDetailId, cartItems[index].quantity);
    } else {
      _removeItem(index);
    }
  }

  void _removeItem(int index) {
    int itemId = cartItems[index].orderDetailId;
    setState(() {
      cartItems.removeAt(index);
    });
    Provider.of<CartProvider>(context, listen: false).removeItem(itemId);
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = widget.isFromTab ? 75 : 35;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E7E7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            widget.isFromTab
                ? null
                : IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
        title: const Text('Giỏ hàng'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.blue),
            onPressed: () => setState(() => cartItems.clear()),
          ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? const Center(child: Text("Giỏ hàng trống"))
              : Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item.selected,
                                activeColor: Colors.blue,
                                onChanged:
                                    (value) => _toggleSelection(index, value),
                              ),
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    item.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nameVariant,
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.colorName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${item.price.toStringAsFixed(0)}đ",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            height: 30,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap:
                                                      () => _decrementQuantity(
                                                        index,
                                                      ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                SizedBox(
                                                  width: 16,
                                                  child: Center(
                                                    child: Text(
                                                      item.quantity.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                GestureDetector(
                                                  onTap:
                                                      () => _incrementQuantity(
                                                        index,
                                                      ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: IconButton(
                            onPressed: () => _removeItem(index),
                            icon: const Icon(Icons.close, size: 14),
                            color: Colors.grey.shade600,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          top: 10,
          right: 16,
          bottom: bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${totalPrice.toStringAsFixed(0)} VND",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 79, 134),
              ),
            ),
            ElevatedButton(
              onPressed:
                  cartItems.isEmpty
                      ? null
                      : () {
                        Navigator.pushNamed(context, '/payment');
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 79, 134),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Thanh toán"),
            ),
          ],
        ),
      ),
    );
  }
}
