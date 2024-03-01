// ignore_for_file: unused_import

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/ui/lists_for_places_page.dart';

import '../../models/model_lists_for_places.dart';
import '../../models/model_site.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class SiteApi {
  SiteApi();

  DioClient dioClient = DioClient(Dio());

  Future<Site> readSite({required String idSite}) async {
    Site site = Site(id: idSite, name: "");

    String s = Endpoints.siteRead.replaceAll("<id>", idSite);

    try {
      final Response response = await dioClient.get(s);
      if (response.statusCode == 200) {
        // await writeUserMe(jsonEncode(response.data));
        Map<String, dynamic> jsonSite = response.data;
        site = Site.fromJson(jsonSite);
      }
    } on DioException catch (e) {
      logger.e(e.message);
    }

    return site;
  }

  Future<Response> addNewSite(
      {required String siteName, required String idTenant}) async {
    try {
      var formData = {"site_name": siteName, "tenant_id": idTenant};
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

  Future<Response> addUserRoles(
      {required String idSite,
      required String email,
      required List<String> idsRoles}) async {
    try {
      var formData = {"user_email": email, "roles": idsRoles};
      String json = jsonEncode(formData);

      String s = Endpoints.addUserRoles.replaceAll("<site_id>", idSite);

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

  Future<Response> removeUserRoles(
      {required String idSite, required String email}) async {
    try {
      var formData = {"user_email": email};
      String json = jsonEncode(formData);

      String s = Endpoints.removeUserRoles.replaceAll("<site_id>", idSite);

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

  Future<Response> updateSiteLists(
      {required String idSite,
      required Map<String, dynamic> dictOfLists}) async {
    try {
      var formData = {"dict_of_lists": dictOfLists};
      String json = jsonEncode(formData);

      String s = Endpoints.updateLists.replaceAll("<site_id>", idSite);

      final Response response = await dioClient.post(
        s,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        logger.d("toutes les listes ont été mises à jour :)");
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

  static Future<Response> updateSiteListsForPlaces(
      {required String idSite,
      required ListsForPlaces lists_for_places}) async {
    try {
      DioClient dioClient = DioClient(Dio());

      var formData = {"dict_of_lists_for_places": lists_for_places.toJSON()};
      String json = jsonEncode(formData);

      String s = Endpoints.updateListsForPlaces.replaceAll("<site_id>", idSite);

      final Response response = await dioClient.post(
        s,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );

      if (response.statusCode == 200) {
        logger.d("toutes les listes for places ont été mises à jour :)");
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
