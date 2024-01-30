import 'model_tenant.dart';

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
}
