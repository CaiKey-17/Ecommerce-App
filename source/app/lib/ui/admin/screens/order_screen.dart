import 'package:app/ui/admin/screens/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart'; // Định dạng tiền VNĐ

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String token = "";

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeOrders();
  }

  List<Map<String, dynamic>> orders = [];
  int orderCounter = 1;
  List<String> orderStatuses = [
    "Đang xử lý",
    "Đang vận chuyển",
    "Đã hoàn thành",
    "Đã hủy",
  ];

  void _initializeOrders() {
    for (int i = 1; i <= 10; i++) {
      _addOrder("ORD00$i", "KH00$i", 2000000 + i * 100000, "Đang xử lý");
    }
  }

  void _addOrder(String id, String customerId, double total, String status) {
    setState(() {
      orders.add({
        "id": id,
        "customerId": customerId,
        "total": total,
        "status": status,
      });
      orderCounter++;
    });
  }

  void _updateOrder(int index, String status) {
    setState(() {
      orders[index]["status"] = status;
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat("#,###", "vi_VN").format(amount) + " VNĐ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý đơn hàng")),
      drawer: SideBar(token: token),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Cuộn ngang nếu nội dung dài
                child: _buildOrderTable(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTable(BuildContext context) {
    return DataTable(
      columnSpacing: 15, // Điều chỉnh khoảng cách giữa các cột
      headingRowHeight: 45,
      dataRowHeight: 50,
      border: TableBorder.all(color: Colors.grey.shade300), // Thêm viền bảng
      columns: [
        _buildHeaderColumn("Mã đơn"),
        _buildHeaderColumn("Khách hàng"),
        _buildHeaderColumn("Tổng tiền"),
        _buildHeaderColumn("Trạng thái"),
      ],
      rows: List.generate(
        orders.length,
        (index) => _buildOrderRow(context, index),
      ),
    );
  }

  DataColumn _buildHeaderColumn(String title) {
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
  }

  DataRow _buildOrderRow(BuildContext context, int index) {
    final order = orders[index];
    return DataRow(
      cells: [
        _buildTableCell(order["id"]),
        _buildTableCell(order["customerId"]),
        _buildTableCell(formatCurrency(order["total"])),
        DataCell(_buildStatusDropdown(index, order["status"])),
      ],
      onSelectChanged: (isSelected) {
        if (isSelected == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetailsScreen()),
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
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(int index, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newValue) {
        if (newValue != null) {
          _updateOrder(index, newValue);
        }
      },
      items:
          orderStatuses.map<DropdownMenuItem<String>>((String status) {
            return DropdownMenuItem<String>(value: status, child: Text(status));
          }).toList(),
    );
  }

  void _showOrderDetailDialog(BuildContext context, int orderIndex) {
    final order = orders[orderIndex];
    String selectedStatus = order["status"];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Chi tiết đơn hàng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildDetailRow("Mã đơn hàng:", order["id"]),
                _buildDetailRow("Khách hàng:", order["customerId"]),
                _buildDetailRow("Tổng tiền:", formatCurrency(order["total"])),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedStatus,
                  decoration: InputDecoration(labelText: "Trạng thái"),
                  items:
                      orderStatuses.map((String status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value as String;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _updateOrder(orderIndex, selectedStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Cập nhật",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
