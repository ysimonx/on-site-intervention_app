// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, empty_statements, unused_import

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/ui/utils/sizes.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_intervention.dart';
import '../../ui/utils/files.dart';
import '../../ui/utils/logger.dart';
import '../../ui/utils/mobilefirst.dart';
import '../dio_client.dart';
import 'constants.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

const String DIRINTERVENTIONUPDATED = "interventions_updated";

class InterventionApi {
  InterventionApi();

  DioClient dioClient = DioClient(Dio());

  Future<List<Intervention>> getList({required Site site}) async {
    dynamic content = null;

    try {
      Map<String, String> qParams = {'site_id': site.id};

      final Response response = await dioClient
          .get(Endpoints.listInterventionsValues, queryParameters: qParams);

      if (response.statusCode == 200) {
        content = jsonEncode(response.data);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          return [];
        }
        logger.e("getList : ${e.response!.statusCode}");
      }
    } catch (e) {
      logger.e("${e.toString()}");
    }

    if (!isMobileFirst()) {
      List<Intervention> listInterventionValues = [];
      List<dynamic> arrayJson = jsonDecode(content);
      for (var i = 0; i < arrayJson.length; i++) {
        Map<String, dynamic> itemJson = arrayJson[i];

        Intervention intervention = Intervention.fromJson(itemJson);
        listInterventionValues.add(intervention);
      }
      return listInterventionValues;
    }

    // mobile first ! : save content from API if not empty
    if (content != null) {
      await writeListInterventionValues(site: site, data: content);
    } else {
      content = await readListInterventionValues(site: site);
    }

    List<Intervention> listInterventionValues = [];

    List<dynamic> arrayJsonMobileFirst = jsonDecode(content);

    List<FileSystemEntity> listLocalUpdatedFiles = await getLocalUpdatedFiles();

    for (var i = 0; i < arrayJsonMobileFirst.length; i++) {
      Map<String, dynamic> itemJson = arrayJsonMobileFirst[i];
      Intervention intervention = Intervention.fromJson(itemJson);

      // au cas où une intervention EXISTANTE est aussi sauvegardée en local
      // elle doit écraser celle qui a été téléchargée du web
      if (await localUpdatedFileExists(intervention: intervention)) {
        Intervention interventionNew =
            await localUpdatedFileRead(intervention: intervention);

        // si c'est la meme version, je peux supprimer le fichier en local
        logger.d("${intervention.version} vs ${interventionNew.version}");
        if (intervention.version > interventionNew.version) {
          // l'intervention en local est plus ancienne que celle du serveur
          // je peux supprimer l'intervention enregistrée en local
          await localUpdatedFileDelete(intervention: intervention);
        } else {
          // l'intervention en local est plus récente que celle du serveur
          // je peux écraser celle du serveur par celle en local
          intervention = interventionNew;
        }

        // Enfin je supprime l'entrée dans listLocalFiles
        // pour ne garder que les NOUVELLES interventions (qui ne sont pas encore créées sur le serveur)
        // qui ont été créées  en local seulement

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
        site: site);

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
    } catch (e) {
      logger.e("postInterventionOnServer :${e.toString()}");
      rethrow;
    }
  }

  Future<File> getlocalFileList({required Site site}) async {
    final path = await localPath;
    String pathfile = '$path/interventions_${site.name}.json';
    return File(pathfile);
  }

  Future<File> writeListInterventionValues(
      {required String data, required Site site}) async {
    final file = await getlocalFileList(site: site);

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create(recursive: true);
    }
    // Write the file
    return file.writeAsString(data);
  }

  Future<String> readListInterventionValues({required Site site}) async {
    try {
      final file = await getlocalFileList(site: site);

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ""
      return "";
    }
  }

  Future<File> getlocalUpdatedFile({required Intervention intervention}) async {
    final path = await localPath;
    String pathfile =
        '$path/$DIRINTERVENTIONUPDATED/intervention_${intervention.intervention_values_on_site_uuid}.json';
    return File(pathfile);
  }

  //
  Future<List<FileSystemEntity>> getLocalUpdatedFiles() async {
    String path = await localPath;

    try {
      Directory d = Directory("$path/$DIRINTERVENTIONUPDATED/");

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
      required Site site}) {
    // add local interventions to list
    // that are not uploaded yet :
    //
    // if they match the "site", these are new ones

    for (var j = 0; j < localFiles.length; j++) {
      FileSystemEntity f = localFiles[j];
      if (f is File) {
        // f.deleteSync();
        String contents = (f).readAsStringSync();
        Map<String, dynamic> contentJson = jsonDecode(contents);
        Intervention intervention = Intervention.fromJson(contentJson);
        if (intervention.site_id == site.id) {
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
