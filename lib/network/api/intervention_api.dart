// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, empty_statements

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_intervention.dart';
import '../dio_client.dart';
import 'constants.dart';

const String dir_intervention_updated = "interventions_updated";

class InterventionApi {
  InterventionApi();

  DioClient dioClient = DioClient(Dio());

  Future<List<Intervention>> getList(
      {required Organization organization}) async {
    try {
      Map<String, String> qParams = {'organization_id': organization.id};

      final Response response = await dioClient.get(Endpoints.listInterventions,
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

    List<FileSystemEntity> listLocalUpdatedFiles = await getLocalUpdatedFiles();

    for (var i = 0; i < arrayLastDownloadedListJson.length; i++) {
      Map<String, dynamic> itemJson = arrayLastDownloadedListJson[i];

      Intervention intervention = Intervention.fromJson(itemJson);

      // au cas où une intervention est sauvegardée en local
      // elle doit écraser celle qui a été téléchargée du web
      if (await localUpdatedFileExists(intervention: intervention)) {
        Intervention intervention_new =
            await localUpdatedFileRead(intervention: intervention);

        // TODO : si c'est la meme version, je peux supprimer le fichier en local
        print("${intervention.version} vs ${intervention_new.version}");
        if (intervention.version > intervention_new.version) {
          // l'intervention en local est plus ancienne que celle du serveur
          // je peux supprimer l'intervention enregistrée en local
          await localUpdatedFileDelete(intervention: intervention);
        } else {
          // l'intervention en local est plus récente que celle du serveur
          // je peux écraser celle du serveur par celle en local
          intervention = intervention_new;
        }

        // et je supprime l'entrée dans listLocalFiles
        // pour ne garder que les interventions qui ont été créées
        // en local seulement
        for (var j = 0; j < listLocalUpdatedFiles.length; j++) {
          FileSystemEntity f = listLocalUpdatedFiles[j];
          if (f.path
              .endsWith("${intervention.intervention_on_site_uuid}.json")) {
            listLocalUpdatedFiles
                .removeAt(j); // the only items remaining will be new ones
          }
        }
      }
      listInterventions.add(intervention);
    }

    listInterventions = completeListWithLocalUpdatedFiles(
        list: listInterventions, localFiles: listLocalUpdatedFiles);

    return listInterventions;
  }

  Future<Response?> postIntervention(Intervention intervention) async {
    Map<String, dynamic> data = intervention.toJSON();
    String json = jsonEncode(data);
    print(json);

    try {
      final Response response = await dioClient.post(
        Endpoints.postIntervention,
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getlocalFileList({required Organization organization}) async {
    final path = await _localPath;
    String pathfile = '$path/interventions_${organization.name}.json';
    return File(pathfile);
  }

  Future<File> writeInterventionsList(String data,
      {required Organization organization}) async {
    final file = await getlocalFileList(organization: organization);

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create(recursive: true);
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

  Future<File> getlocalUpdatedFile({required Intervention intervention}) async {
    final path = await _localPath;
    String pathfile =
        '$path/$dir_intervention_updated/intervention_${intervention.intervention_on_site_uuid}.json';
    return File(pathfile);
  }

  //
  Future<List<FileSystemEntity>> getLocalUpdatedFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;

    try {
      Directory d = Directory("$directory/$dir_intervention_updated/");

      List<FileSystemEntity> list = Directory(d.path).listSync();
      return list;
    } on Exception catch (_) {
      List<FileSystemEntity> list = [];
      return list;
    }
  }

  Future<void> localUpdatedFileSave(
      {required Intervention intervention}) async {
    try {
      final file = await getlocalUpdatedFile(intervention: intervention);
      String data = jsonEncode(intervention.toJSON());
      if (!await file.exists()) {
        // read the file from assets first and create the local file with its contents
        await file.create(recursive: true);
      }
      file.writeAsString(data);
      return;
    } catch (e) {
      // If encountering an error, return ""
      return;
    }
  }

  Future<bool> localUpdatedFileExists(
      {required Intervention intervention}) async {
    final file = await getlocalUpdatedFile(intervention: intervention);
    if (await file.exists()) {
      var s = file.lengthSync();
      if (s == 0) {
        file.deleteSync();
        return false;
      }
      return true;
    }
    return false;
  }

  Future<Intervention> localUpdatedFileRead(
      {required Intervention intervention}) async {
    try {
      final file = await getlocalUpdatedFile(intervention: intervention);
      // Read the file
      String contents = await file.readAsString();

      Map<String, dynamic> contentJson = jsonDecode(contents);
      Intervention i = Intervention.fromJson(contentJson);

      return i;
    } catch (e) {
      rethrow;
    }
  }

  List<Intervention> completeListWithLocalUpdatedFiles(
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

  syncLocalUpdatedFiles() async {
    List<FileSystemEntity> listLocalUpdatedFiles = await getLocalUpdatedFiles();

    for (var j = 0; j < listLocalUpdatedFiles.length; j++) {
      FileSystemEntity f = listLocalUpdatedFiles[j];

      // Read the file
      if (f is File) {
        String contents = await f.readAsString();
        Map<String, dynamic> contentJson = jsonDecode(contents);
        Intervention i = Intervention.fromJson(contentJson);
        var r = await postIntervention(i);
        print(r.toString());
      }
    }
  }

  localUpdatedFileDelete({required Intervention intervention}) async {
    final file = await getlocalUpdatedFile(intervention: intervention);
    if (await file.exists()) {
      file.deleteSync();
    }
  }
}
