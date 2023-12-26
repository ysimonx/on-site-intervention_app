// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_intervention.dart';
import '../dio_client.dart';
import 'constants.dart';

class InterventionApi {
  InterventionApi({required this.organization});

  DioClient dioClient = DioClient(Dio());

  final Organization organization;

  Future<List<Intervention>> getList() async {
    try {
      Map<String, String> qParams = {'organization_id': organization.id};

      final Response response = await dioClient.get(Endpoints.interventionsList,
          queryParameters: qParams);

      if (response.statusCode == 200) {
        await writeInterventionsList(jsonEncode(response.data));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        if (e.response!.statusCode == 401) {
          return [];
        }
      }
    }
    // return data already downloaded, even in mobile-first Mode
    dynamic content = await readInterventionsList();
    List<dynamic> arrayJson = jsonDecode(content);

    List<Intervention> list = [];
    for (var i = 0; i < arrayJson.length; i++) {
      Map<String, dynamic> itemJson = arrayJson[i];
      Intervention intervention = Intervention.fromJson(itemJson);
      //id: itemJson["id"], name: itemJson["name"]);
      list.add(intervention);
    }
    // User me = User.fromJson(contentJson);
    // return me;

    return list;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/organization_.json');
  }

  Future<String> readUserMe() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ""
      return "";
    }
  }

  Future<File> writeInterventionsList(String data) async {
    final file = await _localFile;

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create();
    }

    // Write the file
    return file.writeAsString(data);
  }

  Future<String> readInterventionsList() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ""
      return "";
    }
  }
}
