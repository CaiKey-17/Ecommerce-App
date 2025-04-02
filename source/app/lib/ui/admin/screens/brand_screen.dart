import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart'; 

class BrandScreen extends StatefulWidget {
  @override
  _BrandScreenState createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<Map<String, String>> users = List.generate(
    10,
    (index) => {
      "id": "#U00$index",
      "name": "Loại $index",
      "image": "https://thanhnien.mediacdn.vn/Uploaded/haoph/2021_10_21/jack-va-thien-an-5805.jpeg", 
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý lthương hiệu")),
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
                backgroundImage: NetworkImage(user["image"]!),
                radius: 20,
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
      itemBuilder: (context) => [
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
    String imageUrl =
        isEdit ? users[userIndex!]["image"]! : "https://thanhnien.mediacdn.vn/Uploaded/haoph/2021_10_21/jack-va-thien-an-5805.jpeg";
    File? selectedImage; // Biến để lưu ảnh được chọn từ thiết bị

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                isEdit ? "Chỉnh sửa thương hiệu" : "Thêm thương hiệu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery, 
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        if (isEdit) {
                          users[userIndex!]["name"] = nameController.text;
                          if (selectedImage != null) {

                            users[userIndex]["image"] =
                                selectedImage!.path; 
                          }
                        } else {
                          users.add({
                            "id": id,
                            "name": nameController.text,
                            "image": selectedImage != null
                                ? selectedImage!.path 
                                : "https://thanhnien.mediacdn.vn/Uploaded/haoph/2021_10_21/jack-va-thien-an-5805.jpeg",
                          });
                        }
                      });
                      Navigator.pop(context);
                    }
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