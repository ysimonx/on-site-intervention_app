// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../dio_client.dart';
import 'constants.dart';

class LoginApi {
  static const String keyAccessToken = "accessToken";
  static const String keyRefreshToken = "refreshToken";

  var accessToken;
  var refreshToken;

  late FlutterSecureStorage _storage;

  LoginApi() {
    _storage = const FlutterSecureStorage();
  }

  DioClient dioClient = DioClient(Dio());

  Future<bool> hasAnAccessToken() async {
    if (await _storage.containsKey(key: keyAccessToken)) {
      return true;
    }
    return false;
  }

  Future<Response> login(
      {required String email, required String password}) async {
    try {
      var formData = {
        "email": email,
        "password": password,
        "tenant_id": "fidwork"
      };
      String json = jsonEncode(formData);

      final Response response = await dioClient.post(
        Endpoints.login,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        accessToken = response.data["access_token"];
        refreshToken = response.data["refresh_token"];
        print(accessToken);
        print(refreshToken);

        await _storage.write(key: keyAccessToken, value: accessToken);
        await _storage.write(key: keyRefreshToken, value: refreshToken);
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return e.response!;
        }
      }
      rethrow;
    }
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: LoginApi.keyAccessToken);
    await _storage.delete(key: LoginApi.keyRefreshToken);
    return;
  }
}
