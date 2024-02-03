import 'model_tenant.dart';
import 'model_user.dart';

class Site {
  String id;
  String name;
  List<dynamic> roles = [];
  late Tenant tenant;

  Site({required this.id, required this.name});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['roles'] = roles;
    return data;
  }

  Site.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        roles = json.containsKey('roles') ? json['roles'] : [],
        tenant = Tenant.fromJson(json['tenant']);

  List<String> getRoleNamesForUser(User u) {
    List<String> user_roles = [];

    for (var i = 0; i < roles.length; i++) {
      Map<String, dynamic> x = roles[i];
      x.forEach((role_name, jsonrole) {
        List<dynamic> jsonusers = jsonrole["users"];
        for (var j = 0; j < jsonusers.length; j++) {
          Map<String, dynamic> jsonuser = jsonusers[j]["user"];
          if (jsonuser["email"] == u.email) {
            user_roles.add(role_name);
          }
        }
      });
    }
    return user_roles;
    // return "role";
  }
}
