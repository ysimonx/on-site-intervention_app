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

  Future<List<Intervention>> getList(
      {required Organization organization}) async {
    try {
      Map<String, String> qParams = {'organization_id': organization.id};

      final Response response = await dioClient.get(Endpoints.interventionsList,
          queryParameters: qParams);

      if (response.statusCode == 200) {
        List<Intervention> list = [];
        return list;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return [];
        }
      }
      rethrow;
    }

    return [];
  }
}
