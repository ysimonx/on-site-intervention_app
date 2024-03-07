// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, empty_statements, unused_import

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_place.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_intervention.dart';
import '../../models/model_site.dart';
import '../../ui/utils/sizes.dart';
import '../../ui/utils/files.dart';
import '../../ui/utils/logger.dart';
import '../../ui/utils/mobilefirst.dart';
import '../dio_client.dart';
import 'constants.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'image.api.dart';

const String DIRINTERVENTIONUPDATED = "interventions_updated";

class InterventionApi {
  InterventionApi();

  DioClient dioClient = DioClient(Dio());

  Map<String, dynamic> mapListInterventionsLastModified = {};
  Map<String, List<dynamic>> mapListInterventionsJson = {};

  Map<String, dynamic> mapListPhotosLastModified = {};

  Future<List<Intervention>> getListInterventions(
      {required Site site, required bool realtime, Place? place}) async {
    dynamic content = null;

    logger.d("ta da getListInterventions 10");

    String lastModified = "";

    if (!isMobileFirst() || realtime == true) {
      try {
        Map<String, String> qParams = {'site_id': site.id};

        final Response response = await dioClient
            .get(Endpoints.listInterventionsValues, queryParameters: qParams);

        if (response.statusCode == 200) {
          content = jsonEncode(response.data);
          response.headers.forEach((name, values) {
            // print("header ${name} = ${values.toString()}");
            if (name == "x-lastmodified") {
              lastModified = values.join(",");
              print(lastModified);
            }
          });
        }
      } on DioException catch (e) {
        if (e.response != null) {
          if (e.response!.statusCode == 401) {
            return [];
          }
          logger.e("getList : ${e.response!.statusCode}");
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }

    logger.d("ta da getListInterventions 30");
    if (content != null) {
      logger.d("ta da getListInterventions 35 -> realtime = true");
      await writeListInterventionValues(site: site, data: content);
    } else {
      logger.d("ta da getListInterventions 35 -> realtime = false");
      content = await readListInterventionValues(site: site);
    }

    logger.d("ta da getListInterventions 40");

    List<Intervention> listInterventionValues = [];

    // ici, ca coute en cpu
    List<dynamic> arrayJsonMobileFirst = [];

    if (mapListInterventionsLastModified.containsKey(site.id)) {
      if (mapListInterventionsLastModified[site.id] != lastModified) {
        arrayJsonMobileFirst = jsonDecode(content);
        mapListInterventionsLastModified[site.id] = lastModified;
        mapListInterventionsJson[site.id] = arrayJsonMobileFirst;
      } else {
        arrayJsonMobileFirst = mapListInterventionsJson[site.id]!;
      }
    } else {
      arrayJsonMobileFirst = jsonDecode(content);
      mapListInterventionsLastModified[site.id] = lastModified;
      mapListInterventionsJson[site.id] = arrayJsonMobileFirst;
    }

    if (isMobileFirst() == false) {
      for (int j = 0; j < arrayJsonMobileFirst.length; j = j + 1) {
        Map<String, dynamic> itemJson = arrayJsonMobileFirst[j];
        Intervention intervention = Intervention.fromJson(itemJson);
        if (place == null) {
          listInterventionValues.add(intervention);
        } else {
          if (place.id == intervention.place.id) {
            listInterventionValues.add(intervention);
          }
        }
      }
      return listInterventionValues;
    }

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
          logger.d(
              "ta da intervention.version > interventionNew.version deleting local file");
        } else {
          // l'intervention en local est plus récente que celle du serveur
          // je peux écraser celle du serveur par celle en local
          intervention = interventionNew;
          logger.d(
              "ta da ${intervention.intervention_name} -> ${interventionNew.intervention_name}");

          // logger.i(
          //     "ta da ${intervention.field_on_site_uuid_values['36448a1b-3f11-463a-bf60-7668f32da094']} vs ${interventionNew.field_on_site_uuid_values['36448a1b-3f11-463a-bf60-7668f32da094']}");
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
    logger.d("ta da getListInterventions 50");
    listInterventionValues = completeListWithLocalUpdatedFiles(
        list: listInterventionValues,
        localFiles: listLocalUpdatedFiles,
        site: site);

    logger.d("ta da getListInterventions 60");
    if (place == null) {
      return listInterventionValues;
    } else {
      List<Intervention> list2 = [];
      for (var i = 0; i < listInterventionValues.length; i++) {
        Intervention intervention = listInterventionValues[i];
        if (place.id == intervention.place.id) {
          list2.add(intervention);
        }
      }
      return list2;
    }
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
      if (e.response?.statusCode == 500) {
        rethrow;
      }
    } catch (e) {
      logger.e("postInterventionOnServer :${e.toString()}");
      rethrow;
    }
    return null;
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

  static Future<List<FileSystemEntity>> deleteLocalUpdatedFiles() async {
    String path = await localPath;

    try {
      Directory d = Directory("$path/$DIRINTERVENTIONUPDATED/");

      List<FileSystemEntity> list = Directory(d.path).listSync();
      for (var i = 0; i < list.length; i++) {
        FileSystemEntity f = list[i];
        if (f is File) {
          f.deleteSync();
          list.remove(f);
        }
      }
      return list;
      // return [];
    } on Exception catch (_) {
      List<FileSystemEntity> list = [];
      return list;
    }
  }

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

  Future<int> uploadInterventions() async {
    int nbInterventionsUploaded = 0;

    List<FileSystemEntity> listLocalUpdatedFiles = await getLocalUpdatedFiles();

    for (var j = 0; j < listLocalUpdatedFiles.length; j++) {
      FileSystemEntity f = listLocalUpdatedFiles[j];

      // Read the file
      if (f is File) {
        try {
          String contents = await f.readAsString();
          Map<String, dynamic> contentJson = jsonDecode(contents);
          Intervention i = Intervention.fromJson(contentJson);
          var r = await postInterventionValuesOnServer(i);
          logger.d(r.toString());
          logger.d("ta da uploadInterventions done");
          nbInterventionsUploaded++;
        } catch (e) {
          logger.d("ta da uploadInterventions failed, deleting file");
          await f.delete();
        }
      }
    }

    return nbInterventionsUploaded;
  }

  localUpdatedFileDelete({required Intervention intervention}) async {
    final file = await getlocalUpdatedFile(intervention: intervention);
    if (await file.exists()) {
      logger.d("ta da efface local file ${file.path}");
      file.deleteSync();
    }
  }

  /*
          [
            {
                "photos": [
                    "f16153e0-e299-1eb7-946b-856e67bf256d.jpg"
                ],
                "site_id": "8abf0be4-e217-4678-9644-ed68e7b8b158"
            },
            {
                "photos": [
  */

  Future<void> downloadPhotos({required Site site}) async {
    List<String> photosToDownload = [];
    String lastModified = "";

    try {
      Map<String, String> qParams = {'site_id': site.id};

      final Response response = await dioClient.get(
          Endpoints.listInterventionsValuesPhotos,
          queryParameters: qParams);

      if (response.statusCode == 200) {
        response.headers.forEach((name, values) {
          // print("header ${name} = ${values.toString()}");
          if (name == "x-lastmodified") {
            lastModified = values.join(",");
            print(lastModified);
          }
        });
        if (site.name == "sandbox") {
          print("to");
        }

        if (lastModified != "") {
          if (mapListPhotosLastModified.containsKey(site.id)) {
            if (mapListPhotosLastModified[site.id] == lastModified) {
              return;
            }
          }
        }

        if (site.name == "sandbox") {
          print("to");
        }
        List<dynamic> list = response.data;
        for (var i = 0; i < list.length; i++) {
          Map<String, dynamic> jsonItem = list[i];
          List<dynamic> photos = jsonItem["photos"];
          for (var j = 0; j < photos.length; j++) {
            String photo = photos[j];

            photosToDownload.add(photo);
          }
        }
        if (site.name == "sandbox") {
          print("to");
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          return;
        }
        logger.e("downloadPhotos : ${e.response!.statusCode}");
      }
    } catch (e) {
      logger.e(e.toString());
    }

    if (photosToDownload.isNotEmpty) {
      ImageApi.syncImages(
          list: photosToDownload,
          onSuccess: () {
            mapListPhotosLastModified[site.id] = lastModified;
          });

      print(photosToDownload);
    }
  }
}
