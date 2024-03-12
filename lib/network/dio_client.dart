// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import '../../network/api/login_api.dart';

import '../ui/utils/logger.dart';
import 'api/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  // dio instance
  final Dio _dio;
  final _storage = const FlutterSecureStorage(
      mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
          synchronizable: true));

  // injecting dio instance
  DioClient(this._dio) {
    _dio
      ..options.baseUrl = Endpoints.baseUrl
      ..options.connectTimeout = Endpoints.connectionTimeout
      ..options.receiveTimeout = Endpoints.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));

    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      if (await _storage.containsKey(key: 'accessToken')) {
        String? accessToken = await _storage.read(key: LoginApi.keyAccessToken);
        options.headers['Authorization'] = 'Bearer ${accessToken}';
      }
      return handler.next(options);
    }, onError: (DioException e, handler) async {
      // todo: will finish this

      // si la reponse est 401
      // et qu'il n'y a pas de de "msg" dans la reponse (le try plante),
      // ==> ce n'est pas un message JWT !!
      //
      // sinon, si c'est un access token expiré, je fais un refresh token :)
      // et je retente la request
      if (e.response?.statusCode == 401) {
        try {
          String msg = e.response?.data['msg'];
          logger.e("401 : ${msg}");
          if (msg == "Token has expired") {
            if (await _storage.containsKey(key: 'refreshToken')) {
              // je reactualise l'accessToken
              await refreshAccessToken();
              // et je rente la requete Dio
              return handler.resolve(await _retry(e.requestOptions));
            }
          }
        } catch (er2) {
          return handler.next(e);
        }
      }

      return handler.next(e);
    }));
  }

  Future<void> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');

    await _storage.delete(key: LoginApi.keyAccessToken);

    try {
      final response = await post(Endpoints.refreshToken,
          options: Options(
            headers: {
              "Authorization": "Bearer ${refreshToken}",
            },
          ));

      if (response.statusCode == 200) {
        // successfully got the new access token
        logger.e("refresh token ok");
        String accessToken = response.data["access_token"];
        await _storage.write(key: LoginApi.keyAccessToken, value: accessToken);
        return;
      } else {
        // refresh token is wrong so log out user.
        logger.e("refresh token failed");
      }
    } catch (e) {
      logger.e("refresh token nok");
    }
    _storage.deleteAll();
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  // Get:-----------------------------------------------------------------------
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post:----------------------------------------------------------------------
  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Put:-----------------------------------------------------------------------
  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete:--------------------------------------------------------------------
  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
