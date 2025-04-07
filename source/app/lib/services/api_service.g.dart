// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl}) {
    baseUrl ??= 'http://192.168.1.137:8080/api';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<LoginResponse> login(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<LoginResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/login',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = LoginResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<RegisterResponse> register(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<RegisterResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/register',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = RegisterResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ValidResponse> verifyOtp(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ValidResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/verify-otp',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ValidResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ResendOtpResponse> resendOtp(request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<ResendOtpResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/resend-otp',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = ResendOtpResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UserInfo> getUserInfo(token) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<UserInfo>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/user-info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = UserInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<CategoryInfo>> getListCategory() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/category/list',
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
  Future<List<CategoryInfo>> getListBrand() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CategoryInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/brand/list',
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
  Future<List<ProductInfo>> getProducts() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => ProductInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<ProductInfo>> getProductsByCategory(fk_category) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fk_category': fk_category};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/category',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => ProductInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<Product> getProductDetail(id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Product>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/detail',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Product.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<ProductInfo>> getProductsByBrand(fk_brand) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'fk_brand': fk_brand};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<ProductInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/products/brand',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => ProductInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<List<RatingInfo>> getRatingsByProduct(productId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'productId': productId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<RatingInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/rating/product',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => RatingInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<RatingInfo> createRating(productId, rating) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(rating.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<RatingInfo>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/rating/product/${productId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = RatingInfo.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<CartInfo>> getItemInCart({token, id}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'id': id};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<CartInfo>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/list',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value =
        _result.data!
            .map((dynamic i) => CartInfo.fromJson(i as Map<String, dynamic>))
            .toList();
    return value;
  }

  @override
  Future<void> sendResetPassword(email) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'email': email};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    await _dio.fetch<void>(
      _setStreamType<void>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/auth/forgot-password',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
  }

  @override
  Future<Coupon> findCoupon(name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'name': name};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Coupon>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/coupon/find',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = Coupon.fromJson(_result.data!);
    return value;
  }

  @override
  Future<Map<String, dynamic>> addToCart(
    token,
    productId,
    colorId,
    quantity,
    id,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'productId': productId,
      r'colorId': colorId,
      r'quantity': quantity,
      r'id': id,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/add',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<Map<String, dynamic>> minusToCart(productId, orderId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'productId': productId,
      r'orderId': orderId,
    };
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/minus',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
    return value;
  }

  @override
  Future<Map<String, dynamic>> deleteToCart(orderDetailId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'orderDetailId': orderDetailId};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<Map<String, dynamic>>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/cart/delete',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    var value = Map<String, dynamic>.from(_result.data!);
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
