import 'package:app/luan/models/order_info.dart';
import 'package:app/luan/models/bill_info.dart';
import 'package:app/luan/models/product_variant_info.dart';
import 'package:app/luan/models/user_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/ui/admin/screens/order_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserInfo user;

  const UserDetailsScreen({required this.user, super.key});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  bool isEditing = false;
  late String updatedFullName;
  List<OrderInfo> orders = [];
  Map<int, List<BillInfo>> orderBills = {};
  Map<int, ProductVariant> productVariants = {};
  bool isLoading = false;
  late ApiAdminService apiService;
  final Dio dio = Dio();

  final List<String> orderStatuses = [
    'Đang Đặt',
    'Đang Giao',
    'Hoàn Tất',
    'Đã Hủy',
  ];

  @override
  void initState() {
    super.initState();
    apiService = ApiAdminService(dio);
    updatedFullName = widget.user.fullName;
    nameController = TextEditingController(text: updatedFullName);
    emailController = TextEditingController(text: widget.user.email);
    _loadOrdersAndBills();
  }

  Future<void> _loadOrdersAndBills() async {
    setState(() {
      isLoading = true;
    });
    try {
      debugPrint('Bắt đầu tải danh sách đơn hàng cho khách hàng ID: ${widget.user.id}');
      final fetchedOrders = await apiService.getOrdersByCustomer(widget.user.id);
      orders = fetchedOrders
        ..sort((a, b) => DateTime.parse(b.createdAt ?? '9999-12-31').compareTo(
            DateTime.parse(a.createdAt ?? '9999-12-31')));
      orderBills.clear();
      productVariants.clear();

      for (var order in orders) {
        if (order.id != null) {
          try {
            debugPrint('Tải bills cho đơn hàng ID: ${order.id}');
            final bills = await apiService.getBillsByOrder(order.id!);
            orderBills[order.id!] = bills;
          } catch (e, stackTrace) {
            debugPrint('Lỗi khi tải bills cho đơn hàng ${order.id}: $e');
            debugPrint('StackTrace: $stackTrace');
          }

          if (order.idFkProductVariant != null) {
            try {
              debugPrint('Tải biến thể cho idFkProductVariant: ${order.idFkProductVariant}');
              final variants = await apiService.getVariantsByProductId(order.idFkProductVariant!);
              if (variants.isNotEmpty) {
                productVariants[order.idFkProductVariant!] = variants.first;
              }
            } catch (e, stackTrace) {
              debugPrint('Lỗi khi lấy biến thể ${order.idFkProductVariant}: $e');
              debugPrint('StackTrace: $stackTrace');
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Lỗi khi tải dữ liệu đơn hàng: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  String formatCurrency(double? amount) {
    try {
      if (amount == null) return 'N/A';
      return NumberFormat("#,###", "vi_VN").format(amount) + " VNĐ";
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi định dạng tiền tệ: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
  }

  String formatDate(String? date) {
    try {
      if (date == null) return 'N/A';
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi định dạng ngày: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
  }

  String _translateStatus(String? backendStatus) {
    try {
      switch (backendStatus?.toLowerCase()) {
        case 'dahuy':
          return 'Đã Hủy';
        case 'danggiao':
          return 'Đang Giao';
        case 'hoantat':
          return 'Hoàn Tất';
        case 'dangdat':
          return 'Đang Đặt';
        default:
          debugPrint('Trạng thái backend không xác định: $backendStatus');
          return 'Đang Đặt';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi dịch trạng thái: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'Đang Đặt';
    }
  }

  String _toBackendStatus(String uiStatus) {
    try {
      switch (uiStatus) {
        case 'Đã Hủy':
          return 'dahuy';
        case 'Đang Giao':
          return 'danggiao';
        case 'Hoàn Tất':
          return 'hoantat';
        case 'Đang Đặt':
          return 'dangdat';
        default:
          debugPrint('Trạng thái giao diện không xác định: $uiStatus');
          return 'dangdat';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi chuyển trạng thái sang backend: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'dangdat';
    }
  }

  String _getPaymentStatus(int? orderId) {
    try {
      if (orderId == null || !orderBills.containsKey(orderId)) {
        debugPrint('Không tìm thấy bill cho orderId: $orderId');
        return 'Chưa thanh toán';
      }
      final bills = orderBills[orderId]!;
      if (bills.any((bill) => bill.statusOrder?.toLowerCase() == 'dathanhtoan')) {
        return 'Đã thanh toán';
      }
      return 'Chưa thanh toán';
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi lấy trạng thái thanh toán cho orderId $orderId: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'Chưa thanh toán';
    }
  }

  String _getPaymentMethod(int? orderId) {
    try {
      if (orderId == null || !orderBills.containsKey(orderId)) {
        debugPrint('Không tìm thấy bill cho orderId: $orderId');
        return 'N/A';
      }
      final bills = orderBills[orderId]!;
      if (bills.isNotEmpty && bills.first.methodPayment != null) {
        final method = bills.first.methodPayment!.toLowerCase();
        if (method == 'tienmat') {
          return 'Tiền mặt';
        }
        return bills.first.methodPayment!; 
      }
      debugPrint('Không có phương thức thanh toán cho orderId: $orderId');
      return 'N/A';
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi lấy phương thức thanh toán cho orderId $orderId: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'N/A';
    }
}

  String _toBackendPaymentStatus(String uiStatus) {
    try {
      switch (uiStatus) {
        case 'Đã thanh toán':
          return 'dathanhtoan';
        case 'Chưa thanh toán':
          return 'chuathanhtoan';
        default:
          debugPrint('Trạng thái thanh toán giao diện không xác định: $uiStatus');
          return 'chuathanhtoan';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi chuyển trạng thái thanh toán sang backend: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'chuathanhtoan';
    }
  }

  Future<void> _updateOrderStatus(OrderInfo order, String newStatus) async {
    if (order.id == null) {
      debugPrint('Lỗi: order.id là null khi cập nhật trạng thái');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không xác định được ID đơn hàng')),
      );
      return;
    }

    try {
      debugPrint('Cập nhật trạng thái cho đơn hàng ID: ${order.id}, Trạng thái mới: $newStatus');
      final backendStatus = _toBackendStatus(newStatus);
      await apiService.updateOrderProcess(order.id!, backendStatus);
      debugPrint('Cập nhật trạng thái đơn hàng ID: ${order.id} thành công');

      setState(() {
        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = OrderInfo(
            id: order.id,
            quantityTotal: order.quantityTotal,
            priceTotal: order.priceTotal,
            couponTotal: order.couponTotal,
            pointTotal: order.pointTotal,
            ship: order.ship,
            tax: order.tax,
            createdAt: order.createdAt,
            address: order.address,
            email: order.email,
            total: order.total,
            process: backendStatus,
            idFkCustomer: order.idFkCustomer,
            idFkProductVariant: order.idFkProductVariant,
            fkCouponId: order.fkCouponId,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái đơn hàng thành công')),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi cập nhật trạng thái đơn hàng ID: ${order.id}: $e');
      debugPrint('StackTrace: $stackTrace');
      String errorMessage = 'Lỗi khi cập nhật trạng thái: $e';
      if (e is DioException) {
        errorMessage = 'Lỗi khi cập nhật trạng thái: ${e.response?.statusCode} - ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _updatePaymentStatus(OrderInfo order, String newStatus) async {
    if (order.id == null) {
      debugPrint('Lỗi: order.id là null khi cập nhật trạng thái thanh toán');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không xác định được ID đơn hàng')),
      );
      return;
    }

    try {
      debugPrint('Cập nhật trạng thái thanh toán cho đơn hàng ID: ${order.id}, Trạng thái mới: $newStatus');
      final bills = orderBills[order.id!];
      if (bills == null || bills.isEmpty) {
        debugPrint('Lỗi: Không tìm thấy hóa đơn cho đơn hàng ID: ${order.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không tìm thấy hóa đơn cho đơn hàng')),
        );
        return;
      }

      final bill = bills.first;
      if (bill.id == null) {
        debugPrint('Lỗi: bill.id là null cho đơn hàng ID: ${order.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không xác định được ID hóa đơn')),
        );
        return;
      }

      final backendStatus = _toBackendPaymentStatus(newStatus);
      debugPrint('Gửi yêu cầu cập nhật trạng thái thanh toán tới backend: billId=${bill.id}, statusOrder=$backendStatus');
      await apiService.updateBillStatus(bill.id!, backendStatus);
      debugPrint('Cập nhật trạng thái thanh toán hóa đơn ID: ${bill.id} thành công');

      final updatedBills = await apiService.getBillsByOrder(order.id!);
      setState(() {
        orderBills[order.id!] = updatedBills;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thanh toán thành công')),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi cập nhật trạng thái thanh toán cho đơn hàng ID: ${order.id}: $e');
      debugPrint('StackTrace: $stackTrace');
      String errorMessage = 'Lỗi khi cập nhật trạng thái thanh toán: $e';
      if (e is DioException) {
        errorMessage = 'Lỗi khi cập nhật trạng thái thanh toán: ${e.response?.statusCode} - ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin người dùng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 20),
            const Text("Đơn hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildOrderTable(context),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          nameController.text = widget.user.fullName;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Đóng"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final newName = nameController.text;
                          await apiService.updateUserFullName(
                              widget.user.id, newName);
                          setState(() {
                            updatedFullName = newName;
                            isEditing = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Cập nhật tên thành công")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi khi cập nhật tên: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Lưu lại"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Họ và tên",
            border: OutlineInputBorder(),
          ),
          controller: nameController,
          enabled: isEditing,
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
          controller: emailController,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildOrderTable(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return const Center(child: Text("Không có đơn hàng nào"));
    }
    return DataTable(
      columnSpacing: 15,
      headingRowHeight: 45,
      dataRowHeight: 50,
      border: TableBorder.all(color: Colors.grey.shade300),
      columns: const [
        DataColumn(
            label: Text("Mã đơn", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Giá", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Phí ship", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Tổng tiền", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Địa chỉ", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Phương thức thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text("Chiết khấu", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Điểm", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Thời gian", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Biến thể", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text("Mã coupon", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Trạng thái", style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text("Thanh toán", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: List.generate(
        orders.length,
        (index) => _buildOrderRow(context, orders[index]),
      ),
    );
  }

  DataRow _buildOrderRow(BuildContext context, OrderInfo order) {
    return DataRow(
      cells: [
        _buildTableCell('ORD${order.id.toString().padLeft(3, '0')}'),
        _buildTableCell(formatCurrency(order.priceTotal)),
        _buildTableCell(order.quantityTotal?.toString() ?? 'N/A'),
        _buildTableCell(formatCurrency(order.ship)),
        _buildTableCell(formatCurrency(order.total)),
        _buildTableCell(order.address ?? 'N/A'),
        _buildTableCell(_getPaymentMethod(order.id)),
        _buildTableCell(formatCurrency(order.couponTotal)),
        _buildTableCell(formatCurrency(order.pointTotal)),
        _buildTableCell(formatDate(order.createdAt)),
        _buildTableCell(
            productVariants[order.idFkProductVariant]?.nameVariant ?? 'N/A'),
        _buildTableCell(order.fkCouponId?.toString() ?? 'N/A'),
        DataCell(_buildStatusDropdown(order)),
        DataCell(_buildPaymentDropdown(order)),
      ],
      onSelectChanged: (isSelected) {
        if (isSelected == true) {
          debugPrint('Chọn đơn hàng ID: ${order.id} để xem chi tiết');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                order: order,
                bills: orderBills[order.id] ?? [],
                variant: productVariants[order.idFkProductVariant],
              ),
            ),
          );
        }
      },
    );
  }

  DataCell _buildTableCell(String text) {
    return DataCell(
      Container(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(OrderInfo order) {
    final currentStatus = _translateStatus(order.process);
    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newValue) {
        if (newValue != null) {
          debugPrint('Thay đổi trạng thái cho đơn hàng ID: ${order.id} thành: $newValue');
          _updateOrderStatus(order, newValue);
        }
      },
      items: orderStatuses.map<DropdownMenuItem<String>>((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentDropdown(OrderInfo order) {
    final currentPaymentStatus = _getPaymentStatus(order.id);
    return DropdownButton<String>(
      value: currentPaymentStatus,
      onChanged: (newValue) {
        if (newValue != null && newValue != currentPaymentStatus) {
          debugPrint('Thay đổi trạng thái thanh toán cho đơn hàng ID: ${order.id} thành: $newValue');
          _updatePaymentStatus(order, newValue);
        }
      },
      items: ['Đã thanh toán', 'Chưa thanh toán']
          .map<DropdownMenuItem<String>>((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }
}