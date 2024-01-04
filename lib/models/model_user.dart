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

  static User fromJson(Map<String, dynamic> json) {
    User user = User(
        id: json['user']['id'] as String,
        firstname: json['user']['firstname'] as String,
        lastname: json['user']['lastname'] as String,
        email: json['user']['email'] as String,
        phone: json['user']['phone'] as String);

    List<Organization> res = [];

    if (json.containsKey('organizations')) {
      var organizations = json['organizations'];

      for (var i = 0; i < organizations.length; i++) {
        Organization org =
            Organization.fromJson(organizations[i]["organization"]);
        res.add(org);
      }
    }
    user.organizations = res;
    return user;
  }

  List<Organization> organizationsFromJson(Map<String, dynamic> json) {
    List<Organization> res = [];
    return res;
  }

  void setConfig({required Config config}) {
    this.myconfig = config;
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
}
