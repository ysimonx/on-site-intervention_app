// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'dart:io';

import 'package:dio/dio.dart';

import '../dio_client.dart';
import 'constants.dart';

class LoginApi {
  final DioClient dioClient;

  static const String keyAccessToken = "accessToken";
  static const String keyRefreshToken = "refreshToken";

  LoginApi({required this.dioClient});

  static Future<bool> hasAnAccessToken() async {
    final _storage = const FlutterSecureStorage();
    if (await _storage.containsKey(key: keyAccessToken)) {
      return true;
    }
    return false;
  }

  Future<Response?> listUsers() async {
    try {
      final Response response = await dioClient.get(Endpoints.listUsers);
      print(response.statusCode);
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        return e.response;
      }
      rethrow;
    }
  }

  Future<Response> login(
      {required String email, required String password}) async {
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      var formData = {"email": email, "password": password};
      String json = jsonEncode(formData);

      final Response response = await dioClient.post(
        Endpoints.login,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        String accessToken = response.data["access_token"];
        String refreshToken = response.data["refresh_token"];

        final _storage = const FlutterSecureStorage();
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

  static Future<void> deleteTokens() async {
    final _storage = const FlutterSecureStorage();
    await _storage.delete(key: LoginApi.keyAccessToken);
    await _storage.delete(key: LoginApi.keyRefreshToken);
    await Future.delayed(const Duration(seconds: 2));
    return;
  }
}
