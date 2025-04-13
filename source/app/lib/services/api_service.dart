import 'package:app/models/address.dart';
import 'package:app/models/address_response.dart';
import 'package:app/models/category_info.dart';
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
}

@RestApi(baseUrl: "http://192.168.70.182:8080/api")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/auth/login")
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST("/auth/register")
  Future<RegisterResponse> register(@Body() RegisterRequest request);

  @POST("/auth/verify-otp")
  Future<ValidResponse> verifyOtp(@Body() ValidRequest request);

  @POST("/auth/resend-otp")
  Future<ResendOtpResponse> resendOtp(@Body() ResendOtpRequest request);

  @GET("/auth/user-info")
  Future<UserInfo> getUserInfo(@Header("Authorization") String token);

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

  @GET("/products")
  Future<List<ProductInfo>> getProducts();

  @GET("/products/category")
  Future<List<ProductInfo>> getProductsByCategory(
    @Query("fk_category") String fk_category,
  );

  @GET("/products/detail")
  Future<Product> getProductDetail(@Query("id") int id);

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
  );
}
