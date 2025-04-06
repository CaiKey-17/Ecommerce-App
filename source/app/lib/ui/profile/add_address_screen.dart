import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Controller cho các trường nhập liệu
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Biến trạng thái cho switch
  bool _isDefaultAddress = false;

  // Loại địa chỉ (Văn Phòng hoặc Nhà Riêng)
  String _addressType = 'Văn Phòng';

  // Danh sách Tỉnh, Huyện, Xã
  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  // Giá trị được chọn
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  // Code của Tỉnh và Huyện để gọi API
  String? _selectedProvinceCode;
  String? _selectedDistrictCode;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Lấy danh sách tỉnh/thành phố
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
    final url =
        'https://vn-public-apis.fpo.vn/districts/getByProvince?provinceCode=$provinceCode&limit=-1';
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

  /// Lấy danh sách xã/phường theo quận/huyện
  Future<void> _fetchWards(String districtCode) async {
    final url =
        'https://vn-public-apis.fpo.vn/wards/getByDistrict?districtCode=$districtCode&limit=-1';
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

  // Hàm lưu địa chỉ
  void _saveAddress() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null) {
      Fluttertoast.showToast(msg: 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    // Định dạng số điện thoại thành (+84)
    String formattedPhone = _phoneController.text;
    if (!formattedPhone.startsWith('(+84)')) {
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = formattedPhone.substring(1);
      }
      formattedPhone = '(+84) $formattedPhone';
    }

    // Định dạng location thành "Xã ..., Huyện ..., Tỉnh ..."
    final formattedLocation =
        'Xã $_selectedWard, Huyện $_selectedDistrict, Tỉnh $_selectedProvince';

    // Tạo đối tượng địa chỉ mới
    final newAddress = {
      'name': _nameController.text,
      'phone': formattedPhone,
      'specificAddress': _addressController.text,
      'location': formattedLocation,
      'isDefault': _isDefaultAddress.toString(),
    };

    Navigator.pop(context, newAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Địa chỉ mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.blue, // Màu xanh biển
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Địa chỉ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tỉnh/Thành phố',
                  border: OutlineInputBorder(),
                ),
                value: _selectedProvince,
                hint: Text('Chọn Tỉnh/Thành phố'),
                items:
                    _provinces.map<DropdownMenuItem<String>>((province) {
                      return DropdownMenuItem<String>(
                        value: province['name'],
                        child: Text(province['name']),
                        onTap: () {
                          _selectedProvinceCode = province['code'];
                        },
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvince = value;
                    _districts.clear();
                    _wards.clear();
                    _selectedDistrict = null;
                    _selectedWard = null;
                  });
                  if (_selectedProvinceCode != null) {
                    _fetchDistricts(_selectedProvinceCode!);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Quận/Huyện',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDistrict,
                hint: Text('Chọn Quận/Huyện'),
                items:
                    _districts.map<DropdownMenuItem<String>>((district) {
                      return DropdownMenuItem<String>(
                        value: district['name'],
                        child: Text(district['name']),
                        onTap: () {
                          _selectedDistrictCode = district['code'];
                        },
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                    _wards.clear();
                    _selectedWard = null;
                  });
                  if (_selectedDistrictCode != null) {
                    _fetchWards(_selectedDistrictCode!);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Phường/Xã',
                  border: OutlineInputBorder(),
                ),
                value: _selectedWard,
                hint: Text('Chọn Phường/Xã'),
                items:
                    _wards.map<DropdownMenuItem<String>>((ward) {
                      return DropdownMenuItem<String>(
                        value: ward['name'],
                        child: Text(ward['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWard = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Tên đường, Tòa nhà, Số nhà.',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text(
                  'HOÀN THÀNH',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
