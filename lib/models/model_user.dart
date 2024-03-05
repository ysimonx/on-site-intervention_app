// ignore_for_file: non_constant_identifier_names

import 'package:on_site_intervention_app/models/model_config.dart';

import 'model_site.dart';
import 'model_tenant.dart';

class User {
  String id;
  String firstname;
  String lastname;
  String email;
  String phone;
  String company;

  late List<Site> sites;
  late List<Tenant> tenants_administrator_of;

  late Config myconfig;

  User(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.phone,
      required this.company});

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
    data['company'] = company;
    return data;
  }

  static User fromConfigJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonUser = json['user'];

    User user = User(
      id: jsonUser['id'] as String,
      firstname: ifNull(jsonUser['firstname']),
      lastname: ifNull(jsonUser['lastname']),
      email: jsonUser['email'] as String,
      phone: ifNull(jsonUser['phone']),
      company:
          jsonUser.containsKey('company') ? ifNull(jsonUser['company']) : "",
    );

    if (json.containsKey('config_types_intervention')) {
      user.myconfig = Config.fromJson(json);
    }

    List<Site> resSites = [];

    if (json.containsKey('site_member_of')) {
      List sites = json['site_member_of'];
      for (var i = 0; i < sites.length; i++) {
        Site site = Site.fromJson(sites[i]["site"]);
        resSites.add(site);
      }
    }

    user.sites = resSites;

    List<Tenant> resTenants = [];
    if (json.containsKey('tenant_administrator_of')) {
      List tenants = json['tenant_administrator_of'];
      for (var i = 0; i < tenants.length; i++) {
        Tenant tenant = Tenant.fromJson(tenants[i]["tenant"]);
        resTenants.add(tenant);
      }
    }

    user.tenants_administrator_of = resTenants;

    return user;
  }

  void setConfig({required Config config}) {
    myconfig = config;
  }

  static User nobody() {
    User user = User(
        id: "", firstname: "", lastname: "", email: "", phone: "", company: "");
    return user;
  }

  isNobody() {
    return id == "";
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
        firstname: ifNull(jsonUser['firstname']),
        lastname: ifNull(jsonUser['lastname']),
        email: ifNull(jsonUser['email']),
        phone: ifNull(jsonUser['phone']),
        company: jsonUser.containsKey('company')
            ? jsonUser['company'] as String
            : "");
    return user;
  }
}

String ifNull(String? s) {
  if (s != null) {
    return s;
  }
  return "";
}
