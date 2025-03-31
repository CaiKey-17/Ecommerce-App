import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic> defaultOrderData = {
    "id": "OD12345",
    "name": "Đơn hàng mặc định",
    "client": "Minh Luan",
    "address": "Địa chỉ mặc định",
    "status": "Chờ xử lý",
    "subtotal": 100000.0,
    "discount": 10000.0,
    "shippingFee": 20000.0,
    "totalAmount": 110000.0,
    "items": [
      {
        "imageUrl":
            "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=100&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20100w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=200&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20200w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=300&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20300w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20400w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20500w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20600w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20700w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20800w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%20900w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%201000w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1200&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%201200w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%201400w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%201600w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%201800w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D%202000w",
        "name": "Sản phẩm mặc định mai mai mai mia mai mai mai",
        "address": "Kho mặc định A",
        
        "quantity": 2,
        "price": 20000.0,
        "ship": 5000.0,
      },
      {
        "imageUrl":
            "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=100&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20100w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=200&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20200w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=300&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20300w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20400w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20500w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20600w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20700w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20800w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%20900w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%201000w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1200&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%201200w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%201400w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%201600w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=1800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%201800w,%20https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aI1hZ2V8ZW58MHx8MHx8fDA%3D%202000w",
        "name": "Sản phẩm mặc định 2",
        "address": "Kho mặc định B",
        "quantity": 1,
        "price": 30000.0,
        "ship": 5000.0,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    final order = defaultOrderData;
    items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    print("Dữ liệu order được sử dụng: $order");
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = defaultOrderData;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn hàng"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.network(items[index]['imageUrl'],
                                      width: 100, height: 100),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items[index]['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          "Địa chỉ: ${items[index]['address']}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          "SL: ${items[index]['quantity']}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Giá: ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "${items[index]['price']}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Text("Ship: ${items[index]['ship']}"),
                                  SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "Tổng: ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${items[index]['price'] * items[index]['quantity'] + items[index]['ship']}",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => removeItem(index),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin đơn hàng:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Khách hàng:", style: TextStyle(fontSize: 16)),
                      Text("${order['client']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Đơn giá:", style: TextStyle(fontSize: 16)),
                      Text("${order['subtotal']}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Giảm giá:", style: TextStyle(fontSize: 16)),
                      Text("${order['discount']}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tiền ship:", style: TextStyle(fontSize: 16)),
                      Text("${order['shippingFee']}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Trạng thái:", style: TextStyle(fontSize: 16)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${order['status']}",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tổng đơn hàng:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("${order['totalAmount']}",
                          style: TextStyle(
                              color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
