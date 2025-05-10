import 'package:app/luan/models/product_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:app/ui/admin/screens/product_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String token = "";
  late ApiAdminService apiAdminService;
  bool isLoading = false;
  List<ProductInfo> products = [];
  String? errorMessage;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> fetchProductsManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      final productsData = await apiAdminService.getAllProducts();
      setState(() {
        products = productsData;
        isLoading = false;
      });
    } catch (e) {
      errorMessage = "Không thể tải danh sách sản phẩm: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách sản phẩm: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());
    _loadUserData();
    fetchProductsManager();
  }

  String sortOption = "Mặc định";
  List<String> sortOptions = [
    "Mặc định",
    "A - Z",
    "Z - A",
  ];
  bool _showSortBar = true;
  bool _showSearchOptions = false;
  bool _showSearchField = false;
  String _searchType = "";
  final TextEditingController _searchController = TextEditingController();

  String formatCurrency(double amount) {
    return NumberFormat("#,###", "vi_VN").format(amount);
  }


  void _sortProducts() {
    setState(() {
      if (sortOption == "A - Z") {
        products.sort((a, b) => a.name!.compareTo(b.name!));
      } else if (sortOption == "Z - A") {
        products.sort((a, b) => b.name!.compareTo(a.name!));
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchProductsManager();
      } else {
        products = products.where((product) {
              if (_searchType == "category") {
                return product.fkCategory!.toLowerCase().contains(query.toLowerCase());
              } else if (_searchType == "brand") {
                return product.fkBrand!.toLowerCase().contains(query.toLowerCase()); 
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
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Thêm sản phẩm",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailScreen(
                    isEdit: false,
                    productInfo: null,
                  ),
            ),
          );
          await fetchProductsManager();
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
                            fetchProductsManager();
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
          // child: NotificationListener<ScrollNotification>(
          //   onNotification: (ScrollNotification scrollInfo) {
          //     if (!_showSearchField && scrollInfo is ScrollUpdateNotification) {
          //       if (scrollInfo.scrollDelta! > 0 && _showSortBar) {
          //         setState(() {
          //           _showSortBar = false;
          //         });
          //       } else if (scrollInfo.scrollDelta! < 0 && !_showSortBar) {
          //         setState(() {
          //           _showSortBar = true;
          //         });
          //       }
          //     }
          //     return true;
          //   },
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 100.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
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
                                _buildProductImage(product.mainImage),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mã: ${product.id}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        product.name ?? "Không có tên",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        "Loại: ${product.fkCategory ?? 'Không xác định'}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "Hãng: ${product.fkBrand ?? 'Không xác định'}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
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
                          top: 40,
                          right: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        isEdit: true,
                                        productInfo: product,
                                      ),
                                ),
                              );
                              await fetchProductsManager();
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
                  image: NetworkImage(imagePath),
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
