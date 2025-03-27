import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SearchPage());
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<String> recentSearches = [];
  bool showAllRecent = false;

  List<String> popularSearches = [
    "ca",
    "tai nghe",
    "màn hình",
    "loq",
    "asus",
    "trưng bày",
    "máy",
    "ssd",
    "chuột",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _addToRecentSearches(String query) {
    if (query.isNotEmpty && !recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        print("Số lượng tìm kiếm gần đây: ${recentSearches.length}");
      });
    }
    _searchController.clear();
  }

  Widget _buildSearchBar() {
    return Container(
      height: 37,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 237, 243, 248),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 0.3),
      ),
      child: Row(
        children: [
          if (!_focusNode.hasFocus)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search, color: Colors.grey, size: 18),
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              onSubmitted: _addToRecentSearches,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Bạn muốn mua gì?",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: 10,
                  left: _focusNode.hasFocus ? 16 : 0,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.clear, color: Colors.grey, size: 18),
              ),
            ),
          // 📷 Thêm icon camera vào cuối
          
           IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 20),
              onPressed: () {
                print("Camera pressed");
              },
            ),
        ],
      ),
    );
  }


  Widget _buildRecentSearches() {
    int displayCount = showAllRecent ? recentSearches.length : 5;
    bool shouldShowExpandButton = recentSearches.length > 5;

    print("Hiển thị: $displayCount / Tổng: ${recentSearches.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TÌM KIẾM GẦN ĐÂY", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...recentSearches
            .take(displayCount)
            .map(
              (search) => ListTile(
                leading: Icon(Icons.history, size: 20),
                title: Text(search, style: TextStyle(fontSize: 14)),
              ),
            ),
        if (shouldShowExpandButton)
          TextButton(
            onPressed: () {
              setState(() {
                showAllRecent = !showAllRecent;
                print("Nhấn vào: ${showAllRecent ? 'Xem thêm' : 'Thu gọn'}");
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(showAllRecent ? "Thu gọn" : "Xem thêm"),
                Icon(showAllRecent ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: 16),
          child: _buildSearchBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRecentSearches(),
              Text(
                "TÌM KIẾM PHỔ BIẾN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children:
                    popularSearches
                        .map((search) => Chip(label: Text(search)))
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
