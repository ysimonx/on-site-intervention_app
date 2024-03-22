// ignore_for_file: non_constant_identifier_names

class CustomField {
  String code;
  String label;
  List<dynamic> autocomplete_values;

  CustomField(
      {required this.code,
      required this.label,
      required this.autocomplete_values});

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {};
    data['code'] = code;
    data['label'] = label;
    data['autocomplete_values'] = autocomplete_values;
    return data;
  }

  CustomField.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        label = json['label'],
        autocomplete_values = json.containsKey('autocomplete_values')
            ? json['autocomplete_values']
            : [];
}
