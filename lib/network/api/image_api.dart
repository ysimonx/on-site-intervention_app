// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:convert';
import '../../models/models.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:dio/dio.dart';

import '../dio_client.dart';
import 'constants.dart';

class ImageApi {
  final DioClient dioClient;

  bool isProcessingUpload = false;

  ImageApi({required this.dioClient});

  Future<Response?> uploadImage(
      {required photo_uuid,
      required geste_uuid,
      required field_uuid,
      required filename,
      required latitude,
      required longitude}) async {
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      var formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filename, filename: filename),
        "photo_uuid": photo_uuid,
        "geste_uuid": geste_uuid,
        "field_uuid": field_uuid,
        "latitude": latitude,
        "longitude": longitude,
      });

      final Response response = await dioClient.post(
        Endpoints.uploadImage,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "multipart/form-data",
        }),
        data: formData,
      );
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        if (e.response?.data.contains("photo already uploaded")) {
          return e.response;
        }
      }
      rethrow;
    }
  }

  Future<Response?> isReadyUploadImage() async {
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      final Response response = await dioClient.get(
        Endpoints.readyuploadimage,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  static const String localSubDirectoryUploadImages = 'uploadimages';

  Future<void> processUploadPendingImages() async {
    // VERIFICATION DE LA CONNEXION
    // au passage, si le token doit etre refresh, ca le rafraichit ...
    // parce qu'envoyer un fichier en multipart form data provoque des soucis
    // si on relance la connexion apres un refresh token

    // on parcourt la liste des fichiers à traiter pour l'envoi de photo sur le serveur
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String pathDirectory =
        "${localDirectory.path}/${localSubDirectoryUploadImages}";
    final fileDirectory = Directory(pathDirectory);

    if (!await fileDirectory.exists()) {
      print("processUploadPendingImages : directory not found, aborting ..");
      return;
    }

    List<FileSystemEntity> files = fileDirectory.listSync();

    // si il n'y a pas d'images à envoyer, on revient
    if (files.isEmpty) {
      return;
    }

    // si il a des fichiers à traiter, je regarde d'ab si il est bien possible de se connecter pour les envoyer
    if (files.isNotEmpty) {
      try {
        await isReadyUploadImage();
      } on DioException catch (_) {
        print(
            "processUploadPendingImages pas de connexion : on n'essaye pas d'uploader");

        return;
      } finally {}
    }

    for (var i = 0; i < files.length; i++) {
      var f = File(files[i].path);
      print("uploadPendingImages found : ${f.path}");
      String content = f.readAsStringSync();
      Map<String, dynamic> mapPhoto = jsonDecode(content);
      if (mapPhoto.keys.contains("photo_uuid")) {
        print(mapPhoto.toString());
      }
      if (mapPhoto.keys.contains("location")) {
        print(mapPhoto.toString());
      }
      try {
        Response? resp = await uploadImage(
            photo_uuid: mapPhoto["photo_uuid"],
            geste_uuid: mapPhoto["geste_uuid"],
            field_uuid: mapPhoto["field_uuid"],
            filename: mapPhoto["fileName"],
            latitude: mapPhoto["location"]["latitude"],
            longitude: mapPhoto["location"]["longitude"]);

        if (resp != null) {
          print(resp.statusCode);
          if (resp.statusCode == 201) {
            print("photo uploadee");
            f.deleteSync();
          }
          if (resp.statusCode == 400) {
            String content = resp.data;
            if (content.contains("photo already uploaded")) {
              print("photo déjà uploadee");
              f.deleteSync();
            }
          }
        }
      } on SocketException catch (_) {
        //To handle Socket Exception in case network connection is not available during initiating your network call
        print("soucis de connexion");
      } on DioException catch (_) {
        print(
            "soucis de connexion on saute sans essayer les fichiers suivants");
        break;
      } finally {}
    }
  }

  static Future<void> addUploadPendingImage(String pathImage,
      {required Field field,
      required Geste geste,
      required Beneficiaire beneficiaire,
      required Position position,
      required String photo_uuid}) async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String pathDirectory =
        "${localDirectory.path}/${localSubDirectoryUploadImages}";
    final fileDirectory = Directory(pathDirectory);

    if (!await fileDirectory.exists()) {
      print("uploadPendingImages : directoring not found, creating ..");
      fileDirectory.createSync();
      print("uploadPendingImages : directoring created ..");
    }

    Map<String, dynamic> jsonx = {
      "photo_uuid": photo_uuid,
      "geste_uuid": geste.geste_uuid,
      "field_uuid": field.field_uuid,
      "fileName": pathImage,
      "beneficiaireName": beneficiaire.beneficiaire_name,
      "gesteName": geste.geste_name,
      "fieldName": field.field_name,
      "attendu": field.attendu,
      "commentaire": field.commentaire,
      "location": {
        "longitude": position.longitude,
        "latitude": position.latitude
      }
    };

    String jsonAsString = jsonEncode(jsonx);
    String path = "${pathDirectory}/${photo_uuid}.json";

    // allez, on créé ce fichier
    final file = File(path);
    await file.create();
    await file.writeAsString(jsonAsString);

    return;
  }

  bool isProcessingUploadPendingImages() {
    return isProcessingUpload;
  }
}
