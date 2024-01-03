// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, empty_statements

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';
import 'package:on_site_intervention_app/ui/utils/sizes.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_intervention.dart';
import '../../ui/utils/logger.dart';
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

      final Response response = await dioClient
          .get(Endpoints.listInterventionsValues, queryParameters: qParams);

      if (response.statusCode == 200) {
        await writeInterventionsList(
            organization: organization, jsonEncode(response.data));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          return [];
        }
        logger.e("getList : ${e.response!.statusCode}");
      }
    }

    // returns data already downloaded, even in mobile-first Mode
    dynamic content =
        await readListInterventionValues(organization: organization);
    List<dynamic> arrayJsonLastDownloadedListInterventionValues =
        jsonDecode(content);
    List<Intervention> listInterventionValues = [];

    List<FileSystemEntity> listLocalUpdatedFiles = await getLocalUpdatedFiles();

    for (var i = 0;
        i < arrayJsonLastDownloadedListInterventionValues.length;
        i++) {
      Map<String, dynamic> itemJson =
          arrayJsonLastDownloadedListInterventionValues[i];

      Intervention intervention = Intervention.fromJson(itemJson);

      // au cas où une intervention est sauvegardée en local
      // elle doit écraser celle qui a été téléchargée du web
      if (await localUpdatedFileExists(intervention: intervention)) {
        Intervention intervention_new =
            await localUpdatedFileRead(intervention: intervention);

        // TODO : si c'est la meme version, je peux supprimer le fichier en local
        logger.d("${intervention.version} vs ${intervention_new.version}");
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
          if (f.path.endsWith(
              "${intervention.intervention_values_on_site_uuid}.json")) {
            listLocalUpdatedFiles
                .removeAt(j); // the only items remaining will be new ones
          }
        }
      }
      listInterventionValues.add(intervention);
    }

    listInterventionValues = completeListWithLocalUpdatedFiles(
        list: listInterventionValues,
        localFiles: listLocalUpdatedFiles,
        organization: organization);

    return listInterventionValues;
  }

  Future<Response?> postInterventionValuesOnServer(
      Intervention intervention) async {
    Map<String, dynamic> data = intervention.toJSON();
    String json = jsonEncode(data);

    logger.d("postInterventionOnServer : ${json}");

    try {
      final Response response = await dioClient.post(
        Endpoints.postInterventionValues,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );
      logger.d("postInterventionOnServer :${response.statusCode}");
      return response;
    } on DioException catch (e) {
      logger.e("postInterventionOnServer :${e.response?.statusCode}");
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

  Future<String> readListInterventionValues(
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
        '$path/$dir_intervention_updated/intervention_${intervention.intervention_values_on_site_uuid}.json';
    return File(pathfile);
  }

  //
  Future<List<FileSystemEntity>> getLocalUpdatedFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;

    try {
      Directory d = Directory("$directory/$dir_intervention_updated/");

      List<FileSystemEntity> list = Directory(d.path).listSync();
      for (var i = 0; i < list.length; i++) {
        FileSystemEntity f = list[i];
        if (f is File) {
          // f.deleteSync();
          // list.remove(f);
        }
      }
      return list;
      // return [];
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
      logger.d(data);
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
      required List<FileSystemEntity> localFiles,
      required Organization organization}) {
    // add local interventions to list
    // that are not uploaded yet :
    //
    // if they match the "organization", these are new ones

    for (var j = 0; j < localFiles.length; j++) {
      FileSystemEntity f = localFiles[j];
      if (f is File) {
        // f.deleteSync();
        String contents = (f).readAsStringSync();
        Map<String, dynamic> contentJson = jsonDecode(contents);
        Intervention intervention = Intervention.fromJson(contentJson);
        if (intervention.organization_id == organization.id) {
          list.add(intervention);
        }
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
        var r = await postInterventionValuesOnServer(i);
        logger.d(r.toString());
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
