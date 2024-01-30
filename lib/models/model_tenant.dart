class Tenant {
  String id;
  String name;

  Tenant({required this.id, required this.name});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  Tenant.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String;
}
