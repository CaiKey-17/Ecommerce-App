import 'package:app/globals/ip.dart';
import 'package:app/luan/models/order_info.dart';
import 'package:app/luan/models/bill_info.dart';
import 'package:app/luan/models/product_variant_info.dart';
import 'package:app/luan/models/user_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/ui/admin/screens/order_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';

class OrderScreen extends StatefulWidget {
  final int? couponId;

  const OrderScreen({super.key, this.couponId});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String token = "";
  List<OrderInfo> orders = [];
  List<OrderInfo> filteredOrders = [];
  Map<int, List<BillInfo>> orderBills = {};
  Map<int, ProductVariant> productVariants = {};
  Map<int, UserInfo> customers = {};
  int currentPage = 1;
  final int itemsPerPage = 20;
  String selectedFilter = 'all';
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  final Dio dio = Dio();
  late ApiAdminService apiService;

  final List<String> orderStatuses = ['Chấp nhận', 'Không chấp nhận'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    apiService = ApiAdminService(dio);
    _fetchOrdersAndBills();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        token = prefs.getString('token') ?? "";
        debugPrint('Token loaded: $token');
        dio.options.headers['Authorization'] = 'Bearer $token';
      });
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi tải token từ SharedPreferences: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải token: $e')));
    }
  }

  Future<void> _fetchOrdersAndBills() async {
    setState(() {
      isLoading = true;
    });
    try {
      debugPrint('Bắt đầu tải danh sách đơn hàng...');
      final fetchedOrders =
          widget.couponId != null
              ? await apiService.getOrdersByCouponId(widget.couponId!)
              : await apiService.getAllOrders();
      orders =
          fetchedOrders..sort(
            (a, b) => DateTime.parse(
              b.createdAt ?? '9999-12-31',
            ).compareTo(DateTime.parse(a.createdAt ?? '9999-12-31')),
          );
      orderBills.clear();
      productVariants.clear();
      customers.clear();

      debugPrint(
        'Đã tải ${orders.length} đơn hàng${widget.couponId != null ? ' với fkCouponId: ${widget.couponId}' : ''}:',
      );
      for (var order in orders) {
        debugPrint(
          'Order ID: ${order.id}, CreatedAt: ${order.createdAt}, fkCouponId: ${order.fkCouponId}',
        );
      }

      for (var order in orders) {
        if (order.id != null) {
          try {
            debugPrint('Tải bills cho đơn hàng ID: ${order.id}');
            final bills = await apiService.getBillsByOrder(order.id!);
            debugPrint('BILLS cho đơn hàng ${order.id}: $bills');
            orderBills[order.id!] = bills;
          } catch (e, stackTrace) {
            debugPrint('Lỗi khi tải bills cho đơn hàng ${order.id}: $e');
            debugPrint('StackTrace: $stackTrace');
          }

          if (order.idFkProductVariant != null) {
            try {
              debugPrint(
                'Tải biến thể cho idFkProductVariant: ${order.idFkProductVariant}',
              );
              final variants = await apiService.getVariantsByProductId(
                order.idFkProductVariant!,
              );
              debugPrint(
                'Biến thể cho idFkProductVariant ${order.idFkProductVariant}: $variants',
              );
              if (variants.isNotEmpty) {
                productVariants[order.idFkProductVariant!] = variants.first;
              } else {
                debugPrint(
                  'Không tìm thấy biến thể cho idFkProductVariant: ${order.idFkProductVariant}',
                );
              }
            } catch (e, stackTrace) {
              debugPrint(
                'Lỗi khi lấy biến thể ${order.idFkProductVariant}: $e',
              );
              debugPrint('StackTrace: $stackTrace');
            }
          } else {
            debugPrint(
              'idFkProductVariant is null cho đơn hàng ID: ${order.id}',
            );
          }

          if (order.idFkCustomer != null) {
            try {
              debugPrint(
                'Tải thông tin khách hàng cho idFkCustomer: ${order.idFkCustomer}',
              );
              final customer = await apiService.getUserById(
                order.idFkCustomer!,
              );
              debugPrint(
                'Khách hàng cho idFkCustomer ${order.idFkCustomer}: ${customer.fullName}',
              );
              customers[order.idFkCustomer!] = customer;
            } catch (e, stackTrace) {
              debugPrint('Lỗi khi lấy khách hàng ${order.idFkCustomer}: $e');
              debugPrint('StackTrace: $stackTrace');
            }
          } else {
            debugPrint('idFkCustomer is null cho đơn hàng ID: ${order.id}');
          }
        }
      }

      debugPrint('\nProduct Variants:');
      if (productVariants.isEmpty) {
        debugPrint('Không có biến thể sản phẩm nào được tải.');
      } else {
        productVariants.forEach((key, value) {
          debugPrint(
            'Key: $key, ID: ${value.id}, NameVariant: ${value.nameVariant}',
          );
        });
      }

      debugPrint('\nCustomers:');
      if (customers.isEmpty) {
        debugPrint('Không có khách hàng nào được tải.');
      } else {
        customers.forEach((key, value) {
          debugPrint('Key: $key, ID: ${value.id}, FullName: ${value.fullName}');
        });
      }

      setState(() {
        _applyFilter();
        isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Lỗi khi tải dữ liệu đơn hàng: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    try {
      setState(() {
        if (selectedFilter == 'today') {
          filteredOrders =
              orders.where((order) {
                final orderDate = DateTime.parse(
                  order.createdAt ?? '9999-12-31',
                );
                return orderDate.day == now.day &&
                    orderDate.month == now.month &&
                    orderDate.year == now.year;
              }).toList();
        } else if (selectedFilter == 'yesterday') {
          filteredOrders =
              orders.where((order) {
                final orderDate = DateTime.parse(
                  order.createdAt ?? '9999-12-31',
                );
                final yesterday = now.subtract(Duration(days: 1));
                return orderDate.day == yesterday.day &&
                    orderDate.month == yesterday.month &&
                    orderDate.year == yesterday.year;
              }).toList();
        } else if (selectedFilter == 'week') {
          filteredOrders =
              orders.where((order) {
                final orderDate = DateTime.parse(
                  order.createdAt ?? '9999-12-31',
                );
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                return orderDate.isAfter(weekStart) ||
                    orderDate.isAtSameMomentAs(weekStart);
              }).toList();
        } else if (selectedFilter == 'month') {
          filteredOrders =
              orders.where((order) {
                final orderDate = DateTime.parse(
                  order.createdAt ?? '9999-12-31',
                );
                return orderDate.month == now.month &&
                    orderDate.year == now.year;
              }).toList();
        } else if (selectedFilter == 'custom' &&
            startDate != null &&
            endDate != null) {
          filteredOrders =
              orders.where((order) {
                final orderDate = DateTime.parse(
                  order.createdAt ?? '9999-12-31',
                );
                return (orderDate.isAfter(startDate!) ||
                        orderDate.isAtSameMomentAs(startDate!)) &&
                    (orderDate.isBefore(endDate!) ||
                        orderDate.isAtSameMomentAs(endDate!));
              }).toList();
        } else {
          filteredOrders = orders;
        }
        currentPage = 1;
      });
      debugPrint(
        'Đã áp dụng bộ lọc: $selectedFilter, Kết quả: ${filteredOrders.length} đơn hàng',
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi áp dụng bộ lọc: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi áp dụng bộ lọc: $e')));
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    try {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDateRange:
            startDate != null && endDate != null
                ? DateTimeRange(start: startDate!, end: endDate!)
                : null,
      );
      if (picked != null) {
        setState(() {
          startDate = picked.start;
          endDate = picked.end;
          selectedFilter = 'custom';
          _applyFilter();
        });
        debugPrint('Đã chọn khoảng thời gian: ${startDate} đến ${endDate}');
      } else {
        debugPrint('Không chọn khoảng thời gian nào.');
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi chọn khoảng thời gian: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn khoảng thời gian: $e')),
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
          return 'Không chấp nhận';
        case 'danggiao':
          return 'Chấp nhận';
        default:
          debugPrint('Trạng thái backend không xác định: $backendStatus');
          return 'Chấp nhận';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi dịch trạng thái: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'Chấp nhận';
    }
  }

  String _toBackendStatus(String uiStatus) {
    try {
      switch (uiStatus) {
        case 'Không chấp nhận':
          return 'dahuy';
        case 'Chấp nhận':
          return 'danggiao';
        default:
          debugPrint('Trạng thái giao diện không xác định: $uiStatus');
          return 'danggiao';
      }
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi chuyển trạng thái sang backend: $e');
      debugPrint('StackTrace: $stackTrace');
      return 'danggiao';
    }
  }

  String _getPaymentStatus(int? orderId) {
    try {
      if (orderId == null || !orderBills.containsKey(orderId)) {
        debugPrint('Không tìm thấy bill cho orderId: $orderId');
        return 'Chưa thanh toán';
      }
      final bills = orderBills[orderId]!;
      if (bills.any(
        (bill) => bill.statusOrder?.toLowerCase() == 'dathanhtoan',
      )) {
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

  Future<void> _updateOrderStatus(OrderInfo order, String newStatus) async {
    if (order.id == null) {
      debugPrint('Lỗi: order.id là null khi cập nhật trạng thái');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Không xác định được ID đơn hàng')),
      );
      return;
    }

    try {
      debugPrint(
        'Cập nhật trạng thái cho đơn hàng ID: ${order.id}, Trạng thái mới: $newStatus',
      );
      final backendStatus = _toBackendStatus(newStatus);
      debugPrint(
        'Gửi yêu cầu cập nhật trạng thái tới backend: orderId=${order.id}, process=$backendStatus',
      );
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
          debugPrint(
            'Đã cập nhật đơn hàng ID: ${order.id} trong danh sách cục bộ',
          );
          _applyFilter();
        } else {
          debugPrint(
            'Lỗi: Không tìm thấy đơn hàng ID: ${order.id} trong danh sách',
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái đơn hàng thành công')),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi cập nhật trạng thái đơn hàng ID: ${order.id}: $e');
      debugPrint('StackTrace: $stackTrace');
      String errorMessage = 'Lỗi khi cập nhật trạng thái: $e';
      if (e is DioException) {
        errorMessage =
            'Lỗi khi cập nhật trạng thái: ${e.response?.statusCode} - ${e.message}';
        debugPrint(
          'DioException details: StatusCode=${e.response?.statusCode}, ResponseData=${e.response?.data}',
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  List<OrderInfo> _getPagedOrders() {
    try {
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = startIndex + itemsPerPage;
      final pagedOrders = filteredOrders.sublist(
        startIndex,
        endIndex > filteredOrders.length ? filteredOrders.length : endIndex,
      );
      debugPrint(
        'Lấy trang đơn hàng: Trang $currentPage, Số lượng: ${pagedOrders.length}',
      );
      return pagedOrders;
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi phân trang đơn hàng: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.couponId != null
              ? "Đơn hàng sử dụng mã coupon"
              : "Quản lý đơn hàng",
        ),
      ),
      drawer: SideBar(token: token),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(context),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildOrderTable(context),
                  ),
                ),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    try {
      return Row(
        children: [
          DropdownButton<String>(
            value: selectedFilter,
            items: [
              DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
              DropdownMenuItem(value: 'yesterday', child: Text('Hôm qua')),
              DropdownMenuItem(value: 'week', child: Text('Tuần này')),
              DropdownMenuItem(value: 'month', child: Text('Tháng này')),
              DropdownMenuItem(value: 'custom', child: Text('Tùy chỉnh')),
            ],
            onChanged: (value) {
              try {
                setState(() {
                  selectedFilter = value ?? 'all';
                  if (selectedFilter != 'custom') {
                    startDate = null;
                    endDate = null;
                    _applyFilter();
                  } else {
                    _selectDateRange(context);
                  }
                });
                debugPrint('Đã chọn bộ lọc: $selectedFilter');
              } catch (e, stackTrace) {
                debugPrint('Lỗi khi thay đổi bộ lọc: $e');
                debugPrint('StackTrace: $stackTrace');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi thay đổi bộ lọc: $e')),
                );
              }
            },
          ),
          if (selectedFilter == 'custom' &&
              startDate != null &&
              endDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}',
                style: TextStyle(fontSize: 14),
              ),
            ),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng phần lọc: $e');
      debugPrint('StackTrace: $stackTrace');
      return SizedBox.shrink();
    }
  }

  Widget _buildOrderTable(BuildContext context) {
    try {
      final pagedOrders = _getPagedOrders();
      return DataTable(
        columnSpacing: 10,
        headingRowHeight: 45,
        dataRowHeight: 50,
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: [
          _buildHeaderColumn("Mã đơn"),
          _buildHeaderColumn("Giá"),
          _buildHeaderColumn("Số lượng"),
          _buildHeaderColumn("Phí ship"),
          _buildHeaderColumn("Thuế"),
          _buildHeaderColumn("Tổng tiền"),
          _buildHeaderColumn("Tên khách hàng"),
          _buildHeaderColumn("Email"),
          _buildHeaderColumn("Địa chỉ"),
          _buildHeaderColumn("Phương thức thanh toán"),
          _buildHeaderColumn("Chiết khấu"),
          _buildHeaderColumn("Điểm"),
          _buildHeaderColumn("Thời gian"),
          _buildHeaderColumn("Thanh toán"),
          _buildHeaderColumn("Trạng thái"),
        ],
        rows: List.generate(
          pagedOrders.length,
          (index) => _buildOrderRow(context, pagedOrders[index]),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng bảng đơn hàng: $e');
      debugPrint('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xây dựng bảng đơn hàng: $e')),
      );
      return SizedBox.shrink();
    }
  }

  DataColumn _buildHeaderColumn(String title) {
    try {
      return DataColumn(
        label: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng tiêu đề cột: $title, Lỗi: $e');
      debugPrint('StackTrace: $stackTrace');
      return DataColumn(label: Text(''));
    }
  }

  DataRow _buildOrderRow(BuildContext context, OrderInfo order) {
    try {
      return DataRow(
        cells: [
          _buildTableCell('ORD${order.id.toString().padLeft(3, '0')}'),
          _buildTableCell(formatCurrency(order.priceTotal)),
          _buildTableCell(order.quantityTotal?.toString() ?? 'N/A'),
          _buildTableCell(formatCurrency(order.ship)),
          _buildTableCell(formatCurrency(order.tax)),
          _buildTableCell(formatCurrency(order.total)),
          _buildTableCell(customers[order.idFkCustomer]?.fullName ?? 'N/A'),
          _buildTableCell(order.email ?? 'N/A'),
          _buildTableCell(order.address ?? 'N/A'),
          _buildTableCell(_getPaymentMethod(order.id)),
          _buildTableCell(formatCurrency(order.couponTotal)),
          _buildTableCell(formatCurrency(order.pointTotal)),
          _buildTableCell(formatDate(order.createdAt)),
          DataCell(_buildPaymentStatusText(order)),
          DataCell(_buildStatusDropdown(order)),
        ],
        onSelectChanged: (isSelected) {
          try {
            if (isSelected == true) {
              debugPrint('Chọn đơn hàng ID: ${order.id} để xem chi tiết');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => OrderDetailsScreen(
                        order: order,
                        bills: orderBills[order.id] ?? [],
                        variant: productVariants[order.idFkProductVariant],
                      ),
                ),
              ).then((value) {
                // Reload dữ liệu khi quay lại từ OrderDetailsScreen
                _fetchOrdersAndBills();
              });
            }
          } catch (e, stackTrace) {
            debugPrint('Lỗi khi chọn đơn hàng ID: ${order.id}: $e');
            debugPrint('StackTrace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi chọn đơn hàng: $e')),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng hàng cho đơn hàng ID: ${order.id}: $e');
      debugPrint('StackTrace: $stackTrace');
      return DataRow(cells: []);
    }
  }

  DataCell _buildTableCell(String text) {
    try {
      return DataCell(
        Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng ô bảng với nội dung: $text, Lỗi: $e');
      debugPrint('StackTrace: $stackTrace');
      return DataCell(SizedBox.shrink());
    }
  }

  Widget _buildStatusDropdown(OrderInfo order) {
    try {
      final currentStatus = _translateStatus(order.process);
      return DropdownButton<String>(
        value: currentStatus,
        onChanged: (newValue) {
          try {
            if (newValue != null) {
              debugPrint(
                'Thay đổi trạng thái cho đơn hàng ID: ${order.id} thành: $newValue',
              );
              _updateOrderStatus(order, newValue);
            } else {
              debugPrint(
                'Không có giá trị trạng thái mới cho đơn hàng ID: ${order.id}',
              );
            }
          } catch (e, stackTrace) {
            debugPrint(
              'Lỗi khi thay đổi trạng thái dropdown cho đơn hàng ID: ${order.id}: $e',
            );
            debugPrint('StackTrace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi thay đổi trạng thái: $e')),
            );
          }
        },
        items:
            orderStatuses.map<DropdownMenuItem<String>>((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Chấp nhận' ? Colors.green : Colors.red,
                  ),
                ),
              );
            }).toList(),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi xây dựng dropdown trạng thái cho đơn hàng ID: ${order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      return SizedBox.shrink();
    }
  }

  Widget _buildPaymentStatusText(OrderInfo order) {
    try {
      final paymentStatus = _getPaymentStatus(order.id);
      return Text(
        paymentStatus,
        style: TextStyle(
          fontSize: 14,
          color: paymentStatus == 'Đã thanh toán' ? Colors.green : Colors.black,
        ),
        textAlign: TextAlign.center,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Lỗi khi xây dựng trạng thái thanh toán cho đơn hàng ID: ${order.id}: $e',
      );
      debugPrint('StackTrace: $stackTrace');
      return SizedBox.shrink();
    }
  }

  Widget _buildPaginationControls() {
    try {
      final totalPages = (filteredOrders.length / itemsPerPage).ceil();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:
                currentPage > 1
                    ? () {
                      setState(() {
                        currentPage--;
                        debugPrint('Chuyển về trang trước: Trang $currentPage');
                      });
                    }
                    : null,
          ),
          Text('Trang $currentPage / $totalPages'),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed:
                currentPage < totalPages
                    ? () {
                      setState(() {
                        currentPage++;
                        debugPrint('Chuyển sang trang sau: Trang $currentPage');
                      });
                    }
                    : null,
          ),
        ],
      );
    } catch (e, stackTrace) {
      debugPrint('Lỗi khi xây dựng điều khiển phân trang: $e');
      debugPrint('StackTrace: $stackTrace');
      return SizedBox.shrink();
    }
  }
}
