import 'package:app/ui/admin/screens/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final Map<String, String> user;
  final List<Map<String, dynamic>> orders;

  UserDetailsScreen({required this.user, required this.orders});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  bool isEditing = false;
  late List<Map<String, dynamic>> _orders;
  List<String> orderStatuses = [
    "Chấp nhận",
    "Đang giao",
    "Hủy",
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user["name"]);
    emailController = TextEditingController(text: widget.user["email"]);
    addressController = TextEditingController(text: widget.user["address"] ?? "");
    _orders = List.from(widget.orders);
  }

  void _updateOrderStatus(int index, String status) {
    setState(() {
      _orders[index]["status"] = status;
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat("#,###", "vi_VN").format(amount) + " VNĐ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin người dùng"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  widget.user["name"] = nameController.text;
                  widget.user["email"] = emailController.text;
                  widget.user["address"] = addressController.text;
                }
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
            SizedBox(height: 20),
            Text("Đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildOrderTable(context),
              ),
            ),
            if (isEditing) ...[
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          nameController.text = widget.user["name"]!;
                          emailController.text = widget.user["email"]!;
                          addressController.text = widget.user["address"] ?? "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Đóng"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.user["name"] = nameController.text;
                          widget.user["email"] = emailController.text;
                          widget.user["address"] = addressController.text;
                          isEditing = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Lưu lại"),
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
          decoration: InputDecoration(
            labelText: "Họ và tên",
            border: OutlineInputBorder(),
          ),
          controller: nameController,
          enabled: isEditing,
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
          controller: emailController,
          enabled: isEditing,
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Địa chỉ",
            border: OutlineInputBorder(),
          ),
          controller: addressController,
          enabled: isEditing,
        ),
      ],
    );
  }

  Widget _buildOrderTable(BuildContext context) {
    return DataTable(
      columnSpacing: 15,
      headingRowHeight: 45,
      dataRowHeight: 50,
      border: TableBorder.all(color: Colors.grey.shade300),
      columns: [
        _buildHeaderColumn("ID"),
        _buildHeaderColumn("Tên"),
        _buildHeaderColumn("Địa chỉ"),
        _buildHeaderColumn("SL"),
        _buildHeaderColumn("Giá"),
        _buildHeaderColumn("Ship"),
        _buildHeaderColumn("Tổng"),
        _buildHeaderColumn("Trạng thái"),
      ],
      rows: List.generate(
        _orders.length,
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
    final order = _orders[index];
    return DataRow(
      cells: [
        _buildTableCell(order["id"].toString()),
        _buildTableCell(order["name"].toString()),
        _buildTableCell(order["address"].toString()),
        _buildTableCell(order["quantity"].toString()),
        _buildTableCell(order["price"].toString()),
        _buildTableCell(order["ship"].toString()),
        _buildTableCell(order["total"].toString()),
        DataCell(
          SizedBox(
            width: 150,
            child: _buildStatusDropdown(index, order["status"].toString()),
          ),
        ),
      ],
      onSelectChanged: (isSelected) {
        if (isSelected == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(),
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
          _updateOrderStatus(index, newValue);
        }
      },
      items: orderStatuses.map<DropdownMenuItem<String>>((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status, style: TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }
}