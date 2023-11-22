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

  LoginApi();
  DioClient dioClient = DioClient(Dio());

  static Future<bool> hasAnAccessToken() async {
    const storage = FlutterSecureStorage();
    if (await storage.containsKey(key: keyAccessToken)) {
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

        const storage = FlutterSecureStorage();
        await storage.write(key: keyAccessToken, value: accessToken);
        await storage.write(key: keyRefreshToken, value: refreshToken);
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
    const storage = FlutterSecureStorage();
    await storage.delete(key: LoginApi.keyAccessToken);
    await storage.delete(key: LoginApi.keyRefreshToken);
    return;
  }
}
