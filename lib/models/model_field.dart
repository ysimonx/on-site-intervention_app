// ignore_for_file: non_constant_identifier_names

import '../ui/utils/uuid.dart';

class Field {
  String field_on_site_uuid;
  String field_name;
  String field_type;
  String field_label;

  late List<dynamic> field_possible_values = [];
  late String field_default_value = "";

  late String field_switch_on = "True";
  late String field_switch_off = "False";

  Field({
    required this.field_on_site_uuid,
    required this.field_name,
    required this.field_label,
    required this.field_type,
  });

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field_on_site_uuid'] = field_on_site_uuid;
    data['field_name'] = field_name;
    data['field_name'] = field_label;
    data['field_type'] = field_type;
    data['default_value'] = field_default_value;
    data['field_possible_values'] = field_possible_values;
    data['field_switch_on'] = field_switch_on;
    data['field_switch_off'] = field_switch_off;

    return data;
  }

  Field.fromJson(Map<String, dynamic> json)
      : field_on_site_uuid = json.containsKey('field_on_site_uuid')
            ? json['field_on_site_uuid']
            : generateUUID(),
        field_label = json.containsKey('field_label')
            ? json['field_label'] as String
            : json['field_name'] as String,
        field_name = json['field_name'] as String,
        field_type = json['field_type'] as String,
        field_possible_values =
            json.containsKey('values') ? json['values'] : [],
        field_default_value =
            json.containsKey('default_value') ? json['default_value'] : "",
        field_switch_on =
            json.containsKey('value_on') ? json['value_on'] : "True",
        field_switch_off =
            json.containsKey('value_off') ? json['value_off'] : "False";

  DateTime getDefaultDateTimeValue() {
    if (field_default_value == "now") {
      return DateTime.now();
    }
    if (field_default_value == "j+15") {
      return DateTime.now().add(const Duration(days: 15));
    }

    return DateTime.now();
  }
}
