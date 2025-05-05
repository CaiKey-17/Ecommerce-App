  import 'package:app/luan/models/user_info.dart';
import 'package:app/services/api_admin_service.dart';
  import 'package:app/ui/admin/screens/order_detail_screen.dart';
import 'package:dio/dio.dart';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';

  class UserDetailsScreen extends StatefulWidget {
    final UserInfo user;

    UserDetailsScreen({required this.user});

    @override
    _UserDetailsScreenState createState() => _UserDetailsScreenState();
  }

  class _UserDetailsScreenState extends State<UserDetailsScreen> {
    late TextEditingController nameController;
    late TextEditingController emailController;
    bool isEditing = false;
    late String updatedFullName;
    late List<Map<String, dynamic>> _orders;
    bool isLoadingOrders = false;
    late ApiAdminService apiAdminService;

    List<String> orderStatuses = [
      "Chấp nhận",
      "Đang giao",
      "Hủy",
    ];

    Future<void> _loadOrders() async {
      setState(() {
        isLoadingOrders = true;
      });
      try {
        final orders = await apiAdminService.getOrdersByCustomer(widget.user.id);
        print("Orders from API: $orders");
        setState(() {
          _orders = orders.map((order) => {
            "id": order.id,
            "name": widget.user.fullName,
            "address": order.address ?? "Chưa cung cấp",
            "quantity": order.quantityTotal ?? 0,
            "price": formatCurrency(order.priceTotal ?? 0.0),
            "ship": formatCurrency(order.ship ?? 0.0),
            "total": formatCurrency(order.total ?? 0.0),
            "status": order.process ?? "Chưa xác định",
          }).toList();
        });
      } catch (e) {
        print("Lỗi khi tải đơn hàng: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải danh sách đơn hàng: $e")),
        );
      } finally {
        setState(() {
          isLoadingOrders = false;
        });
      }
    }

    @override
    void initState() {
      super.initState();
      apiAdminService = ApiAdminService(Dio());
      updatedFullName = widget.user.fullName;
      nameController = TextEditingController(text: updatedFullName);
      emailController = TextEditingController(text: widget.user.email);
      _orders = []; 
      _loadOrders();
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
                  // if (isEditing) {
                  //   widget.user = nameController.text;
                  //   widget.user["email"] = emailController.text;
                  // }
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
                            nameController.text = widget.user.fullName; 
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
                        onPressed: () async {
                          try {
                            final newName = nameController.text;
                            await apiAdminService.updateUserFullName(widget.user.id, newName);
                            setState(() {
                              updatedFullName = newName;
                              isEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cập nhật tên thành công")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lỗi khi cập nhật tên: $e")),
                            );
                          }
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
            enabled: false,
          ),
        ],
      );
    }

    Widget _buildOrderTable(BuildContext context) {
      if (isLoadingOrders) {
        return Center(child: CircularProgressIndicator());
      }
      if (_orders.isEmpty) {
        return Center(child: Text("Không có đơn hàng nào"));
      }
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
    String validStatus = orderStatuses.contains(currentStatus) ? currentStatus : orderStatuses[0];

    return DropdownButton<String>(
        value: validStatus,
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