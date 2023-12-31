import '../ui/utils/uuid.dart';

class Field {
  String field_on_site_uuid;
  String field_name;
  String field_type;

  Field(
      {required this.field_on_site_uuid,
      required this.field_name,
      required this.field_type});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field_on_site_uuid'] = field_on_site_uuid;
    data['field_name'] = field_name;
    data['field_type'] = field_type;
    return data;
  }

  Field.fromJson(Map<String, dynamic> json)
      : field_on_site_uuid = json.containsKey('field_on_site_uuid')
            ? json['field_on_site_uuid']
            : generateUUID(),
        field_name = json['field_name'] as String,
        field_type = json['field_type'] as String;
}
