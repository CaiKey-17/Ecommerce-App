import 'dart:convert';
import 'dart:io';
import 'package:app/globals/ip.dart';
import 'package:app/ui/product/main_category.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploader {
  final BuildContext context;
  final Function(String result) onResult;
  File? _image;

  ImageUploader({required this.context, required this.onResult});

  Future<void> pickImageAndUpload() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.baseUrlDetect),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      var res = await request.send();
      var response = await http.Response.fromStream(res);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> objects = jsonResponse["objects"];

        Map<String, String> translationMap = {
          "laptop": "Laptop",
          "cell phone": "Điện thoại",
          "keyboard": "Bàn phím",
          "mouse": "Chuột",
          "tv": "Tivi",
          "monitor": "Màn hình",
          "computer": "PC - Máy tính",
        };

        String filteredResult = objects
            .where((obj) => obj["confidence"] > 0.7)
            .map((obj) => translationMap[obj["label"]] ?? obj["label"])
            .join(", ");

        if (filteredResult.isNotEmpty) {
          onResult(filteredResult);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CategoryPage(selectedCategory: filteredResult),
            ),
          );
        } else {
          showToast("Không có thiết bị nào nhận diện được !");
        }
      } else {
        showToast("Lỗi nhận diện!");
      }
    } catch (e) {
      showToast("Đã xảy ra lỗi kết nối!");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
