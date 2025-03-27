import 'dart:math';

import 'package:app/data/banner.dart';
import 'package:app/models/product_info.dart';
import 'package:app/services/cart_service.dart';
import 'package:app/ui/main_category.dart';
import 'package:app/ui/product_details.dart';
import 'package:app/ui/search_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/category_info.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/cart_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CartRepository cartRepository;
  late CartService cartService;
  late ApiService apiService;
  static const _pageSize = 5;
  bool isLoading = true;
  bool isCollapsed = false;
  String fullName = "";
  int points = 0;
  bool _isFetching = false;
  bool _isLoading = true;
  int _currentIndex = 0;
  String formattedPoints = "";
  String token = "";
  List<CategoryInfo> categories = [];
  List<ProductInfo> products = [];

  final PagingController<int, ProductInfo> _pagingController = PagingController(
    firstPageKey: 0,
  );

  final PagingController<int, ProductInfo> _pagingController2 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController3 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController4 =
      PagingController(firstPageKey: 0);

  final PagingController<int, ProductInfo> _pagingController5 =
      PagingController(firstPageKey: 0);

  late ScrollController _scrollController;
  late ScrollController _scrollController1;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      points = prefs.getInt('points') ?? 0;
      formattedPoints = NumberFormat("#,###", "de_DE").format(points);
      token = prefs.getString('token') ?? "";
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await apiService.getListCategory();
      setState(() {
        categories = response;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await apiService.getProducts();
      setState(() {
        products = response;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController1 = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadUserData();

    apiService = ApiService(Dio());
    cartRepository = CartRepository(apiService);
    cartService = CartService(cartRepository: cartRepository);
    fetchCategories();
    fetchProducts();
    _loadInitialData();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _pagingController, products);
    });

    _pagingController2.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _pagingController2, products);
    });

    _pagingController3.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _pagingController3, products);
    });

    _pagingController4.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _pagingController4, products);
    });

    _pagingController5.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _pagingController5, products);
    });

    _fetchPage1(5, products);
  }

  Future<void> _fetchPage(
    int pageKey,
    PagingController<int, ProductInfo> controller,
    List<ProductInfo> dataList,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));

      final newItems =
          List.generate(_pageSize, (index) {
            final dataIndex = pageKey * _pageSize + index;
            return dataIndex < dataList.length ? dataList[dataIndex] : null;
          }).whereType<ProductInfo>().toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  Future<void> _fetchPage1(int pageKey, List<ProductInfo> dataList) async {
    setState(() {
      _isFetching = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final newItems =
          List.generate(_pageSize, (index) {
            final dataIndex = pageKey * _pageSize + index;
            return dataIndex < dataList.length ? dataList[dataIndex] : null;
          }).whereType<ProductInfo>().toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  double lastOffset = 0;

  void _onScroll() {
    double currentOffset = _scrollController.offset;
    double delta = currentOffset - lastOffset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (currentOffset >= maxScrollExtent - 200 &&
        !_isFetching &&
        _pagingController.nextPageKey != null) {
      _fetchPage1(_pagingController.nextPageKey!, products);
    }

    if (delta > 0 && !isCollapsed) {
      setState(() => isCollapsed = true);
    } else if (delta < 0 && isCollapsed && currentOffset == 0) {
      setState(() => isCollapsed = false);
    }

    lastOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollController1.dispose();
    _pagingController.dispose();
    _pagingController2.dispose();
    _pagingController3.dispose();
    _pagingController4.dispose();
    _pagingController5.dispose();
    super.dispose();
  }

  // List<String> categoryName = [
  //   'Màn hình',
  //   'Linh kiện PC',
  //   'Điện thoại',
  //   'Gaming gear',
  //   'Phụ kiện',
  //   'PC - Máy tính bàn',
  //   'Laptop',
  //   'Laptop',
  //   'Laptop',
  // ];

  // List<Image> imgCategory = [
  //   Image.asset('assets/images/manhinh.webp'),
  //   Image.asset('assets/images/linhkien.webp'),
  //   Image.asset('assets/images/dienthoai.webp'),
  //   Image.asset('assets/images/gaming.webp'),
  //   Image.asset('assets/images/phukien.webp'),
  //   Image.asset('assets/images/pc.webp'),
  //   Image.asset('assets/images/laptop.webp'),
  //   Image.asset('assets/images/laptop.webp'),
  //   Image.asset('assets/images/laptop.webp'),
  // ];

  // sản phẩm mới và bán chạy
  bool isNewProductSelected = true;

  // final List<Map<String, dynamic>> newProducts = List.generate(
  //   20,
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

  // final List<Map<String, dynamic>> bestSellingProducts = List.generate(
  //   10,
  //   (index) => {
  //     "image": "assets/images/laptop.webp",
  //     "discountLabel": "HOT DEAL",
  //     "name": "Kingston",
  //     "description": "SSD Kingston NV2 1TB NVMe PCIe 4.0 Gen 4x4 M.2 2280",
  //     "price": "1.890.000 đ",
  //     "oldPrice": "2.490.000 đ",
  //     "discountPercent": "-24,50%",
  //   },
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 100.0,
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  bool isFullyCollapsed =
                      constraints.maxHeight == kToolbarHeight;

                  return Container(
                    decoration: BoxDecoration(
                      gradient:
                          isFullyCollapsed
                              ? LinearGradient(
                                colors: [Colors.blue, Colors.blue],
                              )
                              : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue,
                                  Colors.blue,
                                  Colors.white,
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCollapsed)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _isLoading
                                    ? _buildGreetingShimmer()
                                    : Text(
                                      "Xin chào ${fullName.isNotEmpty ? fullName : 'bạn'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Pacifico',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                Row(
                                  children: [
                                    _isLoading
                                        ? _buildPointsShimmer()
                                        : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(
                                              40,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade700,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '🪙 100',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.support_agent_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildSearchBar()),
                                if (isCollapsed) SizedBox(width: 8),
                                if (isCollapsed)
                                  Icon(
                                    Icons.support_agent_rounded,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _isLoading
                    ? _buildHorizontalListShimmer()
                    : _buildHorizontalList(),
                _isLoading ? _buildBannerShimmer() : _buildBanner(),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView(_pagingController2),
                SizedBox(height: 10),
                _isLoading
                    ? _buildProductSwitcherShimmer()
                    : _buildProductSwitcher(),
                _isLoading
                    ? _buildProductListShimmer()
                    : _buildProductList(
                      isNewProductSelected ? products : products,
                    ),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("Màn hình", () {
                      print("Màn hình mới");
                    }),
                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController3),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle("PC - Máy tính bàn", () {
                      print("PC - Máy tính bàn");
                    }),

                _isLoading
                    ? _buildListViewShimmer()
                    : _buildListView1(_pagingController4),
                _isLoading
                    ? _buildTitleShimmer()
                    : _buildTitle1("Sản phẩm nổi bật"),

                // _isLoading
                //     ? _buildListViewShimmer()
                //     : _buildListView1(_pagingController5),
                _isLoading ? _buildGridViewShimmer() : _buildGridView(),
                const SizedBox(height: 60),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      },
      child: Container(
        height: 37,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 252, 255),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center, // Căn giữa phần tìm kiếm
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 37,
                    padding: EdgeInsets.only(left: 8), // Để cách lề trái
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Phần chứa icon camera
                Container(
                  width: 50,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      print("Camera pressed");
                    },
                  ),
                ),
              ],
            ),
            // Phần chứa icon search và text, đặt ở giữa nhờ Stack
            Row(
              mainAxisSize:
                  MainAxisSize.min, // Để không chiếm toàn bộ chiều rộng
              children: [
                Icon(Icons.search, color: Colors.grey, size: 19),
                SizedBox(width: 8),
                Text(
                  "Bạn muốn mua gì hôm nay",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 190,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryPage(
                          selectedCategory: categories[index].name,
                        ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        categories[index].images ?? 'error.jpg',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/images/gaming.webp");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    categories[index].name,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner() {
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight =
        screenWidth > 1024
            ? 350
            : screenWidth > 600
            ? 250
            : 180;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: AppBanner.imgBanner.length,
            itemBuilder: (context, index, realIndex) {
              return CachedNetworkImage(
                imageUrl: AppBanner.imgBanner[index],
                imageBuilder:
                    (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                placeholder:
                    (context, url) =>
                        Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            },
            options: CarouselOptions(
              height: bannerHeight,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              viewportFraction: 0.8,
              aspectRatio: 16 / 9,
              initialPage: 0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                AppBanner.imgBanner.length,
                (index) => Container(
                  width: _currentIndex == index ? 17 : 7,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        _currentIndex == index
                            ? Colors.blue
                            : const Color.fromARGB(255, 174, 185, 184),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalListShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 140, // Tương ứng với chiều cao của Horizontal List thực tế
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6, // Số lượng placeholder (đủ để hiển thị 2 dòng)
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBannerShimmer() {
    double screenWidth = MediaQuery.of(context).size.width;
    double bannerHeight =
        screenWidth > 1024
            ? 350
            : screenWidth > 600
            ? 250
            : 180;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: bannerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, VoidCallback onSeeMore) {
    List<String> brands = [
      "Nike",
      "Adidas",
      "Puma",
      "Reebok",
      "New Balance",
      "Converse",
      "Under Armour",
      "Vans",
      "Fila",
      "ASICS",
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;
        return Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSmallScreen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildHeader(title)),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildBrandList(brands),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(selectedCategory: title),
                          ),
                        );
                      },
                      child: Text(
                        "Xem thêm",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),

              if (isSmallScreen) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildHeader(title)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(selectedCategory: title),
                          ),
                        );
                      },
                      child: Text(
                        "Xem thêm",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildBrandList(brands),
                  ),
                ),
              ],
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle1(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: _buildHeader(title),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBrandList(List<String> brands) {
    return Row(
      children:
          brands.map((brand) {
            return Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(brand, style: TextStyle(fontSize: 12)),
            );
          }).toList(),
    );
  }

  // final List<Map<String, dynamic>> products = List.generate(
  //   10,
  //   (index) => {
  //     "image": "assets/images/laptop.webp",
  //     "discountLabel": "TIẾT KIỆM\n700.000 đ",
  //     "name": "ADATAfdsfadfdnmafdam,fnasdm,f fdmas,fndasm,fnasdmfdnassfmadnf",
  //     "description":
  //         "Ram Desktop ADATA XPG D50 DDR4 16GB (1x16GB) 3200 RGB Grey...",
  //     "price": "990.000 đ",
  //     "oldPrice": "1.690.000 đ",
  //     "discountPercent": "-41,42%",
  //   },
  // );

  Widget _buildListView(PagingController<int, ProductInfo> controller) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/nengiamgia.webp',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 480,
          color: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Giảm cực sốc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(selectedCategory: "Giảm giá"),
                          ),
                        );
                      },
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PagedListView<int, ProductInfo>(
                  pagingController: controller,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(8),
                  builderDelegate: PagedChildBuilderDelegate<ProductInfo>(
                    itemBuilder: (context, product, index) {
                      final int rating = Random().nextInt(3) + 3;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
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
                                    Positioned(
                                      bottom: 5,
                                      left: 8,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/giamgia.svg',
                                            width: 40,
                                            height: 40,
                                          ),
                                          Positioned(
                                            child: Text(
                                              product.discountLabel,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
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
                                      maxLines: 2,
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          product.oldPrice,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          product.discountPercent,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
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
                                      side: BorderSide(
                                        color: Colors.blue,
                                        width: 1,
                                      ),
                                      foregroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 9,
                                      ),
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView1(PagingController<int, ProductInfo> controller) {
    return Container(
      height: 420,
      child: PagedListView<int, ProductInfo>(
        pagingController: controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8),
        builderDelegate: PagedChildBuilderDelegate<ProductInfo>(
          itemBuilder: (context, product, index) {
            final int rating = Random().nextInt(3) + 3;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductPage()),
                );
              },
              child: Container(
                width: 180,
                margin: EdgeInsets.only(right: 10),
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
                      child: ClipRRect(
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
                            maxLines: 2,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              ),
            );
          },
        ),
      ),
    );
  }

  // sản phẩm mới hoặc sản phẩm bán chạy

  String backgroundImage =
      "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png";

  Widget _buildProductList(List<ProductInfo> products) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImage), // Ảnh nền
          fit: BoxFit.cover, // Trải đều ảnh
        ),
      ),
      child: ListView.builder(
        controller: _scrollController1,
        padding: EdgeInsets.all(8),
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
                  child: ClipRRect(
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
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        products[index].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        products[index].description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        products[index].price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            products[index].oldPrice,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 4),
                          Text(
                            products[index].discountPercent,
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

  Widget _buildProductSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isNewProductSelected = true;
              _scrollController1.jumpTo(0);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              image:
                  isNewProductSelected
                      ? DecorationImage(
                        image: NetworkImage(
                          "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png",
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
              color: isNewProductSelected ? null : Colors.white,
            ),
            child: Text(
              "Sản phẩm mới",
              style: TextStyle(
                color: Colors.black,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isNewProductSelected = false;
              _scrollController1.jumpTo(0);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              image:
                  !isNewProductSelected
                      ? DecorationImage(
                        image: NetworkImage(
                          "https://file.hstatic.net/200000722513/file/thang_02_layout_web_-12.png",
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
              color: !isNewProductSelected ? null : Colors.white,
            ),
            child: Text(
              "Sản phẩm bán chạy",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(ProductInfo product) {
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              product.image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  product.price ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.oldPrice ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.discountPercent ?? "",
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
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
  }

  Widget _buildGridView() {
    return ValueListenableBuilder(
      valueListenable: _pagingController,
      builder: (context, PagingState<int, ProductInfo> value, child) {
        final items = value.itemList ?? [];
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.53,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _buildProductItem(items[index]),
            ),
            if (_isFetching)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Đang tải thêm ...",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            if (value.error != null)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Có lỗi xảy ra khi tải dữ liệu',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

Widget _buildGreetingShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: 150, // Ước lượng chiều rộng của text chào hỏi
      height: 20, // Chiều cao tương ứng với fontSize 16
      color: Colors.white,
    ),
  );
}

Widget _buildPointsShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: 60, // Ước lượng chiều rộng của '🪙 100'
      height: 28, // Chiều cao của Container thực tế (padding + text)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
    ),
  );
}

Widget _buildListViewShimmer() {
  return Container(
    height: 480,
    color: null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 100, height: 18, color: Colors.white),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 60, height: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 420,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(8),
              itemCount: 5, // Số lượng placeholder shimmer
              itemBuilder: (context, index) {
                return Container(
                  width: 180,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
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
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 8,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.white,
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
                              Container(
                                width: 120,
                                height: 14,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 150,
                                height: 12,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    width: 40,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    width: 16,
                                    height: 16,
                                    margin: EdgeInsets.only(right: 2),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            width: double.infinity,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
        ),
      ],
    ),
  );
}

Widget _buildProductSwitcherShimmer() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(width: 80, height: 16, color: Colors.grey[300]),
        ),
      ),
      const SizedBox(width: 8),
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(width: 120, height: 16, color: Colors.grey[300]),
        ),
      ),
    ],
  );
}

