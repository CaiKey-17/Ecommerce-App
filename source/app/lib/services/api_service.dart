import 'package:app/models/address.dart';
import 'package:app/models/address_response.dart';
import 'package:app/models/admin_info.dart';
import 'package:app/models/category_info.dart';
import 'package:app/models/comment.dart';
import 'package:app/models/comment_info.dart';
import 'package:app/models/comment_reply_request.dart';
import 'package:app/models/comment_request.dart';
import 'package:app/models/coupon_info.dart';

import 'package:app/models/product_info.dart';
import 'package:app/models/product_info_detail.dart';
import 'package:app/models/rating_info.dart';
import 'package:app/models/resend_otp_request.dart';
import 'package:app/models/resend_otp_response.dart';
import 'package:app/models/valid_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/http.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

import '../models/register_request.dart';
import '../models/valid_request.dart';
import '../models/register_response.dart';
import '../models/user_info.dart';
import '../models/cart_info.dart';

part 'api_service.g.dart';

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }
}

@RestApi(baseUrl: "http://192.168.70.182:8080/api")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/auth/login")
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST("/auth/changePassword")
  Future<ApiResponse> changePassword(
    @Header("Authorization") String token,
    @Query("oldPassword") String oldPassword,
    @Query("newPassword") String newPassword,
  );

  @POST("/auth/register")
  Future<RegisterResponse> register(@Body() RegisterRequest request);

  @POST("/auth/verify-otp")
  Future<ValidResponse> verifyOtp(@Body() ValidRequest request);

  @POST("/auth/resend-otp")
  Future<ResendOtpResponse> resendOtp(@Body() ResendOtpRequest request);

  @GET("/auth/user-info")
  Future<UserInfo> getUserInfo(@Header("Authorization") String token);

  @GET("/auth/admin-info")
  Future<AdminInfo> getAdminInfo(@Header("Authorization") String token);

  @POST("/auth/user-info/change")
  Future<void> changeImage(
    @Header("Authorization") String token,
    @Query("image") String image,
  );

  @POST("/auth/user-info/update-name")
  Future<void> changeName(
    @Header("Authorization") String token,
    @Query("name") String name,
  );
  @GET("/address")
  Future<List<AddressList>> getListAddress(
    @Header("Authorization") String token,
  );
  @POST("/address/add")
  Future<AddressResponse> addAddress(@Body() AddressList address);

  @POST("/address/default")
  Future<void> chooseAddressDefault(
    @Header("Authorization") String token,
    @Query("addressId") int addressId,
  );

  @GET("/category/list")
  Future<List<CategoryInfo>> getListCategory();

  @GET("/brand/list")
  Future<List<CategoryInfo>> getListBrand();

  @GET("/products/promotion")
  Future<List<ProductInfo>> getProductsPromotion();

  @GET("/products/new")
  Future<List<ProductInfo>> getProductsNew();

  @GET("/products/best-seller")
  Future<List<ProductInfo>> getProductsBestSeller();

  @GET("/products/laptop")
  Future<List<ProductInfo>> getProductsLaptop();

  @GET("/products/phone")
  Future<List<ProductInfo>> getProductsPhone();

  @GET("/products/pc")
  Future<List<ProductInfo>> getProductsPc();

  @GET("/products/keyboard")
  Future<List<ProductInfo>> getProductsKeyBoard();

  @GET("/products/monitor")
  Future<List<ProductInfo>> getProductsMonitor();

  @GET("/products/category")
  Future<List<ProductInfo>> getProductsByCategory(
    @Query("fk_category") String fk_category,
  );

  @GET("/products/detail")
  Future<Product> getProductDetail(@Query("id") int id);

  @GET("/comments")
  Future<List<Comment>> getCommentInProduct(@Query("id") int id);

  @POST("/comments")
  Future<Comment> postComment(@Body() CommentRequest comment);

  @POST("/comments/{commentId}/reply")
  Future<Comment> replyToComment(
    @Path("commentId") int commentId,
    @Body() CommentReplyRequest reply,
  );

  @GET("/products/brand")
  Future<List<ProductInfo>> getProductsByBrand(
    @Query("fk_brand") String fk_brand,
  );

  @GET("/rating/product")
  Future<List<RatingInfo>> getRatingsByProduct(
    @Query("productId") int productId,
  );

  @POST("/rating/product/{productId}")
  Future<RatingInfo> createRating(
    @Path("productId") int productId,
    @Body() RatingInfo rating,
  );

  @GET("/cart/list")
  Future<List<CartInfo>> getItemInCart({
    @Header("Authorization") String? token,
    @Query("id") int? id,
  });

  @GET("/cart/quantity")
  Future<Map<String, dynamic>> getRawQuantityInCart(
    @Query("userId") int? userId,
  );

  @POST("/auth/forgot-password")
  Future<void> sendResetPassword(@Query("email") String email);

  @GET("/coupon/find")
  Future<Coupon> findCoupon(@Query("name") String name);

  @POST("/cart/add")
  Future<Map<String, dynamic>> addToCart(
    @Header("Authorization") String? token,
    @Query("productId") int productId,
    @Query("colorId") int colorId,
    @Query("quantity") int quantity,
    @Query("id") int? id,
  );

  @POST("/cart/minus")
  Future<Map<String, dynamic>> minusToCart(
    @Query("productId") int productId,
    @Query("orderId") int orderId,
    @Query("colorId") int colorId,
  );

  @POST("/cart/delete")
  Future<Map<String, dynamic>> deleteToCart(
    @Query("orderDetailId") int orderDetailId,
  );

  @GET("/order/pending")
  Future<List<Map<String, dynamic>>> findPendingOrdersByCustomer(
    @Header("Authorization") String? token,
  );

  @GET("/order/delivering")
  Future<List<Map<String, dynamic>>> findDeliveringOrdersByCustomer(
    @Header("Authorization") String? token,
  );
  @GET("/order/delivered")
  Future<List<Map<String, dynamic>>> findDeliveredOrdersByCustomer(
    @Header("Authorization") String? token,
  );

  @POST("/order/confirm")
  Future<Map<String, dynamic>> confirmToCart(
    @Query("orderId") int orderId,
    @Query("address") String address,
    @Query("couponTotal") double couponTotal,
    @Query("email") String email,
    @Query("fkCouponId") int fkCouponId,
    @Query("pointTotal") double pointTotal,
    @Query("priceTotal") double priceTotal,
    @Query("ship") double ship,
    @Query("tempId") String tempId,
    @Query("id") int id,
  );

  @POST("/order/cancel")
  Future<Map<String, dynamic>> cancelToCart(@Query("orderId") int orderId);

  @POST("/order/received")
  Future<Map<String, dynamic>> received(@Query("orderId") int orderId);
}
