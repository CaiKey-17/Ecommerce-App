// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_admin_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ApiAdminService implements ApiAdminService {
  _ApiAdminService(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://172.16.10.26:8080/api';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<BrandInfo>> getAllBrands() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch<List<dynamic>>(_setStreamType<List<BrandInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/brand/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => BrandInfo.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<BrandInfo> createBrand(
    name,
    image,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'name': name,
      r'image': image,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<BrandInfo>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/brand/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<BrandInfo> updateBrand(
    name,
    image,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<BrandInfo>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/brand/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteBrand(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(_setStreamType<void>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/brand/${name}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
  }

  @override
  Future<List<CategoryInfo>> getAllCategories() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<List<CategoryInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/category/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => CategoryInfo.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<CategoryInfo> createCategory(
    name,
    image,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'name': name,
      r'image': image,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<CategoryInfo>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/category/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CategoryInfo> updateCategory(
    name,
    image,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<CategoryInfo>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/category/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteCategory(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(_setStreamType<void>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/category/${name}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
  }

  @override
  Future<List<UserInfo>> getAllUsers() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch<List<dynamic>>(_setStreamType<List<UserInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/users',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => UserInfo.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<UserInfo> getUserById(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch<Map<String, dynamic>>(_setStreamType<UserInfo>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/users/${id}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> toggleUserActive(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(_setStreamType<void>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/users/${id}/toggle-active',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
  }

  @override
  Future<void> deleteUser(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(_setStreamType<void>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/users/${id}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
  }

  @override
  Future<void> updateUserFullName(
    id,
    fullName,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fullName': fullName};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(_setStreamType<void>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/admin/users/${id}/full-name',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
  }

  @override
  Future<List<OrderInfo>> getOrdersByCustomer(customerId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await _dio.fetch<List<dynamic>>(_setStreamType<List<OrderInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/orders/customer/${customerId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => OrderInfo.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<List<ProductInfo>> getAllProducts() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<List<ProductInfo>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/admin/products',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) => ProductInfo.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
