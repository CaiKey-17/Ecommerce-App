import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/cart_repository.dart';
import '../providers/cart_provider.dart';

class CartService {
  final CartRepository cartRepository;

  CartService({required this.cartRepository});

  Future<void> addToCart({
    required int productID,
    required int colorId,
    required int id,
    required String? token,
    required dynamic context,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userID = prefs.getInt('userId') ?? -1;
    String? authToken;

    if (token != null && token.isNotEmpty && token.split('.').length == 3) {
      authToken = token;
      userID = null;
    } else {
      authToken = null;
    }

    try {
      var response = await cartRepository.addToCart(
        token: authToken,
        productId: productID,
        colorId: colorId,
        quantity: 1,
        id: userID,
      );

      int statusCode = response["statusCode"] ?? 500;

      if (statusCode == 400) {
        Fluttertoast.showToast(
          msg: response["error"] ?? "Lỗi không xác định!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        if (response.containsKey("id")) {
          userID = response["id"];
          await prefs.setInt('userId', userID!);
        }

        Fluttertoast.showToast(
          msg: response["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Provider.of<CartProvider>(context, listen: false).addItem(id);
      }
    } catch (error) {
      print("Lỗi khi gọi API: $error");
      Fluttertoast.showToast(
        msg: "Lỗi hệ thống! Vui lòng thử lại.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
