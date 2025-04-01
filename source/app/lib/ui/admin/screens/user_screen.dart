import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sidebar.dart';
import '../screens/user_detail_screen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<Map<String, String>> users = List.generate(
    10,
    (index) => {
      "id": "#U00$index",
      "name": "Người dùng $index",
      "email": "user$index@email.com",
      "phone": "1232481292",
      "address": "Địa chỉ $index",
      "isBlocked": "false" // Thêm trạng thái block
    },
  );

  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _address = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý người dùng")),
      drawer: SideBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: _buildUserList(context))],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm người dùng",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          _showAddUserDialog(context);
        },
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  user["id"]!.substring(3),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user["name"]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user["email"]!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user["phone"]!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (user["phone"] != null) {
                    _makePhoneCall(user["phone"]!);
                  } else {
                    print("Số điện thoại không tồn tại");
                  }
                },
                icon: Icon(Icons.call, color: Colors.blue),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    users[index]["isBlocked"] =
                        (users[index]["isBlocked"] == "true") ? "false" : "true";
                  });
                },
                icon: Icon(
                  users[index]["isBlocked"] == "true"
                      ? Icons.lock
                      : Icons.lock_open,
                  color: users[index]["isBlocked"] == "true"
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              _buildPopupMenu(context, index),
            ],
          ),
        );
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        print('Không thể mở URL: $phoneUri');
      }
    } else {
      print("Quyền gọi điện bị từ chối.");
    }
  }

  Widget _buildPopupMenu(BuildContext context, int userIndex) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'view') {
          List<Map<String, dynamic>> orders = List.generate(
            5,
            (index) => {
              "id": "#O00$index",
              "name": "Đơn hàng $index",
              "address": "Địa chỉ $index",
              "quantity": index + 1,
              "price": (index + 1) * 10000,
              "ship": 20000,
              "total": (index + 1) * 10000 + 20000,
              "status": "Chấp nhận",
            },
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserDetailsScreen(user: users[userIndex], orders: orders),
            ),
          );
        } else if (value == 'delete') {
          _confirmDeleteUser(context, userIndex);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'view', child: Text('Xem thông tin')),
        PopupMenuItem(
            value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
      ],
      icon: Icon(Icons.more_vert, color: Colors.grey[700]),
    );
  }

  void _confirmDeleteUser(BuildContext context, int userIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa ${users[userIndex]["name"]} không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  users.removeAt(userIndex);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thêm người dùng mới'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Họ và tên'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _fullName = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Địa chỉ'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _address = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mật khẩu'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Xong', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    users.add({
                      "id": "#U00${users.length}",
                      "name": _fullName,
                      "email": _email,
                      "phone": "Chưa có",
                      "address": _address,
                      "isBlocked": "false",
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }
}