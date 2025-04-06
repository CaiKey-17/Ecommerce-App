import 'package:flutter/material.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  List<Map<String, dynamic>> addresses = [
    {
      'specificAddress': 'Số 87, Đường Số 1',
      'location': 'Xã Phường Bình Thuận, Huyện Quận 7, Tỉnh TP. Hồ Chí Minh',
      'isDefault': 'false',
      'isCurrentDefault': false,
    },
    {
      'specificAddress': 'Giấy đẹp Cao Minh - Đối diện chợ Sơn Hà',
      'location': 'Xã Sơn Hà, Huyện Sơn Hà, Tỉnh Quảng Ngãi',
      'isDefault': 'false',
      'isCurrentDefault': false,
    },
    {
      'specificAddress': 'Đại Học Tôn Đức Thắng, 19 Đ.Nguyễn Hữu Thọ',
      'location': 'Xã Phường Tân Phong, Huyện Quận 7, Tỉnh TP. Hồ Chí Minh',
      'isDefault': 'false',
      'isCurrentDefault': false,
    },
  ];

  void _addNewAddress(Map<String, dynamic> newAddress) {
    setState(() {
      addresses.add({...newAddress, 'isCurrentDefault': false});
    });
  }

  void _setDefaultAddress() {
    setState(() {
      final selectedAddressIndex = addresses.indexWhere(
        (address) => address['isDefault'] == 'true',
      );

      if (selectedAddressIndex != -1) {
        for (var address in addresses) {
          address['isCurrentDefault'] = false;
        }
        addresses[selectedAddressIndex]['isCurrentDefault'] = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn một địa chỉ để đặt làm mặc định'),
          ),
        );
      }
    });
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
          'Địa chỉ của Tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.star, color: Colors.white),
            onPressed: _setDefaultAddress,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'ĐỊA CHỈ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['specificAddress'] ??
                                  'Không có địa chỉ chi tiết',
                              style: TextStyle(color: Colors.black87),
                            ),
                            SizedBox(height: 2),
                            Text(
                              address['location'] ?? 'Không có địa điểm',
                              style: TextStyle(color: Colors.black87),
                            ),
                            if (address['isCurrentDefault'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Mặc định',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: address['isDefault'] == 'true',
                          onChanged: (value) {
                            setState(() {
                              for (var addr in addresses) {
                                addr['isDefault'] = 'false';
                              }
                              address['isDefault'] = value.toString();
                            });
                          },
                          activeTrackColor: Colors.blue,
                          activeColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade300,
                          inactiveThumbColor: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAddressScreen()),
                  );
                  if (newAddress != null) {
                    _addNewAddress(newAddress);
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: Colors.red),
                label: Text(
                  'Thêm Địa Chỉ Mới',
                  style: TextStyle(color: Colors.red),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.red),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
