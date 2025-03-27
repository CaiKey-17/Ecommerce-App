import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class UpdateAddressScreen extends StatefulWidget {
  final String currentAddress;
  UpdateAddressScreen({required this.currentAddress});

  @override
  _UpdateAddressScreenState createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  TextEditingController _specificAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _specificAddressController.text = widget.currentAddress; 
  }

  /// Lấy danh sách tỉnh/thành
  Future<void> _fetchProvinces() async {
    final url = 'https://vn-public-apis.fpo.vn/provinces/getAll?limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _provinces = data['data']['data'];
        });
      } else {
        throw Exception('Không thể tải danh sách tỉnh/thành phố');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy tỉnh: $e');
    }
  }

  /// Lấy danh sách quận/huyện theo tỉnh
  Future<void> _fetchDistricts(String provinceCode) async {
    final url = 'https://vn-public-apis.fpo.vn/districts/getByProvince?provinceCode=$provinceCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districts = data['data']['data'];
          _wards.clear();
          _selectedDistrict = null;
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách quận/huyện');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy quận/huyện: $e');
    }
  }

  /// Lấy danh sách xã/phường theo quận
  Future<void> _fetchWards(String districtCode) async {
    final url = 'https://vn-public-apis.fpo.vn/wards/getByDistrict?districtCode=$districtCode&limit=-1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _wards = data['data']['data'];
          _selectedWard = null;
        });
      } else {
        throw Exception('Không thể tải danh sách xã/phường');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Lỗi khi lấy xã/phường: $e');
    }
  }

  /// Lưu địa chỉ và quay về màn hình trước
  void _saveAddress() {
  if (_selectedProvince == null || _selectedDistrict == null || _selectedWard == null) {
    Fluttertoast.showToast(msg: "Vui lòng chọn đầy đủ địa chỉ!");
    return;
  }

  // Tìm tên của tỉnh, quận, xã theo code đã chọn
  String provinceName = _provinces.firstWhere((p) => p['code'] == _selectedProvince)['name'];
  String districtName = _districts.firstWhere((d) => d['code'] == _selectedDistrict)['name'];
  String wardName = _wards.firstWhere((w) => w['code'] == _selectedWard)['name'];

  // Ghép lại thành địa chỉ hoàn chỉnh
  String newAddress = "${_specificAddressController.text}, $wardName, $districtName, $provinceName";

  Navigator.pop(context, newAddress); // Trả về PaymentConfirmationScreen
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật địa chỉ"),
        centerTitle: true,  // Căn giữa tiêu đề
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nhập địa chỉ cụ thể
            TextField(
              controller: _specificAddressController,
              decoration: InputDecoration(
                labelText: "Số nhà, tên đường...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown chọn tỉnh/thành
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              items: _provinces.map((province) {
                return DropdownMenuItem<String>(
                  value: province['code'],
                  child: Text(province['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value;
                  _fetchDistricts(value!);
                });
              },
              decoration: InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown chọn quận/huyện
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              items: _districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district['code'],
                  child: Text(district['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                  _fetchWards(value!);
                });
              },
              decoration: InputDecoration(
                labelText: 'Quận/Huyện',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown chọn xã/phường
            DropdownButtonFormField<String>(
              value: _selectedWard,
              items: _wards.map((ward) {
                return DropdownMenuItem<String>(
                  value: ward['code'],
                  child: Text(ward['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWard = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Xã/Phường',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 20),

            // Nút lưu
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text("Lưu địa chỉ"),
            ),
          ],
        ),
      ),
    );
  }
}
