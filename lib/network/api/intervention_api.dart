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
  InterventionApi();

  DioClient dioClient = DioClient(Dio());

  Future<List<Intervention>> getList(
      {required Organization organization}) async {
    try {
      Map<String, String> qParams = {'organization_id': organization.id};

      final Response response = await dioClient.get(Endpoints.interventionsList,
          queryParameters: qParams);

      if (response.statusCode == 200) {
        await writeInterventionsList(
            organization: organization, jsonEncode(response.data));
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
    dynamic content = await readInterventionsList(organization: organization);
    List<dynamic> arrayJson = jsonDecode(content);

    List<Intervention> list = [];
    for (var i = 0; i < arrayJson.length; i++) {
      Map<String, dynamic> itemJson = arrayJson[i];

      Intervention intervention = Intervention.fromJson(itemJson);
      if (await localExists(intervention: intervention)) {
        intervention = await localRead(intervention: intervention);
      }

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

  Future<File> getlocalFileList({required Organization organization}) async {
    final path = await _localPath;
    String pathfile = '$path/interventions_${organization.name}.json';
    return File(pathfile);
  }

  Future<File> getlocalFile({required Intervention intervention}) async {
    final path = await _localPath;
    String pathfile = '$path/intervention_${intervention.id}.json';
    return File(pathfile);
  }

  Future<File> writeInterventionsList(String data,
      {required Organization organization}) async {
    final file = await getlocalFileList(organization: organization);

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create();
    }

    // Write the file
    return file.writeAsString(data);
  }

  Future<String> readInterventionsList(
      {required Organization organization}) async {
    try {
      final file = await getlocalFileList(organization: organization);

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ""
      return "";
    }
  }

  Future<void> localSave({required Intervention intervention}) async {
    try {
      final file = await getlocalFile(intervention: intervention);
      String data = jsonEncode(intervention.toJSON());
      file.writeAsString(data);
      return;
    } catch (e) {
      // If encountering an error, return ""
      return;
    }
  }

  Future<bool> localExists({required Intervention intervention}) async {
    final file = await getlocalFile(intervention: intervention);
    if (await file.exists()) {
      return true;
    }
    return false;
  }

  Future<Intervention> localRead({required Intervention intervention}) async {
    try {
      final file = await getlocalFile(intervention: intervention);
      // Read the file
      String contents = await file.readAsString();

      Map<String, dynamic> contentJson = jsonDecode(contents);
      Intervention i = Intervention.fromJson(contentJson);

      return i;
    } catch (e) {
      rethrow;
    }
  }
}
