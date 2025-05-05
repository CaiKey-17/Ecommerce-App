import 'package:app/luan/models/brand_info.dart';
import 'package:app/luan/models/category_info.dart';

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

@RestApi(baseUrl: "http://192.168.70.182:8080/api")
abstract class ApiAdminService {
  factory ApiAdminService(Dio dio, {String baseUrl}) = _ApiAdminService;

  @GET("/admin/brand/list")
  Future<List<BrandInfo>> getAllBrands();

  @POST("/admin/brand/add")
  Future<BrandInfo> createBrand(
    @Query("name") String name,
    @Query("image") String image,
  );

  @POST("/admin/brand/{name}")
  Future<BrandInfo> updateBrand(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/brand/{name}")
  Future<void> deleteBrand(@Path("name") String name);

  //category
  @GET("/admin/category/list")
  Future<List<CategoryInfo>> getAllCategories();

  @POST("/admin/category/add")
  Future<CategoryInfo> createCategory(
    @Query("name") String name,
    @Query("image") String image,
  );

  @POST("/admin/category/{name}")
  Future<CategoryInfo> updateCategory(
    @Path("name") String name,
    @Query("image") String image,
  );

  @DELETE("/admin/category/{name}")
  Future<void> deleteCategory(@Path("name") String name);
}
