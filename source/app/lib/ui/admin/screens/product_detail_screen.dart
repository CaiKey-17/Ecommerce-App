  // product_detail_screen.dart
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';

  class ProductDetailScreen extends StatefulWidget {
    final bool isEdit;
    final Map<String, dynamic>? product;
    final int? productIndex;
    final Function(Map<String, dynamic>)? onSave;

    ProductDetailScreen({
      required this.isEdit,
      this.product,
      this.productIndex,
      this.onSave,
    });

    @override
    _ProductDetailScreenState createState() => _ProductDetailScreenState();
  }

  class _ProductDetailScreenState extends State<ProductDetailScreen> {
    late TextEditingController _nameController;
    late TextEditingController _basePriceController;
    late TextEditingController _descriptionController;
    late TextEditingController _discountController;


    final List<String> productTypes = [
      "Điện thoại",
      "Máy tính bảng",
      "Laptop",
      "Phụ kiện",
      "Tai nghe",
      "Đồng hồ thông minh"
    ];
    String? selectedProductType;

    List<String> versions = [];
    List<double> priceModifiers = [];
    List<List<String>> versionColors = [];
    List<List<double>> versionColorPrices = [];
    List<List<int>> versionColorQuantities = [];
    List<String?> colorImages = [];

    int selectedVersionIndex = -1;
    int selectedColorIndex = -1;

    final TextEditingController _newColorController = TextEditingController();
    final TextEditingController _newPriceController = TextEditingController();
    final TextEditingController _newVersionController = TextEditingController();
    final TextEditingController _newVersionPriceController = TextEditingController();
    final TextEditingController _newQuantityController = TextEditingController();

    final TextEditingController _keyController = TextEditingController();
    final TextEditingController _valueController = TextEditingController();
    List<Map<String, String>> specifications = [];
    bool showTitleInput = false;
    bool showKeyValueInput = false;
    bool showVersionSection = false;
    bool hasColors = false;

    String? _imagePath;
    List<String> _additionalImages = [];

    @override
    void initState() {
      super.initState();
      if (widget.isEdit && widget.product != null) {
        _nameController = TextEditingController(text: widget.product!["name"]);
        _basePriceController = TextEditingController(text: widget.product!["price"].toString());
        _discountController = TextEditingController(text: widget.product!["discount"].toString());
        _descriptionController = TextEditingController(text: "");
        selectedProductType = widget.product!["category"];
        _imagePath = widget.product!["image"];
        versions = ["Default"];
        priceModifiers = [0];
        versionColors = [["Default"]];
        versionColorPrices = [[0]];
        versionColorQuantities = [[widget.product!["quantity"]]];
        showVersionSection = true;
        hasColors = false;
        selectedVersionIndex = 0;
        selectedColorIndex = 0;
        if (widget.product!["additionalImages"] != null) {
        _additionalImages = List<String>.from(widget.product!["additionalImages"]);
      }
      } else {
        _nameController = TextEditingController();
        _basePriceController = TextEditingController();
        _discountController = TextEditingController(text: "0");
        _descriptionController = TextEditingController();
        selectedProductType = productTypes.first;
        _imagePath = null;
        selectedVersionIndex = -1;
        selectedColorIndex = -1;
      }
    }

    double _calculateDiscountedPrice() {
      double basePrice = double.tryParse(_basePriceController.text) ?? 0;
      double discount = double.tryParse(_discountController.text) ?? 0;
      return basePrice * (1 - discount / 100);
    }

    Future<void> _pickImage(Function(String?) onImagePicked) async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        onImagePicked(pickedFile.path);
      }
    }

    Future<void> _pickAdditionalImages() async {
      final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _additionalImages.addAll(pickedFiles.map((file) => file.path));
        });
      }
    }                                                 

    void _saveProduct() {
      final product = {
        "id": widget.isEdit ? widget.product!["id"] : "#00${DateTime.now().millisecondsSinceEpoch}",
        "name": _nameController.text,
        "price": _basePriceController.text.isNotEmpty ? double.parse(_basePriceController.text) : 0,
        "quantity": versions.isEmpty
            ? 0
            : (selectedVersionIndex >= 0 && selectedColorIndex >= 0
                ? versionColorQuantities[selectedVersionIndex][selectedColorIndex]
                : versionColorQuantities.isNotEmpty ? versionColorQuantities[0][0] : 0),
        "category": selectedProductType ?? "Điện thoại",
        "discount": _discountController.text.isNotEmpty ? double.parse(_discountController.text) : 0.0,
        "image": _imagePath,
        "versions": versions,
        "priceModifiers": priceModifiers,
        "versionColors": versionColors,
        "versionColorPrices": versionColorPrices,
        "versionColorQuantities": versionColorQuantities,
        "specifications": specifications,
        "description": _descriptionController.text,
        "additionalImages": _additionalImages, 
      };
      widget.onSave?.call(product);
      Navigator.pop(context);
    }

    void _deleteProduct() {
      if (widget.isEdit) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Xác nhận xóa"),
            content: Text("Bạn có chắc chắn muốn xóa sản phẩm này?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã xóa sản phẩm")),
                  );
                },
                child: Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    }

    void _showAddColorDialog() {
      if (selectedVersionIndex < 0) return;
      String? imagePath; // Thêm biến lưu đường dẫn ảnh
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Thêm màu cho ${versions[selectedVersionIndex]}"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            imagePath = pickedFile.path;
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: imagePath == null
                            ? Icon(Icons.camera_alt_rounded, size: 30)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imagePath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _newColorController,
                        decoration: InputDecoration(
                          labelText: "Tên màu",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _newPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Giá tăng thêm (VNĐ)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _newQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Số lượng",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_newColorController.text.isNotEmpty &&
                          _newPriceController.text.isNotEmpty &&
                          _newQuantityController.text.isNotEmpty) {
                        setState(() {
                          versionColors[selectedVersionIndex].add(_newColorController.text);
                          versionColorPrices[selectedVersionIndex].add(double.parse(_newPriceController.text));
                          versionColorQuantities[selectedVersionIndex].add(int.parse(_newQuantityController.text));
                          colorImages.add(imagePath); // Lưu đường dẫn ảnh
                          if (selectedColorIndex == -1) selectedColorIndex = 0;
                        });
                        _newColorController.clear();
                        _newPriceController.clear();
                        _newQuantityController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Hoàn tất"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void _showAddVersionDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Thêm phiên bản mới"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newVersionController,
                decoration: InputDecoration(
                  labelText: "Tên phiên bản (ví dụ: 1TB)",
                  border: OutlineInputBorder(),
                ),
              ),
              if (!hasColors) ...[
                SizedBox(height: 16),
                TextField(
                  controller: _newVersionPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Giá tăng thêm (VNĐ)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _newQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Số lượng",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                if (_newVersionController.text.isNotEmpty &&
                    (hasColors ||
                        (_newVersionPriceController.text.isNotEmpty &&
                            _newQuantityController.text.isNotEmpty))) {
                  setState(() {
                    versions.add(_newVersionController.text);
                    priceModifiers.add(hasColors
                        ? 0
                        : double.parse(_newVersionPriceController.text));
                    versionColors.add(hasColors ? [] : ["Default"]);
                    versionColorPrices.add(hasColors ? [] : [0]);
                    versionColorQuantities.add(
                        hasColors ? [] : [int.parse(_newQuantityController.text)]);
                    if (selectedVersionIndex == -1) selectedVersionIndex = 0;
                    if (selectedColorIndex == -1 && !hasColors) selectedColorIndex = 0;
                  });
                  _newVersionController.clear();
                  _newVersionPriceController.clear();
                  _newQuantityController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text("Hoàn tất"),
            ),
          ],
        ),
      );
    }

    void _addSpecification() {
      if (_valueController.text.isNotEmpty &&
          (showTitleInput || (showKeyValueInput && _keyController.text.isNotEmpty))) {
        setState(() {
          Map<String, String> newSpec = {
            showTitleInput ? "title" : _keyController.text: _valueController.text
          };
          specifications.add(newSpec);
          
          String specString = specifications.map((spec) {
            String key = spec.keys.first;
            String value = spec.values.first;
            return key == "title" ? "Title: $value" : "$key: $value";
          }).join("; "); 
          
          print("Specifications as string: $specString");
          
          _keyController.clear();
          _valueController.clear();
          showTitleInput = false;
          showKeyValueInput = false;
        });
      } else {
        print("Error: Input is incomplete!");
      }
    }

    void _deleteVersion(int index) {
      setState(() {
        versions.removeAt(index);
        priceModifiers.removeAt(index);
        versionColors.removeAt(index);
        versionColorPrices.removeAt(index);
        versionColorQuantities.removeAt(index);
        if (versions.isEmpty) {
          selectedVersionIndex = -1;
          selectedColorIndex = -1;
        } else if (selectedVersionIndex >= versions.length) {
          selectedVersionIndex = versions.length - 1;
          selectedColorIndex = versionColors[selectedVersionIndex].isEmpty ? -1 : 0;
        }
      });
    }

    void _deleteColor(int index) {
      if (selectedVersionIndex < 0) return;
      setState(() {
        versionColors[selectedVersionIndex].removeAt(index);
        versionColorPrices[selectedVersionIndex].removeAt(index);
        versionColorQuantities[selectedVersionIndex].removeAt(index);
        if (versionColors[selectedVersionIndex].isEmpty) {
          selectedColorIndex = -1;
        } else if (selectedColorIndex >= versionColors[selectedVersionIndex].length) {
          selectedColorIndex = versionColors[selectedVersionIndex].length - 1;
        }
      });
    }

    void _deleteSpecification(int index) {
      setState(() {
        specifications.removeAt(index);
      });
    }

    double _calculateVersionPrice(int versionIndex) {
      double basePrice = _calculateDiscountedPrice(); 
      return basePrice + priceModifiers[versionIndex];
    }

    double _calculateColorPrice(int versionIndex, int colorIndex) {
      double basePrice = _calculateDiscountedPrice(); 
      return basePrice + priceModifiers[versionIndex] + versionColorPrices[versionIndex][colorIndex];
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Chi tiết sản phẩm"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imagePath = pickedFile.path;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? Center(child: Text("Chọn hình ảnh"))
                      : null,
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
              onTap: _pickAdditionalImages,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text("Chọn nhiều hình ảnh bổ sung")),
              ),
            ),
            SizedBox(height: 8),
            if (_additionalImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _additionalImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_additionalImages[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Tên sản phẩm",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedProductType,
                decoration: InputDecoration(
                  labelText: "Loại sản phẩm",
                  border: OutlineInputBorder(),
                ),
                items: productTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProductType = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _basePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Giá nhập (VNĐ)",
                  border: OutlineInputBorder(),

                ),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Phần trăm giảm giá (%)",
                  border: OutlineInputBorder(),

                ),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: 16),
              Text(
                "Giá sau giảm: ${_calculateDiscountedPrice()} VNĐ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),
              if (!showVersionSection) ...[
                Text("Sản phẩm bạn có màu sắc không?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showVersionSection = true;
                          hasColors = true;
                        });
                      },
                      child: Text("Có"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showVersionSection = true;
                          hasColors = false;
                        });
                      },
                      child: Text("Không"),
                    ),
                  ],
                ),
              ],
              if (showVersionSection) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Chọn phiên bản:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _showAddVersionDialog,
                      child: Text("Thêm phiên bản"),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                versions.isEmpty
                    ? Text("Chưa có phiên bản nào")
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(versions.length, (index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVersionIndex = index;
                                    selectedColorIndex = hasColors && versionColors[index].isNotEmpty ? 0 : -1;
                                  });
                                },
                                child: Container(
                                  width: 110,
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedVersionIndex == index ? Colors.blue : Colors.grey,
                                      width: selectedVersionIndex == index ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(versions[index],
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      if (!hasColors) ...[
                                        Text(
                                          "${_calculateVersionPrice(index).toStringAsFixed(0)}đ",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        if (versionColorQuantities[index].isNotEmpty)
                                          Text(
                                            "SL: ${versionColorQuantities[index][0]}",
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _deleteVersion(index),
                                  child: Container(
                                    color: Colors.red,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                if (hasColors && selectedVersionIndex >= 0) ...[
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Màu sắc (${versions[selectedVersionIndex]}):",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: _showAddColorDialog,
                        child: Text("Thêm màu"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  versionColors[selectedVersionIndex].isEmpty
                      ? Text("Chưa có màu nào cho phiên bản này")
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(versionColors[selectedVersionIndex].length, (index) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColorIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 110,
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedColorIndex == index ? Colors.blue : Colors.grey,
                                        width: selectedColorIndex == index ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(versionColors[selectedVersionIndex][index],
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text(
                                          "${_calculateColorPrice(selectedVersionIndex, index).toStringAsFixed(0)}đ",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "SL: ${versionColorQuantities[selectedVersionIndex][index]}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => _deleteColor(index),
                                    child: Container(
                                      color: Colors.red,
                                      child: Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                ],
              ],
              SizedBox(height: 16),
              Text("Thông tin chi tiết:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Column(
                children: [
                  if (!showTitleInput && !showKeyValueInput)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showTitleInput = true;
                            });
                          },
                          child: Text('Nhập Tiêu đề'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showKeyValueInput = true;
                            });
                          },
                          child: Text('Nhập Key-Value'),
                        ),
                      ],
                    ),
                  if (showTitleInput) ...[
                    TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: 'Nhập nội dung tiêu đề',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  if (showKeyValueInput)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _keyController,
                            decoration: InputDecoration(
                              labelText: 'Nhập key',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Nhập value',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (showTitleInput || showKeyValueInput) ...[
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addSpecification,
                      child: Text('Hoàn tất'),
                    ),
                  ],
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: specifications.length,
                      itemBuilder: (context, index) {
                        Map<String, String> spec = specifications[index];
                        String key = spec.keys.first;
                        String value = spec.values.first;
                        bool isTitle = key.toLowerCase() == "title";

                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: isTitle
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                                      child: Text(
                                        value,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Container(
                                      color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              key,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _deleteSpecification(index),
                                child: Container(
                                  color: Colors.red,
                                  child: Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("Mô tả sản phẩm:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Mô tả",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.isEdit)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Xóa", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              if (widget.isEdit) SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    widget.isEdit ? "Cập nhật" : "Thêm",
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