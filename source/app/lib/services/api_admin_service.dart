import 'package:app/luan/models/brand_info.dart';
import 'package:app/luan/models/category_info.dart';
import 'package:app/luan/models/order_info.dart';
import 'package:app/luan/models/user_info.dart';
import 'package:app/luan/models/product_info.dart';

import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'api_admin_service.g.dart';

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

@RestApi(baseUrl: "http://172.16.10.26:8080/api")
abstract class ApiAdminService {
  factory ApiAdminService(Dio dio, {String baseUrl}) = _ApiAdminService;

  @GET("/admin/brand/list")
  Future<List<BrandInfo>> getAllBrands();

  @POST("/admin/brand/add")
  Future<BrandInfo> createBrand(
    @Query("name") String name,
    @Query("image") String image);

  @POST("/admin/brand/{name}")
  Future<BrandInfo> updateBrand(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/brand/{name}")
  Future<void> deleteBrand(
    @Path("name") String name);

  //category
  @GET("/admin/category/list")
  Future<List<CategoryInfo>> getAllCategories();

  @POST("/admin/category/add")
  Future<CategoryInfo> createCategory(
    @Query("name") String name,
    @Query("image") String image);

  @POST("/admin/category/{name}")
  Future<CategoryInfo> updateCategory(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/category/{name}")
  Future<void> deleteCategory(
    @Path("name") String name);


  //user
  @GET("/admin/users")
  Future<List<UserInfo>> getAllUsers();

  @GET("/admin/users/{id}")
  Future<UserInfo> getUserById(@Path("id") int id);

  @POST("/admin/users/{id}/toggle-active")
  Future<void> toggleUserActive(@Path("id") int id);

  @DELETE("/admin/users/{id}")
  Future<void> deleteUser(@Path("id") int id);

  @POST("/admin/users/{id}/full-name")
  Future<void> updateUserFullName(
    @Path("id") int id,
    @Query("fullName") String fullName,
  );

  //order
  @GET("/admin/orders/customer/{customerId}")
  Future<List<OrderInfo>> getOrdersByCustomer(
    @Path("customerId") int customerId,
  );

  // product
  @GET("/admin/products")
  Future<List<ProductInfo>> getAllProducts();

}
