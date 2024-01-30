import 'package:on_site_intervention_app/models/model_config.dart';

import 'model_organization.dart';

class User {
  String id;
  String firstname;
  String lastname;
  String email;
  String phone;

  late List<Organization> organizations;
  late Config myconfig;

  User(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.phone});

  Map<String, dynamic> toJSON() {
    var resorg = [];
    for (var i = 0; i < organizations.length; i++) {
      resorg.add(organizations[i].toJSON());
    }

    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['email'] = email;
    data['phone'] = phone;
    data['organizations'] = resorg;
    return data;
  }

  static User fromConfigJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonUser = json['user'];

    User user = User(
        id: jsonUser['id'] as String,
        firstname: jsonUser['firstname'] as String,
        lastname: jsonUser['lastname'] as String,
        email: jsonUser['email'] as String,
        phone: jsonUser['phone'] as String);

    if (json.containsKey('config_organization_type_intervention')) {
      user.myconfig = Config.fromJson(json);
    }

    List<Organization> res = [];

    if (json.containsKey('organizations')) {
      List organizations = json['organizations'];
      for (var i = 0; i < organizations.length; i++) {
        Organization org =
            Organization.fromJson(organizations[i]["organization"]);
        res.add(org);
      }
    }

    user.organizations = res;

    return user;
  }

  void setConfig({required Config config}) {
    myconfig = config;
  }

  static User nobody() {
    User user = User(id: "", firstname: "", lastname: "", email: "", phone: "");
    return user;
  }

  bool isAuthorized() {
    if (id != "") {
      return true;
    }
    return false;
  }

  static User fromJson(Map<String, dynamic> jsonUser) {
    User user = User(
        id: jsonUser['id'] as String,
        firstname: IfNull(jsonUser['firstname']),
        lastname: IfNull(jsonUser['lastname']),
        email: IfNull(jsonUser['email']),
        phone: IfNull(jsonUser['phone']));
    return user;
  }
}

String IfNull(String? s) {
  if (s != null) {
    return s;
  }
  return "";
}
