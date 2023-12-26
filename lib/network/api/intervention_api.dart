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

    // returns data already downloaded, even in mobile-first Mode
    dynamic content = await readInterventionsList(organization: organization);
    List<dynamic> arrayLastDownloadedListJson = jsonDecode(content);
    List<Intervention> listInterventions = [];

    List<FileSystemEntity> listLocalFiles =
        await getLocalSavedInterventionsList();

    for (var i = 0; i < arrayLastDownloadedListJson.length; i++) {
      Map<String, dynamic> itemJson = arrayLastDownloadedListJson[i];

      Intervention intervention = Intervention.fromJson(itemJson);

      // au cas où une intervention est sauvegardée en local
      // elle doit écraser celle qui a été téléchargée du web
      if (await localExists(intervention: intervention)) {
        intervention = await localRead(intervention: intervention);
        for (var j = 0; j < listLocalFiles.length; j++) {
          FileSystemEntity f = listLocalFiles[j];
          if (f.path.endsWith("${intervention.id}.json")) {
            listLocalFiles
                .removeAt(j); // the only items remaining will be new ones
          }
        }
      }
      listInterventions.add(intervention);
    }

    listInterventions = completeListWithNewOnes(
        list: listInterventions, localFiles: listLocalFiles);

    return listInterventions;
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
    String pathfile =
        '$path/interventions/intervention_${intervention.id}.json';
    return File(pathfile);
  }

  Future<File> writeInterventionsList(String data,
      {required Organization organization}) async {
    final file = await getlocalFileList(organization: organization);

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create(recursive: true);
      ;
    }

    // Write the file
    return file.writeAsString(data);
  }

  //
  Future<List<FileSystemEntity>> getLocalSavedInterventionsList() async {
    String directory = (await getApplicationDocumentsDirectory()).path;

    List<FileSystemEntity> list =
        Directory("$directory/interventions/").listSync();
    // .listSync(); //use your folder name insted of resume.
    return list;
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
      var s = file.lengthSync();
      print(s);
      if (s == 0) {
        file.deleteSync();
        return false;
      }
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

  List<Intervention> completeListWithNewOnes(
      {required List<Intervention> list,
      required List<FileSystemEntity> localFiles}) {
    // add local interventions not uploaded yet : these are the new ones
    for (var j = 0; j < localFiles.length; j++) {
      FileSystemEntity f = localFiles[j];
      if (f is File) {
        String contents = (f).readAsStringSync();
        Map<String, dynamic> contentJson = jsonDecode(contents);
        Intervention intervention = Intervention.fromJson(contentJson);
        list.add(intervention);
      }
    }
    return list;
  }
}
