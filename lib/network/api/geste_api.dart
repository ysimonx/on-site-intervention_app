// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, non_constant_identifier_names

// ignore: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../dio_client.dart';

import 'constants.dart';

class GesteApi {
  final DioClient dioClient;

  GesteApi({required this.dioClient});

  Future<Response?> sendGeste({
    required String beneficiaire_id,
    required String beneficiaire_name,
    required String geste_uuid,
    required String geste_name,
    required dynamic gestes,
  }) async {
    var formData = {
      "beneficiaire_uuid": beneficiaire_id,
      "beneficiaire_name": beneficiaire_name,
      "geste_uuid": geste_uuid,
      "geste_name": geste_name,
      "formulaires": [],
    };

    var listFormulaires = [];

    for (var i = 0; i < gestes.length; i++) {
      Map<String, dynamic> geste = gestes[i];
      print(geste.toString());
      if (geste["geste_uuid"] == geste_uuid) {
        var formulaires = geste["formulaires"];
        for (var j = 0; j < formulaires.length; j++) {
          Map<String, dynamic> formulaire = formulaires[j];
        }
      }
    }

    formData["formulaires"] = listFormulaires;

    print(formData);
    String json = jsonEncode(formData);

    try {
      final Response response = await dioClient.post(
        Endpoints.uploadGeste,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );
      return response;
    } on DioException catch (e) {
      print(e.response?.statusCode);

      rethrow;
    }
  }

  Future<Response?> processDownloadBackOfficeFeedback(
      List<String> listGestesUuidForBackOfficeFeedback) async {
    print(listGestesUuidForBackOfficeFeedback.length);
    print("processDownloadBackOfficeFeedback call");
    List<Map<String, String>> gestes = [];
    for (var i = 0; i < listGestesUuidForBackOfficeFeedback.length; i++) {
      gestes.add({"geste_uuid": listGestesUuidForBackOfficeFeedback[i]});
    }
    print(gestes);
    Map<String, dynamic> data = {"gestes": gestes};
    String json = jsonEncode(data);
    print(json);
    try {
      final Response response = await dioClient.post(
        Endpoints.downloadBackOfficeFeedBack,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );
      print(response.statusCode);
      return response;
    } on DioException catch (e) {
      print(e.response?.statusCode);

      /* if (e.response?.statusCode == 400) {
        if (e.response?.data.contains("photo already uploaded")) {
          return e.response;
        }
      }*/
      rethrow;
    }
  }
}
