import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class ImageApi {
  final DioClient dioClient;

  bool isProcessingUpload = false;

  ImageApi({required this.dioClient});

  static Future<Response?> uploadImage(
      {required filename,
      required latitude,
      required longitude,
      required photo_on_site_uuid,
      required field_on_site_uuid}) async {
    DioClient dioClient = DioClient(Dio());
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      var directory = await ImageApi.getPendingUploadImageAbsoluteDirectory();
      String filePath = "${directory.path}/$filename";
      var formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: filename),
        "photo_on_site_uuid": photo_on_site_uuid,
        "field_on_site_uuid": field_on_site_uuid,
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

  static Future<Response?> isReadyUploadImage() async {
    // TO DO : https://kashifchandio.medium.com/upload-images-to-rest-api-with-flutter-using-dio-package-421111389c27
    try {
      DioClient dioClient = DioClient(Dio());

      final Response response = await dioClient.get(
        Endpoints.readyuploadimage,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  static const String localSubDirectoryUploadImages = 'uploadimages';

  static Future<void> processUploadPendingImages() async {
    // VERIFICATION DE LA CONNEXION
    // au passage, si le token doit etre refresh, ca le rafraichit ...
    // parce qu'envoyer un fichier en multipart form data provoque des soucis
    // si on relance la connexion apres un refresh token

    // on parcourt la liste des fichiers à traiter pour l'envoi de photo sur le serveur
    final fileDirectory = await getPendingUploadImageAbsoluteDirectory();

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
    } else {
      return;
    }

    for (var i = 0; i < files.length; i++) {
      if (!files[i].path.endsWith(".json")) {
        continue;
      }
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
            photo_on_site_uuid: mapPhoto["photo_on_site_uuid"],
            field_on_site_uuid: mapPhoto["field_on_site_uuid"],
            filename: mapPhoto["filename"],
            /* latitude: mapPhoto["location"]["latitude"],
            longitude: mapPhoto["location"]["longitude"]
            */
            latitude: 0.0,
            longitude: 0.0);

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

  static Future<void> addUploadPendingImage({
    // required Field field,
    // required Position position,
    required String photo_on_site_uuid,
    required String filename,
    required String field_on_site_uuid,
  }) async {
    final directory = await getPendingUploadImageAbsoluteDirectory();
    Map<String, dynamic> jsonContent = {
      "photo_on_site_uuid": photo_on_site_uuid,
      "filename": filename,
      "field_on_site_uuid": field_on_site_uuid
      /* "fieldName": field.field_name,
      "location": {
        "longitude": position.longitude,
        "latitude": position.latitude
      }
      */
    };

    String jsonContentAsString = jsonEncode(jsonContent);
    String path = "${directory.path}/$photo_on_site_uuid.json";
    final file = File(path);
    await file.create();
    await file.writeAsString(jsonContentAsString);
    return;
  }

  bool isProcessingUploadPendingImages() {
    return isProcessingUpload;
  }

  static String getImagePath(Directory directory, String pathOrigin) {
    const String localSubDirectoryCameraPictures = 'camera/pictures';
    final String pathDirectory =
        "${directory.path}/$localSubDirectoryCameraPictures";

    var strParts = pathOrigin.split('pictures/');

    String path = "$pathDirectory/${strParts[1]}";
    return path;
  }

  static String getPendingUploadImageRelativeDirectoryPath() {
    final String pathDirectory = "$localSubDirectoryUploadImages";
    return pathDirectory;
  }

  static Future<Directory> getPendingUploadImageAbsoluteDirectory() async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String pathDirectory =
        "${localDirectory.path}/$localSubDirectoryUploadImages";
    final directory = Directory(pathDirectory);

    if (!await directory.exists()) {
      logger.d("uploadPendingImages : directoring not found, creating ..");
      directory.createSync(recursive: true);
      logger.d("uploadPendingImages : directoring created ..");
    }

    return directory;
  }
}
