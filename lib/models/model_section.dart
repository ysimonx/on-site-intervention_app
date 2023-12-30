import '../ui/utils/uuid.dart';

class Section {
  String section_on_site_uuid;
  String section_name;

  Section({required this.section_on_site_uuid, required this.section_name});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['section_on_site_uuid'] = section_on_site_uuid;
    data['section_name'] = section_name;

    return data;
  }

  Section.fromJson(Map<String, dynamic> json)
      : section_on_site_uuid = json.containsKey('section_on_site_uuid')
            ? json['form_on_site_uuid']
            : generateUUID(),
        section_name = json['section_name'] as String;
}

Map<String, Section> ConvertJsonToMapSection(map) {
  Map<String, Section> res = {};

  map.forEach((key, value) {
    Section s = Section(
        section_name: value["section_name"],
        section_on_site_uuid: value.containsKey('section_on_site_uuid')
            ? value["section_on_site_uuid"]
            : generateUUID());

    res[key] = s;
  });
  // }
  return res;
}

Map<String, dynamic> ConvertListSectionsToJson(Map<String, Section> map) {
  Map<String, dynamic> res = {};

  map.forEach((key, value) {
    dynamic json = value.toJSON();
    res[key] = json;
  });
  // }
  return res;
}
