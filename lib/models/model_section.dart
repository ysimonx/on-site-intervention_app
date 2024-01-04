// ignore_for_file: non_constant_identifier_names

import '../ui/utils/uuid.dart';
import 'model_field.dart';

class Section {
  String section_on_site_uuid;
  String section_name;
  String section_type;
  Map<String, Field> fields = {};

  Section(
      {required this.section_on_site_uuid,
      required this.section_name,
      required this.section_type});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['section_on_site_uuid'] = section_on_site_uuid;
    data['section_name'] = section_name;
    data['section_type'] = section_type;
    data['fields'] = ConvertMapFieldsToJson(fields);

    return data;
  }

  Section.fromJson(Map<String, dynamic> json)
      : section_on_site_uuid = json.containsKey('section_on_site_uuid')
            ? json['section_on_site_uuid'] as String
            : generateUUID(),
        section_name = json['section_name'] as String,
        section_type = json['section_type'] as String,
        fields = ConvertJsonToMapFields(json['fields']);
}

Map<String, Field> ConvertJsonToMapFields(map) {
  Map<String, Field> res = {};

  map.forEach((key, value) {
    Field f = Field.fromJson(value);
    res[key] = f;
  });
  // }
  return res;
}

Map<String, dynamic> ConvertMapFieldsToJson(Map<String, Field> map) {
  Map<String, dynamic> res = {};

  map.forEach((key, value) {
    dynamic json = value.toJSON();
    res[key] = json;
  });
  // }
  return res;
}
