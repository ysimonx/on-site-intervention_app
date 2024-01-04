// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../../models/model_config.dart';
import '../../models/model_formulaire.dart';
import '../../models/model_organization.dart';
import '../../models/model_user.dart';
import '../../ui/utils/logger.dart';
import '../dio_client.dart';
import 'constants.dart';

class UserApi {
  UserApi();

  DioClient dioClient = DioClient(Dio());

  Future<User> me({bool tryRealTime = true}) async {
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

  Future<Map<String, Formulaire>> getInterventionInitializedFormsFromTemplate(
      {required String organization, required String type_intervention}) async {
    User me = await this.me(tryRealTime: false);

    Map<String, Formulaire> forms = {};

    // recherche des templates de formulaire pour le bon type d'intervention
    // et pour l'organization
    for (var i = 0;
        i < me.myconfig.organizations_types_interventions.length;
        i++) {
      Map<String, dynamic> item =
          me.myconfig.organizations_types_interventions[i];

      if (item.containsKey(organization)) {
        Map<String, dynamic> item_organization = item[organization];
        if (item_organization.containsKey(type_intervention)) {
          // je l'ai trouvé !

          Map<String, dynamic> formsTemplates =
              jsonDecode(item_organization[type_intervention]);

          Map<String, Formulaire> forms = {};

          formsTemplates["forms"].forEach((key, value) {
            Formulaire form = Formulaire.fromJson(value);
            forms[key] = form;
          });

          return forms;
        }
      }
    }

    return forms;
  }

  Future<List<User>> getSupervisorsList(
      {required Organization organization}) async {
    User me = await this.me(tryRealTime: false);

    List<User> res = [];

    for (var i = 0; i < me.organizations.length; i++) {
      Organization o = me.organizations[i];
      if (o.id == organization.id) {
        for (var j = 0; j < o.roles.length; j++) {
          Map<String, dynamic> mapRoles = o.roles[j];
          if (mapRoles.containsKey("supervisor")) {
            print("gotcha");
            Map<String, dynamic> mapRole = mapRoles["supervisor"];
            List<dynamic> listUsers = mapRole["users"];
            for (var k = 0; k < listUsers.length; k++) {
              dynamic itemUser = listUsers[k];
              User u = User.fromJson(itemUser);
              res.add(u);
            }
          }
        }
      }
    }
    // recherche des templates de formulaire pour le bon type d'intervention
    // et pour l'organization

    /* for (var i = 0;
        i < me.myconfig.organizations_types_interventions.length;
        i++) {
      Map<String, dynamic> item =
          me.myconfig.organizations_types_interventions[i];

      if (item.containsKey(organization)) {
        Map<String, dynamic> item_organization = item[organization];
        if (item_organization.containsKey(type_intervention)) {
          // je l'ai trouvé !

          Map<String, dynamic> formsTemplates =
              jsonDecode(item_organization[type_intervention]);

          Map<String, Formulaire> forms = {};

          formsTemplates["forms"].forEach((key, value) {
            Formulaire form = Formulaire.fromJson(value);
            forms[key] = form;
          });

          return forms;
        }
      }
    }
    */

    return res;
  }
}
