// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';

import '../../models/model_intervention.dart';
import '../dio_client.dart';
import 'constants.dart';

class InterventionApi {
  InterventionApi();

  DioClient dioClient = DioClient(Dio());

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

      if (response.statusCode == 200) {}

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

  Future<List<Intervention>> getList(
      {required Organization organization}) async {
    List<Intervention> list = [];
    return list;
  }
}
