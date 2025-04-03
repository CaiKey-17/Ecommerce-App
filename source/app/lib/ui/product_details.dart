import 'dart:math';

import 'package:app/globals/convert_money.dart';
import 'package:app/models/color_model.dart';
import 'package:app/models/image_model.dart';
import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/variant_model.dart';
import 'package:app/repositories/cart_repository.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/main_page.dart';
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

  int _currentIndex = 0;

  List<String> images = [];

  List<ColorOption> colors = [];
  List<Variant> versions = [];

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Huỳnh Hữu Thiện',
      'rating': 5,
      'content': 'Ad cho hỏi...',
      'likes': 16,
      'days': 7,
      'verified': true,
      'goodCount': 0,
      'badCount': 0,
    },
    {
      'name': 'L',
      'rating': 5,
      'content': 'Tôi có chụp ảnh...',
      'likes': 9,
      'days': 4,
      'verified': true,
      'goodCount': 0,
      'badCount': 0,
    },
    {
      'name': 'Nguyễn Văn A',
      'rating': 5,
      'content': 'Sản phẩm rất tuyệt...',
      'likes': 5,
      'days': 3,
      'verified': true,
      'goodCount': 0,
      'badCount': 0,
    },
    {
      'name': 'Bùi Bảo',
      'rating': 4,
      'content': 'Mình thấy ổn...',
      'likes': 2,
      'days': 1,
      'verified': false,
      'goodCount': 0,
      'badCount': 0,
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(
          child: Text(
            "Thông tin chi tiết",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(initialIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
                                autoPlayInterval: const Duration(seconds: 3),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '${_currentIndex + 1}/${images.length}',
                                  style: const TextStyle(
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thương hiệu: ${product?.brand}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8 (200 Đánh giá)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
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
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
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
                                                style: const TextStyle(
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
                                const SizedBox(height: 12),
                                const Text(
                                  'Chọn màu:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${ConvertMoney.currencyFormatter.format(colors[index].price)} đ",
                                                style: const TextStyle(
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
                                const SizedBox(height: 16),
                                Container(
                                  height: 60,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.grey[200],
                                  child: Text(
                                    "${ConvertMoney.currencyFormatter.format(price)} đ",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 16, 118, 201),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Thông tin chi tiết',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const SpecificationWidget(),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Mô tả sản phẩm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const DescriptionWidget(),
                                    const SizedBox(height: 10),
                                    ProductRatingWidget(
                                      productName: "Sản phẩm A",
                                      reviews: reviews,
                                      images: images,
                                      onViewMoreReviews: () {
                                        setState(() {
                                          // Hiển thị tất cả đánh giá
                                        });
                                      },
                                      onWriteReview:
                                          () => print('Viết đánh giá'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildTitle("Sản phẩm cùng hãng", () {
                                  print("Xem thêm được bấm!");
                                }),
                                const Divider(color: Colors.grey, thickness: 1),
                                const SizedBox(height: 10),
                                _buildListView(products_brand),
                                const SizedBox(height: 10),
                                _buildTitle("Sản phẩm liên quan ", () {
                                  print("Xem thêm được bấm!");
                                }),
                                const Divider(color: Colors.grey, thickness: 1),
                                const SizedBox(height: 10),
                                _buildListView(products_category),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
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
  const SpecificationWidget({super.key});

  final List<Map<String, String>> specifications = const [
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
      padding: const EdgeInsets.all(12),
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
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
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
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                    const Text(
                                      "Thông số chi tiết",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                                                    style: const TextStyle(
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
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
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
                  child: const Text(
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
  const DescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLongText = productDescription.length > 200;
    String shortDescription =
        isLongText
            ? "${productDescription.substring(0, 400)}..."
            : productDescription;

    return Container(
      padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 8),
              Text(shortDescription, style: const TextStyle(fontSize: 14)),
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
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                    const Text(
                                      "Chi tiết mô tả",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      productDescription,
                                      style: const TextStyle(fontSize: 14),
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
                  child: const Center(
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
              bottom: 30,
              height: 40,
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
  final List<String> images;
  final VoidCallback? onViewMoreReviews;
  final VoidCallback? onWriteReview;

  const ProductRatingWidget({
    super.key,
    required this.productName,
    required this.reviews,
    required this.images,
    this.onViewMoreReviews,
    this.onWriteReview,
  });

  @override
  _ProductRatingWidgetState createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget> {
  bool showAllReviews = false;
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var review in widget.reviews) {
      review['liked'] = false;
      review['disliked'] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedReviews =
        showAllReviews ? widget.reviews : widget.reviews.take(3).toList();
    double averageRating =
        widget.reviews.isEmpty
            ? 0
            : widget.reviews
                    .map((r) => r['rating'] as int)
                    .reduce((a, b) => a + b) /
                widget.reviews.length;
    int totalReviews = widget.reviews.length;
    int goodCount = widget.reviews.fold(
      0,
      (sum, r) => sum + (r['goodCount'] as int),
    );
    int badCount = widget.reviews.fold(
      0,
      (sum, r) => sum + (r['badCount'] as int),
    );
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
          const Text(
            'Đánh giá sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tốt: $goodCount',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Không tốt: $badCount',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
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
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc theo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterButton('Tất cả'),
                  const SizedBox(width: 7),
                  _buildFilterButton('Có hình ảnh'),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildStarRating(5),
                  const SizedBox(width: 7),
                  _buildStarRating(4),
                  const SizedBox(width: 7),
                  _buildStarRating(3),
                  const SizedBox(width: 7),
                  _buildStarRating(2),
                  const SizedBox(width: 7),
                  _buildStarRating(1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Column(
                children:
                    displayedReviews.map((review) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        review['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (review['verified'] as bool)
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
                                        i < (review['rating'] as int)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Text(review['content'] as String),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color:
                                        review['liked']
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (!review['liked']) {
                                        if (review['disliked']) {
                                          review['disliked'] = false;
                                          review['badCount'] =
                                              (review['badCount'] as int) - 1;
                                        }
                                        review['liked'] = true;
                                        review['goodCount'] =
                                            (review['goodCount'] as int) + 1;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_down,
                                    color:
                                        review['disliked']
                                            ? Colors.red
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (!review['disliked']) {
                                        if (review['liked']) {
                                          review['liked'] = false;
                                          review['goodCount'] =
                                              (review['goodCount'] as int) - 1;
                                        }
                                        review['disliked'] = true;
                                        review['badCount'] =
                                            (review['badCount'] as int) + 1;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              if (widget.reviews.length > 3 && !showAllReviews)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 60,
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
          // if (widget.reviews.length > 3 && !showAllReviews)
          //   Center(
          //     child: TextButton(
          //       onPressed: () {
          //         setState(() {
          //           showAllReviews = true;
          //         });
          //         widget.onViewMoreReviews?.call();
          //       },
          //       child: const Text(
          //         'Xem thêm',
          //         style: TextStyle(fontSize: 16, color: Colors.blue),
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16),
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
                                    const Text(
                                      "Tất cả đánh giá",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children:
                                          widget.reviews.map((review) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              review['name']
                                                                  as String,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            if (review['verified']
                                                                as bool)
                                                              const Icon(
                                                                Icons.verified,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                                size: 16,
                                                              ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: List.generate(
                                                            5,
                                                            (i) => Icon(
                                                              i <
                                                                      (review['rating']
                                                                          as int)
                                                                  ? Icons.star
                                                                  : Icons
                                                                      .star_border,
                                                              color:
                                                                  Colors.amber,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          review['content']
                                                              as String,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.thumb_up,
                                                          color:
                                                              review['liked']
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (!review['liked']) {
                                                              if (review['disliked']) {
                                                                review['disliked'] =
                                                                    false;
                                                                review['badCount'] =
                                                                    (review['badCount']
                                                                        as int) -
                                                                    1;
                                                              }
                                                              review['liked'] =
                                                                  true;
                                                              review['goodCount'] =
                                                                  (review['goodCount']
                                                                      as int) +
                                                                  1;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.thumb_down,
                                                          color:
                                                              review['disliked']
                                                                  ? Colors.red
                                                                  : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (!review['disliked']) {
                                                              if (review['liked']) {
                                                                review['liked'] =
                                                                    false;
                                                                review['goodCount'] =
                                                                    (review['goodCount']
                                                                        as int) -
                                                                    1;
                                                              }
                                                              review['disliked'] =
                                                                  true;
                                                              review['badCount'] =
                                                                  (review['badCount']
                                                                      as int) +
                                                                  1;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
                child: const Text('Xem đánh giá'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => ReviewDialog(
                          productName: widget.productName,
                          images: widget.images,
                          onSubmit: (rating, comment) {
                            setState(() {
                              widget.reviews.add({
                                'name': 'Người dùng mới',
                                'rating': rating,
                                'content': comment,
                                'likes': 0,
                                'days': 0,
                                'verified': false,
                                'goodCount': 0,
                                'badCount': 0,
                                'liked': false,
                                'disliked': false,
                              });
                            });
                            print('Đánh giá: $rating sao - $comment');
                          },
                        ),
                  );
                },
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

class ReviewDialog extends StatefulWidget {
  final String productName;
  final List<String> images;
  final Function(int rating, String comment) onSubmit;

  const ReviewDialog({
    super.key,
    required this.productName,
    required this.images,
    required this.onSubmit,
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.images.isNotEmpty
                  ? widget.images[0]
                  : 'https://via.placeholder.com/150',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            if (selectedRating > 0)
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Nhập đánh giá của bạn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
            // const SizedBox(height: 10),
            // if (selectedRating > 0)
            //   GestureDetector(
            //     onTap: () {
            //       print('Tải ảnh thực tế');
            //     },
            //     child: Container(
            //       height: 50,
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Colors.grey),
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Center(child: Text('Thêm ảnh thực tế')),
            //     ),
            //   ),
            const SizedBox(height: 10),
            if (selectedRating > 0)
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    widget.onSubmit(selectedRating, _commentController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Gửi đánh giá'),
              ),
          ],
        ),
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
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
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

Widget _buildListView(List<ProductInfo> products) {
  return Container(
    height: 400,
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final int rating = Random().nextInt(3) + 3;

        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: 8),
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
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${ConvertMoney.currencyFormatter.format(product.price)} đ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Row(
                        children: [
                          Text(
                            "${ConvertMoney.currencyFormatter.format(product.oldPrice)} đ",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "- ${product.discountPercent}%" ?? "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8),
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
                      side: const BorderSide(color: Colors.blue, width: 1),
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      GestureDetector(
        onTap: onViewMore,
        child: const Text(
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
