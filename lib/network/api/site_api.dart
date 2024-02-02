import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../models/model_site.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class SiteApi {
  SiteApi();

  DioClient dioClient = DioClient(Dio());

  Future<Site> readSite({required String site_id}) async {
    Site _site = Site(id: site_id, name: "");

    String s = Endpoints.siteRead.replaceAll("<id>", site_id);

    try {
      final Response response = await dioClient.get(s);
      if (response.statusCode == 200) {
        // await writeUserMe(jsonEncode(response.data));
        print(response.statusCode);
        print(response.data);
        Map<String, dynamic> jsonSite = response.data;
        print(jsonSite);
        _site = Site.fromJson(jsonSite);
      }
    } on DioException catch (e) {
      logger.e(e.message);
    }

    return _site;
  }

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

  Future<Response> AddUserRoles(
      {required String site_id,
      required String email,
      required List<String> roles_id}) async {
    try {
      var formData = {"user_email": email, "roles": roles_id};
      String json = jsonEncode(formData);

      String s = Endpoints.addUserRoles.replaceAll("<site_id>", site_id);

      final Response response = await dioClient.post(
        s,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        logger.d("nouveaux roles ajoutés :)");
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        logger.e(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return e.response!;
        }
        if (e.response!.statusCode == 400) {
          return e.response!;
        }
      }
      rethrow;
    }
  }

  Future<Response> RemoveUserRoles(
      {required String site_id, required String email}) async {
    try {
      var formData = {"user_email": email};
      String json = jsonEncode(formData);

      String s = Endpoints.removeUserRoles.replaceAll("<site_id>", site_id);

      final Response response = await dioClient.delete(
        s,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        logger.d("tous les roles ont été supprimés :)");
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        logger.e(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return e.response!;
        }
        if (e.response!.statusCode == 400) {
          return e.response!;
        }
      }
      rethrow;
    }
  }
}
