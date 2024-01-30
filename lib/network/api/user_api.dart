// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, unused_import, non_constant_identifier_names

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:on_site_intervention_app/models/model_intervention.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../../models/model_config.dart';
import '../../models/model_formulaire.dart';
import '../../models/model_site.dart';
import '../../models/model_user.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class UserApi {
  UserApi();

  DioClient dioClient = DioClient(Dio());

  Future<List<User>> userList({String tenant = 'fidwork'}) async {
    List<User> res = [];

    Map<String, String> qParams = {'tenant_id': tenant};

    try {
      final Response response =
          await dioClient.get(Endpoints.userList, queryParameters: qParams);
      if (response.statusCode == 200) {
        // await writeUserMe(jsonEncode(response.data));
        print(response.statusCode);
        print(response.data);
        List<dynamic> arrayJson = response.data;
        for (int index = 0; index < arrayJson.length; index++) {
          User u = User.fromJson(arrayJson[index]);
          res.add(u);
        }
      }
    } on DioException catch (e) {
      logger.e(e.message);
    }

    return res;
  }

  Future<User> myConfig({bool tryRealTime = true}) async {
    // attempt to retrieve my profile from server
    if (tryRealTime) {
      try {
        final Response response = await dioClient.get(Endpoints.userMe);
        if (response.statusCode == 200) {
          await writeUserMe(jsonEncode(response.data));
        }
      } on DioException catch (e) {
        logger.e(e.message);
      }
    }

    // return data already downloaded, even in mobile-first Mode
    dynamic content = await readUserMe();
    Map<String, dynamic> contentJson = jsonDecode(content);

    User me = User.fromConfigJson(contentJson);
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

  Future<Map<String, Formulaire>> getInterventionFormsFromTemplate(
      {required String site_name,
      required String type_intervention_name}) async {
    User me = await myConfig(tryRealTime: false);

    Map<String, dynamic> formsTemplates = await me
        .myconfig.sites_types_interventions[site_name][type_intervention_name];

    Map<String, Formulaire> forms = {};

    Map<String, dynamic> jsonForm = formsTemplates["forms"];

    jsonForm.forEach((key, value) {
      Formulaire form = Formulaire.fromJson(value);
      forms[key] = form;
    });

    return forms;
  }

  Future<List<User>> getSupervisorsList({required Site site}) async {
    User me = await myConfig(tryRealTime: false);

    List<User> res = [];

    for (var i = 0; i < me.sites.length; i++) {
      Site o = me.sites[i];
      if (o.id == site.id) {
        for (var j = 0; j < o.roles.length; j++) {
          Map<String, dynamic> mapRoles = o.roles[j];
          if (mapRoles.containsKey("supervisor")) {
            print("gotcha");
            Map<String, dynamic> mapRole = mapRoles["supervisor"];
            List<dynamic> listUsers = mapRole["users"];
            for (var k = 0; k < listUsers.length; k++) {
              dynamic itemUser = listUsers[k];
              User u = User.fromConfigJson(itemUser);
              res.add(u);
            }
          }
        }
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> getTemplate(
      {required Site organisation, required Intervention intervention}) async {
    User me = await myConfig(tryRealTime: false);
    return me.myconfig.sites_types_interventions[organisation.name]
        [intervention.type_intervention_name];
  }
}
