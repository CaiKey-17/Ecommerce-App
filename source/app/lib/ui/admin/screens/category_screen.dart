import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, String>> users = List.generate(
    10,
    (index) => {
      "id": "#U00$index",
      "name": "Thương hiệu $index",
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý thương hiệu")),
      drawer: SideBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUserList(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm thương hiệu",
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
          ),
        ),

        onPressed: () => _showUserDialog(context, isEdit: false),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      user["id"]!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user["name"]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  ],
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
        if (value == 'edit') {
          _showUserDialog(
            context,
            isEdit: true,
            userIndex: userIndex,
          );
        } else if (value == 'delete') {
          _confirmDeleteUser(context, userIndex);
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
      icon: Icon(Icons.more_vert, color: Colors.grey[700]),
    );
  }

  void _showUserDialog(
    BuildContext context, {
    required bool isEdit,
    int? userIndex,
  }) {
    String id = isEdit ? users[userIndex!]["id"]! : "#U00${users.length}";
    TextEditingController nameController = TextEditingController(
      text: isEdit ? users[userIndex!]["name"] : "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Chỉnh sửa thương hiệu",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, 
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "ID thương hiệu",
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: id),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                enabled: false,
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Tên thương hiệu",
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black54),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Đóng",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                if (isEdit) {
                  setState(() {
                    users[userIndex!]["name"] = nameController.text;
                  });
                } else {
                  setState(() {
                    users.add({
                      "id": id,
                      "name": nameController.text,
                    });
                  });
                }
                Navigator.pop(context); 
              },
              child: Text(
                "Xong",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
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
}
