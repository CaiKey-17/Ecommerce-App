import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // PagingController cho từng tab
  final PagingController<int, Map<String, dynamic>> _pendingController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Map<String, dynamic>> _deliveringController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Map<String, dynamic>> _deliveredController =
      PagingController(firstPageKey: 0);

  static const int _pageSize = 3;

  // Danh sách đơn hàng mẫu
  final List<Map<String, dynamic>> pendingOrders = [
    {
      "store": "Honjianda Official Store",
      "status": "Chờ xác nhận",
      "image": "assets/images/dienthoai.webp",
      "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh",
      "time": "23/02/2025, 17:01",
      "details": "0448, 8 lỗ cắm, 1.8 mét",
      "quantity": 1,
      "totalPrice": 99000,
    },
    {
      "store": "Honjianda Official Store",
      "status": "Chờ xác nhận",
      "image": "assets/images/dienthoai.webp",
      "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh",
      "time": "23/02/2025, 17:01",
      "details": "0448, 8 lỗ cắm, 1.8 mét",
      "quantity": 1,
      "totalPrice": 99000,
    },
    {
      "store": "Honjianda Official Store",
      "status": "Chờ xác nhận",
      "image": "assets/images/dienthoai.webp",
      "name": "Ổ cắm điện đa năng HONJIANDA Sạc nhanh",
      "time": "23/02/2025, 17:01",
      "details": "0448, 8 lỗ cắm, 1.8 mét",
      "quantity": 1,
      "totalPrice": 99000,
    },
  ];

  final List<Map<String, dynamic>> deliveringOrders = [
    {
      "store": "Tech Store",
      "status": "Chờ giao hàng",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Switch Brown, kết nối USB",
      "quantity": 1,
      "totalPrice": 499000,
    },
  ];

  final List<Map<String, dynamic>> deliveredOrders = [
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
    {
      "store": "Điện máy xanh",
      "status": "Đã giao",
      "image": "assets/images/dienthoai.webp",
      "name": "Bàn phím cơ RGB gaming",
      "time": "23/02/2025",
      "details": "Công suất 200W, làm mát nhanh",
      "quantity": 1,
      "totalPrice": 1599000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Thiết lập listener cho từng controller
    _pendingController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _pendingController, pendingOrders);
    });
    _deliveringController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _deliveringController, deliveringOrders);
    });
    _deliveredController.addPageRequestListener((pageKey) {
      _fetchOrders(pageKey, _deliveredController, deliveredOrders);
    });
  }

  // Hàm lấy dữ liệu phân trang
  Future<void> _fetchOrders(
    int pageKey,
    PagingController<int, Map<String, dynamic>> controller,
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final startIndex = pageKey * _pageSize;
      final endIndex =
          (startIndex + _pageSize) > orders.length
              ? orders.length
              : (startIndex + _pageSize);
      final newItems = orders.sublist(startIndex, endIndex);

      final isLastPage =
          newItems.length < _pageSize || endIndex == orders.length;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pendingController.dispose();
    _deliveringController.dispose();
    _deliveredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Hoạt động"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 31, 133, 216),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.blue),
            onPressed: () {
              print("Nhấn vào thông báo!");
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              indicatorColor: Colors.blue,
              indicatorWeight: 3.0,
              tabs: const [
                Tab(text: "Chờ xác nhận"),
                Tab(text: "Chờ giao hàng"),
                Tab(text: "Lịch sử"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOrderList(_pendingController, pendingOrders),
          buildOrderList(_deliveringController, deliveringOrders),
          buildOrderList(_deliveredController, deliveredOrders),
        ],
      ),
    );
  }

  Widget buildOrderList(
    PagingController<int, Map<String, dynamic>> controller,
    List<Map<String, dynamic>> orders,
  ) {
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: controller,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 62),
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        itemBuilder: (context, order, index) {
          Widget actionButton;
          Widget? refundButton;

          if (order["status"] == "Chờ xác nhận") {
            actionButton = OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text("Hủy đơn hàng"),
            );
          } else if (order["status"] == "Chờ giao hàng") {
            actionButton = ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Đã nhận được hàng",
                style: TextStyle(color: Colors.white),
              ),
            );
            refundButton = OutlinedButton(
              onPressed: () {},
              child: const Text("Trả hàng/Hoàn tiền"),
            );
          } else {
            actionButton = ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Đánh giá",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order["status"] ?? "Không xác định",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              order["image"] ?? "assets/images/dienthoai.webp",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order["name"] ?? "Sản phẩm không có tên",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              order["time"] ?? "Không có thời gian",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "và ${order["quantity"] ?? 0} sản phẩm khác",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng số tiền:",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "₫${order["totalPrice"]?.toString() ?? 'N/A'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (refundButton != null) refundButton,
                      const SizedBox(width: 10),
                      actionButton,
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        firstPageProgressIndicatorBuilder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.5, // Giới hạn chiều cao
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            period: const Duration(seconds: 1),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Số lượng placeholder
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 150,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 120,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        newPageProgressIndicatorBuilder:
            (context) => const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 58),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Đang tải thêm ...",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        noItemsFoundIndicatorBuilder:
            (context) => const Center(
              child: Text(
                "Không có đơn hàng nào!",
                style: TextStyle(fontSize: 16),
              ),
            ),
      ),
    );
  }
}
