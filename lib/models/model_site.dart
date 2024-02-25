import 'model_tenant.dart';
import 'model_user.dart';
import 'dart:convert';

class Site {
  String id;
  String name;
  List<dynamic> roles = [];
  Map<String, dynamic> dictOfLists = {};
  Map<String, dynamic> dictOfListsForPlaces = {};

  late Tenant tenant;

  Site({required this.id, required this.name});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['roles'] = roles;
    data['dictOfLists'] = jsonEncode(dictOfLists);
    data['dictOfListsForPlaces'] = jsonEncode(dictOfListsForPlaces);
    return data;
  }

  Site.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        roles = json.containsKey('roles') ? json['roles'] : [],
        dictOfLists =
            json.containsKey('dict_of_lists') ? json['dict_of_lists'] : {},
        dictOfListsForPlaces = json.containsKey('dict_of_lists_for_places')
            ? json['dict_of_lists_for_placess']
            : {},
        tenant = Tenant.fromJson(json['tenant']);

  List<String> getRoleNamesForUser(User u) {
    List<String> userRoles = [];

    for (var i = 0; i < roles.length; i++) {
      Map<String, dynamic> x = roles[i];
      x.forEach((roleName, jsonrole) {
        List<dynamic> jsonusers = jsonrole["users"];
        for (var j = 0; j < jsonusers.length; j++) {
          Map<String, dynamic> jsonuser = jsonusers[j]["user"];
          if (jsonuser["email"] == u.email) {
            userRoles.add(roleName);
          }
        }
      });
    }
    return userRoles;
    // return "role";
  }

  List<String> getUsersForRoleName(String whichRoleName) {
    List<String> usersEmail = [];

    for (var i = 0; i < roles.length; i++) {
      Map<String, dynamic> x = roles[i];
      x.forEach((roleName, jsonrole) {
        if (roleName == whichRoleName) {
          List<dynamic> jsonusers = jsonrole["users"];
          for (var j = 0; j < jsonusers.length; j++) {
            Map<String, dynamic> jsonuser = jsonusers[j]["user"];
            usersEmail.add(jsonuser["email"]);
          }
        }
      });
    }
    return usersEmail;
  }
}
