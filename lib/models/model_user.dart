import 'package:on_site_intervention_app/models/model_config.dart';

import 'model_site.dart';

class User {
  String id;
  String firstname;
  String lastname;
  String email;
  String phone;

  late List<Site> sites;
  late Config myconfig;

  User(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.phone});

  Map<String, dynamic> toJSON() {
    var resorg = [];
    for (var i = 0; i < sites.length; i++) {
      resorg.add(sites[i].toJSON());
    }

    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['email'] = email;
    data['phone'] = phone;
    data['sites'] = resorg;
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

    if (json.containsKey('config_site_type_intervention')) {
      user.myconfig = Config.fromJson(json);
    }

    List<Site> res = [];

    if (json.containsKey('sites')) {
      List sites = json['sites'];
      for (var i = 0; i < sites.length; i++) {
        Site org = Site.fromJson(sites[i]["site"]);
        res.add(org);
      }
    }

    user.sites = res;

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
