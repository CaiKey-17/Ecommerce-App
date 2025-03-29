import 'dart:math';

import 'package:app/models/color_model.dart';
import 'package:app/models/image_model.dart';
import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/variant_model.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/main_page.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  final int productId;

  const ProductPage({super.key, required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late ApiService apiService;
  int selectedColorIndex = 0;
  int selectedVersionIndex = 0;
  String name = "";
  double? price;

  double basePrice = 1990000;
  int _currentIndex = 0;

  List<String> images = [];

  List<ColorOption> colors = [];
  List<Variant> versions = [];
  final List<double> priceModifiers = [0, 200000, 500000];

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Huỳnh Hữu Thiện',
      'rating': 5,
      'content': 'Ad cho hỏi...',
      'likes': 16,
      'days': 7,
      'verified': true,
    },
    {
      'name': 'L',
      'rating': 5,
      'content': 'Tôi có chụp ảnh...',
      'likes': 9,
      'days': 4,
      'verified': true,
    },
    {
      'name': 'Nguyễn Văn A',
      'rating': 5,
      'content': 'Sản phẩm rất tuyệt...',
      'likes': 5,
      'days': 3,
      'verified': true,
    },
    {
      'name': 'Bùi Bảo',
      'rating': 4,
      'content': 'Mình thấy ổn...',
      'likes': 2,
      'days': 1,
      'verified': false,
    },
  ];

  bool isLoading = true;
  Product? product;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());
    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
    fetchProductDetail();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> fetchProductDetail() async {
    try {
      final response = await apiService.getProductDetail(widget.productId);
      setState(() {
        product = response;
        for (ProductImage i in product!.images) {
          images.add(i.image);
        }
        versions = product!.variants;
        if (versions.isNotEmpty) {
          selectedVersionIndex = 0;
          name = versions[0].name;
          colors = versions[0].colors;

          if (colors.isNotEmpty) {
            selectedColorIndex = 0;
            price = colors[0].price;
            for (ColorOption i in colors) {
              images.add(i.image);
            }
          } else {
            selectedColorIndex = -1;
            price = versions[0].price;
          }
        }
        fetchProductsBrand(product!.brand);
        fetchProductsCategory(product!.category);
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsBrand(String brand) async {
    try {
      final response = await apiService.getProductsByBrand(brand);
      setState(() {
        for (ProductInfo i in response) {
          if (i.id != widget.productId) {
            products_brand.add(i);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProductsCategory(String category) async {
    try {
      final response = await apiService.getProductsByCategory(category);
      setState(() {
        for (ProductInfo i in response) {
          if (i.id != widget.productId) {
            products_category.add(i);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            "Thông tin chi tiết",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(initialIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: images.length,
                              itemBuilder: (context, index, realIndex) {
                                return Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(images[index]),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 250,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 3),
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 15,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '${_currentIndex + 1}/${images.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Thương hiệu: ${product?.brand}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < 4
                                              ? Icons.star
                                              : Icons.star_half,
                                          color: Colors.amber,
                                          size: 18,
                                        );
                                      }),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.8 (200 Đánh giá)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(versions.length, (
                                    index,
                                  ) {
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedVersionIndex = index;
                                            name = versions[index].name;
                                            colors = versions[index].colors;

                                            if (colors.isNotEmpty) {
                                              selectedColorIndex = 0;
                                              price = colors[0].price;
                                            } else {
                                              selectedColorIndex = -1;
                                              price = versions[index].price;
                                            }
                                          });
                                        },

                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedVersionIndex == index
                                                      ? Colors.blue
                                                      : Colors.grey,
                                              width:
                                                  selectedVersionIndex == index
                                                      ? 2
                                                      : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                versions[index].name,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Chọn màu:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(colors.length, (
                                    index,
                                  ) {
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (colors.isNotEmpty) {
                                            setState(() {
                                              selectedColorIndex = index;
                                              price = colors[index].price;
                                            });
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  selectedColorIndex == index
                                                      ? Colors.blue
                                                      : Colors.grey,
                                              width:
                                                  selectedColorIndex == index
                                                      ? 2
                                                      : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                colors[index].nameColor,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${(colors[index].price).toStringAsFixed(0)}đ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 60,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.grey[200],
                                  child: Text(
                                    price.toString(),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        16,
                                        118,
                                        201,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin chi tiết',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    SpecificationWidget(),
                                    SizedBox(height: 10),
                                    Text(
                                      'Mô tả sản phẩm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    DescriptionWidget(),
                                    SizedBox(height: 10),
                                    ProductRatingWidget(
                                      productName: "Sản phẩm A",
                                      reviews: reviews,
                                      onViewMoreReviews:
                                          () => print('Xem thêm đánh giá'),
                                      onWriteReview:
                                          () => print('Viết đánh giá'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                _buildTitle("Sản phẩm cùng hãng", () {
                                  print("Xem thêm được bấm!");
                                }),
                                Divider(color: Colors.grey, thickness: 1),
                                SizedBox(height: 10),

                                _buildListView(products_brand),
                                SizedBox(height: 10),

                                _buildTitle("Sản phẩm liên quan ", () {
                                  print("Xem thêm được bấm!");
                                }),
                                Divider(color: Colors.grey, thickness: 1),
                                SizedBox(height: 10),

                                _buildListView(products_category),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // cartService.addToCart(
                  //   productID: versions[index].id,
                  //   colorId: product.idColor,
                  //   id: product.id,
                  //   token: token,
                  //   context: context,
                  // );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Mua ngay',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecificationWidget extends StatelessWidget {
  final List<Map<String, String>> specifications = [
    {"title": "Thông số kỹ thuật"},
    {"CPU": "Snapdragon 8 Gen 2"},
    {"RAM": "12GB"},
    {"title": "Màn hình"},
    {"Kích thước": "6.8 inch"},
    {"Độ phân giải": "1440 x 3200 pixels"},
    {"title": "Camera"},
    {"Camera chính": "50MP"},
    {"Camera trước": "32MP"},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredSpecs =
        specifications
            .where((spec) => !spec.keys.first.toLowerCase().contains("title"))
            .toList();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...filteredSpecs.take(5).map((spec) {
                String key = spec.keys.first;
                String value = spec.values.first;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(value, style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.95,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Thông số chi tiết",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: specifications.length,
                                    itemBuilder: (context, index) {
                                      Map<String, String> spec =
                                          specifications[index];
                                      String key = spec.keys.first;
                                      String value = spec.values.first;
                                      bool isTitle = key.toLowerCase().contains(
                                        "title",
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child:
                                            isTitle
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10,
                                                        bottom: 5,
                                                      ),
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                                : Container(
                                                  color:
                                                      index % 2 == 0
                                                          ? Colors.grey[100]
                                                          : Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          key,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                          value,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
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
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "Xem thêm",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String productDescription =
    "Bạn đang cần tìm màn hình hiển thị sắc nét, hiệu năng vượt trội với mức giá hợp lý? "
    "Màn hình MSI PRO MP242L với kích thước 24 inch (23.8 inch) chính là sự lựa chọn hoàn hảo đến từ thương hiệu uy tín. "
    "Được trang bị độ phân giải Full HD, tấm nền IPS cao cấp và tần số quét 100Hz, thiết bị không chỉ mang lại trải nghiệm hình ảnh sống động "
    "mà còn hỗ trợ bảo vệ thị lực tối ưu cho người dùng. Hãy cùng khám phá các thông tin nổi bật của loại màn hình này nhé!\n\n"
    "Màn hình MSI PRO MP242L 23.8 inch nổi bật với thiết kế thanh lịch và kích thước (không chân) 542 x 28 x 321 mm, khối lượng 2kg và kích thước "
    "(có chân) 542 x 174 x 391 mm, khối lượng 3.5kg dễ dàng phù hợp với mọi không gian sử dụng văn phòng. Với viền mỏng 3 cạnh hiện đại, tỷ lệ khung hình 16:9 "
    "không chỉ tối ưu không gian hiển thị mà còn mang lại vẻ đẹp tinh tế, nâng tầm thẩm mỹ cho góc làm việc hay giải trí. Phần mặt sau được tô điểm bởi các họa tiết "
    "tạo điểm nhấn độc đáo và đầy cảm hứng. Thiết kế tối giản này tạo điều kiện thuận lợi khi thiết lập đa màn hình, đáp ứng linh hoạt nhu cầu sử dụng.";

class DescriptionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isLongText = productDescription.length > 200;
    String shortDescription =
        isLongText
            ? productDescription.substring(0, 400) + "..."
            : productDescription;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(shortDescription, style: TextStyle(fontSize: 14)),
              if (isLongText)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.9,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Chi tiết mô tả",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      productDescription,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      "Xem thêm",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (isLongText)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30, // Điều chỉnh vị trí gradient
              height: 40, // Điều chỉnh chiều cao của hiệu ứng mờ
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.7),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductRatingWidget extends StatefulWidget {
  final String productName;
  final List<Map<String, dynamic>> reviews;
  final VoidCallback? onViewMoreReviews;
  final VoidCallback? onWriteReview;

  const ProductRatingWidget({
    super.key,
    required this.productName,
    required this.reviews,
    this.onViewMoreReviews,
    this.onWriteReview,
  });

  @override
  _ProductRatingWidgetState createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget> {
  bool showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedReviews =
        showAllReviews ? widget.reviews : widget.reviews.take(3).toList();
    double averageRating =
        widget.reviews.isEmpty
            ? 0
            : widget.reviews.map((r) => r['rating']).reduce((a, b) => a + b) /
                widget.reviews.length;
    int totalReviews = widget.reviews.length;
    String satisfactionText =
        averageRating >= 4
            ? 'Rất tốt'
            : (averageRating >= 3 ? 'Tốt' : 'Trung bình');
    Map<int, double> ratingPercentages = {
      5: 0.7,
      4: 0.2,
      3: 0.05,
      2: 0.03,
      1: 0.02,
    };

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá sản phẩm',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const Text('/5', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  Text(
                    '$satisfactionText ',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    '( $totalReviews đánh giá )',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(5, (index) {
                    int star = 5 - index;
                    double percentage = ratingPercentages[star] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text(
                              '$star',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const Icon(Icons.star, size: 15, color: Colors.amber),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.blue,
                                ),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${(percentage * 100).round()}%',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey, thickness: 1),

          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc theo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterButton('Tất cả'),
                  SizedBox(width: 7),
                  _buildFilterButton('Có hình ảnh'),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildStarRating(5),
                  SizedBox(width: 7),

                  _buildStarRating(4),
                  SizedBox(width: 7),

                  _buildStarRating(3),
                  SizedBox(width: 7),

                  _buildStarRating(2),
                  SizedBox(width: 7),

                  _buildStarRating(1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children:
                displayedReviews.map((review) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (review['verified'])
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 16,
                              ),
                          ],
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(review['content']),
                      ],
                    ),
                  );
                }).toList(),
          ),
          if (widget.reviews.length > 3)
            Center(
              child: TextButton(
                onPressed: widget.onViewMoreReviews,
                child: const Text(
                  'Xem thêm',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: widget.onViewMoreReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
                child: const Text('Xem 10 đánh giá'),
              ),
              ElevatedButton(
                onPressed: widget.onWriteReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Viết đánh giá'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildFilterButton(String text) {
  return ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(text),
  );
}

Widget _buildStarRating(int stars) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: Colors.grey),
      borderRadius: BorderRadius.circular(20),
    ),
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: Row(
      children: [
        Text('$stars', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Icon(Icons.star, color: Colors.yellow[700], size: 15),
      ],
    ),
  );
}

List<ProductInfo> products_brand = [];
List<ProductInfo> products_category = [];
late CartRepository cartRepository;
late CartService cartService;
String token = "";

// final List<Map<String, dynamic>> products = List.generate(
//   10,
//   (index) => {
//     "image": "assets/images/laptop.webp",
//     "discountLabel": "TIẾT KIỆM\n700.000 đ",
//     "name": "ADATA",
//     "description":
//         "Ram Desktop ADATA XPG D50 DDR4 16GB (1x16GB) 3200 RGB Grey...",
//     "price": "990.000 đ",
//     "oldPrice": "1.690.000 đ",
//     "discountPercent": "-41,42%",
//   },
// );

Widget _buildListView(List<ProductInfo> products) {
  return Container(
    height: 400,
    child: ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final int rating = Random().nextInt(3) + 3;

        return Container(
          width: 180,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.network(
                        product.image,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          product.oldPrice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          product.discountPercent,
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      cartService.addToCart(
                        productID: product.idVariant,
                        colorId: product.idColor,
                        id: product.id,
                        token: token,
                        context: context,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 1),
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Thêm giỏ hàng",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildTitle(String title, VoidCallback onViewMore) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      GestureDetector(
        onTap: onViewMore,
        child: Text(
          "Xem thêm",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        ),
      ),
    ],
  );
}
