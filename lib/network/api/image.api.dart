import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/model_field.dart';
import '../../ui/utils/logger.dart';
import '../../ui/widget/gallery.dart';
import '../dio_client.dart';
import 'constants.dart';

class ImageApi {
  final DioClient dioClient;

  bool isProcessingUpload = false;

  ImageApi({required this.dioClient});

  Future<Response?> uploadImage(
      {required photo_uuid,
      required filename,
      required latitude,
      required longitude}) async {
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      var directory = await getApplicationDocumentsDirectory();
      var formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
            Platform.isIOS ? getImagePathiOS(directory, filename) : filename,
            filename: filename),
        "photo_uuid": photo_uuid,
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
      logger.d("processUploadPendingImages : directory not found, aborting ..");
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
        logger.d(
            "processUploadPendingImages pas de connexion : on n'essaye pas d'uploader");

        return;
      } finally {}
    }

    for (var i = 0; i < files.length; i++) {
      var f = File(files[i].path);
      logger.d("uploadPendingImages found : ${f.path}");
      String content = f.readAsStringSync();
      Map<String, dynamic> mapPhoto = jsonDecode(content);
      if (mapPhoto.keys.contains("photo_uuid")) {
        logger.d(mapPhoto.toString());
      }
      if (mapPhoto.keys.contains("location")) {
        logger.d(mapPhoto.toString());
      }
      try {
        Response? resp = await uploadImage(
            photo_uuid: mapPhoto["photo_uuid"],
            filename: mapPhoto["fileName"],
            latitude: mapPhoto["location"]["latitude"],
            longitude: mapPhoto["location"]["longitude"]);

        if (resp != null) {
          logger.d(resp.statusCode);
          if (resp.statusCode == 201) {
            logger.d("photo uploadee");
            f.deleteSync();
          }
          if (resp.statusCode == 400) {
            String content = resp.data;
            if (content.contains("photo already uploaded")) {
              logger.d("photo déjà uploadee");
              f.deleteSync();
            }
          }
        }
      } on SocketException catch (_) {
        //To handle Socket Exception in case network connection is not available during initiating your network call
        logger.d("soucis de connexion");
      } on DioException catch (_) {
        logger.d(
            "soucis de connexion on saute sans essayer les fichiers suivants");
        break;
      } finally {}
    }
  }

  static Future<void> addUploadPendingImage(String pathImage,
      {required Field field,
      required Position position,
      required String photo_uuid}) async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String pathDirectory =
        "${localDirectory.path}/${localSubDirectoryUploadImages}";
    final fileDirectory = Directory(pathDirectory);

    if (!await fileDirectory.exists()) {
      logger.d("uploadPendingImages : directoring not found, creating ..");
      fileDirectory.createSync();
      logger.d("uploadPendingImages : directoring created ..");
    }

    Map<String, dynamic> jsonx = {
      "photo_uuid": photo_uuid,
      "fileName": pathImage,
      "fieldName": field.field_name,
      "location": {
        "longitude": position.longitude,
        "latitude": position.latitude
      }
    };

    String jsonAsString = jsonEncode(jsonx);
    String path = "${pathDirectory}/${photo_uuid}.json";

    final file = File(path);
    await file.create();
    await file.writeAsString(jsonAsString);

    return;
  }

  bool isProcessingUploadPendingImages() {
    return isProcessingUpload;
  }
}
