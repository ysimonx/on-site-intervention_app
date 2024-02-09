import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'dart:async';

import '../../models/model_intervention.dart';
import '../../models/model_tenant.dart';
import '../../models/model_formulaire.dart';
import '../../models/model_site.dart';
import '../../models/model_user.dart';
import '../../ui/utils/mobilefirst.dart';
import '../../ui/utils/files.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class UserApi {
  UserApi();

  DioClient dioClient = DioClient(Dio());

  Future<List<User>> userList(
      {String tenant = 'ctei',
      required Site site,
      required List<Tenant> tenants}) async {
    List<User> res = [];

    Map<String, String> qParams = {'tenant_id': tenant, 'site_id': site.id};

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

    dynamic content = {};

    try {
      final Response response = await dioClient.get(Endpoints.userMe);

      if (response.statusCode == 200) {
        content = jsonEncode(response.data);
      }
    } on DioException catch (e) {
      logger.e(e.message);
    } on Exception catch (e) {
      logger.e(e.toString());
    }

    if (isMobileFirst()) {
      if (content != {}) {
        await writeUserMe(content);
      } else {
        content = await readUserMe();
      }
    }

    Map<String, dynamic> contentJson = jsonDecode(content);
    User me = User.fromConfigJson(contentJson);
    return me;
  }

  Future<File> get _localFile async {
    final path = await localPath;
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
      rethrow;
    }
  }

  Future<File> writeUserMe(String data) async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        // read the file from assets first and create the local file with its contents
        await file.create();
      }

      // Write the file
      return file.writeAsString(data);
    } catch (e) {
      // If encountering an error, return ""
      rethrow;
    }
  }

  Future<Map<String, Formulaire>> getInterventionFormsFromTemplate(
      {required String site_name,
      required String type_intervention_name,
      required User user}) async {
    Map<String, dynamic> formsTemplates =
        await user.myconfig.config_types_intervention[type_intervention_name];

    Map<String, Formulaire> forms = {};

    Map<String, dynamic> jsonForm = formsTemplates["forms"];

    jsonForm.forEach((key, value) {
      Formulaire form = Formulaire.fromJson(value);
      forms[key] = form;
    });

    return forms;
  }

  Future<List<User>> getSupervisorsList(
      {required Site site, required User user}) async {
    List<User> res = [];

    for (var i = 0; i < user.sites.length; i++) {
      Site o = user.sites[i];
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
    return me.myconfig.config_types_intervention[organisation.name]
        [intervention.type_intervention_name];
  }
}
