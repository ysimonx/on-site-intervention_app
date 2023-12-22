// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../../models/model_user.dart';
import '../dio_client.dart';
import 'constants.dart';

class UserApi {
  UserApi();

  DioClient dioClient = DioClient(Dio());

  Future<User> me() async {
    // attempt to retrieve my profile from server
    try {
      final Response response = await dioClient.get(Endpoints.userMe);
      if (response.statusCode == 200) {
        await writeUserMe(jsonEncode(response.data));
      }
    } on DioException catch (e) {
      print(e.message);
    }

    // return data already downloaded, even in mobile-first Mode
    dynamic content = await readUserMe();
    Map<String, dynamic> contentJson = jsonDecode(content);
    User me = User.fromJson(contentJson);
    return me;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/userMe.json');
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

  Future<File> writeUserMe(String data) async {
    final file = await _localFile;

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      await file.create();
    }

    // Write the file
    return file.writeAsString(data);
  }
}
