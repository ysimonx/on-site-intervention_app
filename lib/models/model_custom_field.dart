// ignore_for_file: non_constant_identifier_names

class CustomField {
  String code;
  String label;

  CustomField({required this.code, required this.label});

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = {};
    data['code'] = code;
    data['label'] = label;
    return data;
  }

  CustomField.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        label = json['label'];
}
