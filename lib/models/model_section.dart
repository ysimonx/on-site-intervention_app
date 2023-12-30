import '../ui/utils/uuid.dart';

class Section {
  String section_on_site_uuid;
  String section_name;
  String section_type;

  Section(
      {required this.section_on_site_uuid,
      required this.section_name,
      required this.section_type});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['section_on_site_uuid'] = section_on_site_uuid;
    data['section_name'] = section_name;
    data['section_type'] = section_type;
    return data;
  }

  Section.fromJson(Map<String, dynamic> json)
      : section_on_site_uuid = json.containsKey('section_on_site_uuid')
            ? json['form_on_site_uuid']
            : generateUUID(),
        section_name = json['section_name'] as String,
        section_type = json['section_type'] as String;
}
