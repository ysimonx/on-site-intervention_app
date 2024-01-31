import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class SiteApi {
  SiteApi();

  DioClient dioClient = DioClient(Dio());

  Future<Response> AddNewSite(
      {required String site_name, required String tenant_id}) async {
    try {
      var formData = {"site_name": site_name, "tenant_id": tenant_id};
      String json = jsonEncode(formData);

      final Response response = await dioClient.post(
        Endpoints.postSite,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 201) {
        logger.d("nouveau site ajouté :)");
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        logger.e(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return e.response!;
        }
      }
      rethrow;
    }
  }
}
