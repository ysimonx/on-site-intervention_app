// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../../models/model_config.dart';
import '../../models/model_formulaire.dart';
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
    Config config = Config.fromJson(contentJson);
    me.setConfig(config: config);

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

  Future<Map<String, Formulaire>> getInterventionFormsTemplate(
      {required String organization, required String type_formulaire}) async {
    User me = await this.me();
    Map<String, dynamic> res = {};

    Map<String, Formulaire> forms = {};

    for (var i = 0;
        i < me.myconfig.organizations_types_interventions.length;
        i++) {
      Map<String, dynamic> item =
          me.myconfig.organizations_types_interventions[i];
      print(item);
      if (item.containsKey(organization)) {
        Map<String, dynamic> item_organization = item[organization];
        if (item_organization.containsKey(type_formulaire)) {
          res = jsonDecode(item_organization[type_formulaire]);

          Map<String, Formulaire> forms = {};

          res["forms"].forEach((key, value) {
            Formulaire form = Formulaire.fromJson(value);
            forms[key] = form;
          });

          return forms;
        }
      }
    }

    return forms;
  }
}
