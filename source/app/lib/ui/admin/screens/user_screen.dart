import 'package:app/luan/models/user_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sidebar.dart';
import '../screens/user_detail_screen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String token = "";

  bool isLoading = false;
  List<UserInfo> users = [];
  late ApiAdminService apiAdminService;

  Future<void> fetchUsersManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      final usersData = await apiAdminService.getAllUsers();

       print("API response: ${usersData.toString()}");
      setState(() {
        users = usersData;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách người dùng: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());
    _loadUserData();
    fetchUsersManager();
  }

  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _address = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý người dùng",
           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      drawer: SideBar(token: token),
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
                backgroundImage: user.image.isNotEmpty
                    ? NetworkImage(user.image)  
                    : null,  
                child: user.image.isEmpty
                    ? Text(
                        user.id.toString(),
                        style: TextStyle(color: Colors.white),
                      )
                    : null,  
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await apiAdminService.toggleUserActive(user.id);
                    await fetchUsersManager(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã cập nhật trạng thái người dùng")),
                    );
                  } catch (e) {
                    print("Lỗi khi cập nhật trạng thái: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi khi cập nhật trạng thái người dùng")),
                    );
                  }
                },
                icon: Icon(
                  user.active  != 1 ? Icons.lock : Icons.lock_open,
                  color: user.active != 1 ? Colors.red : Colors.green,
                ),
              ),

              _buildPopupMenu(context, index),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, int userIndex) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'view') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      UserDetailsScreen(user: users[userIndex]),
            ),
          );
        } else if (value == 'delete') {
          _confirmDeleteUser(context, userIndex);
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 'view', child: Text('Xem thông tin')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
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
            "Bạn có chắc muốn xóa ${users[userIndex].fullName} không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
            onPressed: () async {
              try {
                await apiAdminService.deleteUser(users[userIndex].id);
                setState(() {
                  users.removeAt(userIndex);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Xóa người dùng thành công")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa người dùng: $e")),
                );
                Navigator.pop(context);
              }
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
            // ElevatedButton(
            //   child: Text('Xong', style: TextStyle(color: Colors.white)),
            //   onPressed: () {
            //     if (_formKey.currentState!.validate()) {
            //       _formKey.currentState!.save();
            //       setState(() {
            //         users.add({
            //           "id": "#U00${users.length}",
            //           "name": _fullName,
            //           "email": _email,
            //           "phone": "Chưa có",
            //           "address": _address,
            //           "isBlocked": "false",
            //         });
            //       });
            //       Navigator.of(context).pop();
            //     }
            //   },
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            // ),
          ],
        );
      },
    );
  }
}