Widget _buildProductListShimmer() {
  return Container(
    height: 420,
    child: ListView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.horizontal,
      itemCount: 8,
      itemBuilder: (context, index) {
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
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần ảnh
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
                // Phần nội dung
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.white,
                      ), // Tên
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ), // Mô tả dòng 1
                      const SizedBox(height: 2),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ), // Mô tả dòng 2
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 16,
                        color: Colors.white,
                      ), // Giá
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 12,
                            color: Colors.white,
                          ), // Giá cũ
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 12,
                            color: Colors.white,
                          ), // Giảm giá
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 2),
                            color: Colors.white,
                          );
                        }),
                      ), // Sao đánh giá
                    ],
                  ),
                ),
                const Spacer(),
                // Nút "Thêm giỏ hàng"
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildTitleShimmer() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ô bên trái (giả lập tiêu đề)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100, // Ước lượng chiều rộng tiêu đề
                height: 20, // Ước lượng chiều cao tiêu đề
                color: Colors.white,
              ),
            ),
            // Ô bên phải (giả lập "Xem thêm")
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 60, // Ước lượng chiều rộng "Xem thêm"
                height: 14, // Ước lượng chiều cao text
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 1, color: Colors.grey[300]),
      ],
    ),
  );
}

Widget _buildGridViewShimmer() {
  return Column(
    children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.53,
        ),
        itemCount: 4, // Số lượng item giả lập (có thể thay đổi)
        itemBuilder: (context, index) => _buildProductItemShimmer(),
      ),
    ],
  );
}

Widget _buildProductItemShimmer() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần ảnh
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              color: Colors.white,
            ),
          ),
          // Phần nội dung
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120, // Giả lập tên sản phẩm
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 2),
                Container(width: 80, height: 12, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                  width: 60, // Giả lập giá
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 40, // Giả lập giá cũ
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 30, // Giả lập giảm giá
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Nút "Thêm giỏ hàng"
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              height: 36, // Ước lượng chiều cao nút
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
