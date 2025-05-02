import 'package:app/ui/admin/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String token = "";

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeProducts();
  }

  List<Map<String, dynamic>> products = [];
  List<String> categories = ["Điện thoại", "Laptop", "Phụ kiện", "Khác"];
  int productCounter = 1;
  String sortOption = "Mặc định";
  List<String> sortOptions = [
    "Mặc định",
    "A - Z",
    "Z - A",
    "Giá tăng",
    "Giá giảm",
  ];
  bool _showSortBar = true;
  bool _showSearchOptions = false;
  bool _showSearchField = false;
  String _searchType = "";
  final TextEditingController _searchController = TextEditingController();

  void _initializeProducts() {
    for (int i = 0; i < 5; i++) {
      _addProduct(
        "Sản phẩm $i",
        "1000000",
        "10",
        "null",
        "Điện thoại",
        "Apple",
        0,
      );
    }
  }

  String formatCurrency(double amount) {
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  void _addProduct(
    String name,
    String price,
    String quantity,
    String? image,
    String category,
    String brand,
    double discount,
  ) {
    setState(() {
      products.add({
        "id": "#00$productCounter",
        "name": name,
        "price": double.parse(price),
        "quantity": int.parse(quantity),
        "category": category,
        "brand": brand,
        "discount": discount,
        "image": image,
      });
      productCounter++;
    });
  }

  void _sortProducts() {
    setState(() {
      if (sortOption == "A - Z") {
        products.sort((a, b) => a["name"].compareTo(b["name"]));
      } else if (sortOption == "Z - A") {
        products.sort((a, b) => b["name"].compareTo(a["name"]));
      } else if (sortOption == "Giá tăng") {
        products.sort((a, b) => a["price"].compareTo(b["price"]));
      } else if (sortOption == "Giá giảm") {
        products.sort((a, b) => b["price"].compareTo(a["price"]));
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _initializeProducts(); // Reset danh sách nếu không có query
      } else {
        products =
            products.where((product) {
              if (_searchType == "category") {
                return product["category"].toLowerCase().contains(
                  query.toLowerCase(),
                );
              } else if (_searchType == "brand") {
                return product["brand"].toLowerCase().contains(
                  query.toLowerCase(),
                ); // Sửa từ "name" thành "brand"
              }
              return true;
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(token: token),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Quản lý sản phẩm",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [Expanded(child: _buildProductList())]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailScreen(
                    isEdit: false,
                    onSave: (product) {
                      _addProduct(
                        product["name"],
                        product["price"].toString(),
                        product["quantity"].toString(),
                        product["image"],
                        product["category"],
                        product["brand"],
                        product["discount"],
                      );
                    },
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        if (_showSortBar && !_showSearchField)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: sortOption,
                  items:
                      sortOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        sortOption = newValue;
                        _sortProducts();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.blue.shade700),
                  onPressed: () {
                    setState(() {
                      _showSearchOptions = !_showSearchOptions;
                    });
                  },
                ),
              ],
            ),
          ),
        if (_showSearchOptions && !_showSearchField)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSearchField = true;
                      _showSortBar = false;
                      _showSearchOptions = false;
                      _searchType = "category";
                      _searchController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                  ),
                  child: Text("Tìm kiếm theo loại"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSearchField = true;
                      _showSortBar = false;
                      _showSearchOptions = false;
                      _searchType = "brand";
                      _searchController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                  ),
                  child: Text("Tìm kiếm theo hãng"),
                ),
              ],
            ),
          ),
        if (_showSearchField)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          _searchType == "category"
                              ? "Nhập loại sản phẩm..."
                              : "Nhập hãng sản phẩm...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _showSearchField = false;
                            _showSortBar = true;
                            _searchController.clear();
                            _initializeProducts();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _filterProducts(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_showSearchField && scrollInfo is ScrollUpdateNotification) {
                if (scrollInfo.scrollDelta! > 0 && _showSortBar) {
                  setState(() {
                    _showSortBar = false;
                  });
                } else if (scrollInfo.scrollDelta! < 0 && !_showSortBar) {
                  setState(() {
                    _showSortBar = true;
                  });
                }
              }
              return true;
            },
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                double finalPrice =
                    product["price"] * (1 - product["discount"] / 100);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1.5,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProductImage(product["image"]),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mã: ${product["id"]}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        product["name"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        "Loại: ${product["category"]}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "Hãng: ${product["brand"]}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Giá: ${formatCurrency(product["price"])} VNĐ",
                            ),
                            if (product["discount"] > 0)
                              Text(
                                "Giảm giá: ${product["discount"]}%",
                                style: TextStyle(color: Colors.red),
                              ),
                            Row(
                              children: [
                                Text(
                                  "Giá sau giảm: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${formatCurrency(finalPrice)} VNĐ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Text("Tồn kho: ${product["quantity"]}"),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                products.removeAt(index);
                              });
                            },
                          ),
                        ),
                        Positioned(
                          top: 60,
                          right: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        isEdit: true,
                                        product: product,
                                        productIndex: index,
                                        onSave: (updatedProduct) {
                                          setState(() {
                                            products[index] = updatedProduct;
                                          });
                                        },
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String? imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        image:
            imagePath != null
                ? DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )
                : DecorationImage(
                  image: AssetImage(
                    'https://thanhnien.mediacdn.vn/Uploaded/haoph/2021_10_21/jack-va-thien-an-5805.jpeg',
                  ),
                  fit: BoxFit.cover,
                ),
      ),
    );
  }
}
