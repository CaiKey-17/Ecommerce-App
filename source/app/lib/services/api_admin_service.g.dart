// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_admin_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ApiAdminService implements ApiAdminService {
  _ApiAdminService(this._dio, {this.baseUrl}) {
    baseUrl ??= ApiConfig.baseUrlAPI;
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<BrandInfo>> getAllBrands() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<BrandInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => BrandInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<BrandInfo> createBrand(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name, r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<BrandInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<BrandInfo> updateBrand(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<BrandInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = BrandInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteBrand(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/brand/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<List<CategoryInfo>> getAllCategories() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map(
              (dynamic i) => CategoryInfo.fromJson(i as Map<String, dynamic>),
            )
            .toList();
    return value;
  }

  @override
  Future<CategoryInfo> createCategory(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name, r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<CategoryInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<CategoryInfo> updateCategory(name, image) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'image': image};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<CategoryInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = CategoryInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteCategory(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/admin/category/${name}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
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
