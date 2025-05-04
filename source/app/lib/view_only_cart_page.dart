import 'package:app/globals/convert_money.dart';
import 'package:app/models/cart_info.dart';
import 'package:flutter/material.dart';

class ViewOnlyCartPage extends StatefulWidget {
  final bool isFromTab;

  const ViewOnlyCartPage({super.key, this.isFromTab = true});

  @override
  State<ViewOnlyCartPage> createState() => _ViewOnlyCartPageState();
}

class _ViewOnlyCartPageState extends State<ViewOnlyCartPage> {
  List<CartInfo> cartItems = [
    CartInfo(
      nameVariant: 'MacBook Air M2 - 16GB RAM',
      price: 1300000,
      originalPrice: 1400000,
      quantity: 1,
      image: 'https://example.com/macbook.jpg',
    ),
    CartInfo(
      nameVariant: 'HP Spectre x360 - OLED',
      price: 902000,
      originalPrice: 1000000,
      quantity: 1,
      image: 'https://example.com/hp_spectre.jpg',
    ),
  ];

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
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
        title: const Text('Xem giỏ hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Text('Image not available'),
                              ),
                            ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nameVariant,
                            style: const TextStyle(fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${ConvertMoney.currencyFormatter.format(item.price)} đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "${ConvertMoney.currencyFormatter.format(item.originalPrice)} đ",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 16,
                                child: Center(
                                  child: Text(
                                    "x${item.quantity}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding:
            widget.isFromTab
                ? const EdgeInsets.only(
                  left: 16,
                  top: 10,
                  right: 16,
                  bottom: 80,
                )
                : const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${ConvertMoney.currencyFormatter.format(totalPrice)} VNĐ",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 11, 79, 134),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartInfo {
  final String nameVariant;
  final int price;
  final int originalPrice;
  final int quantity;
  final String image;

  CartInfo({
    required this.nameVariant,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.image,
  });
}
