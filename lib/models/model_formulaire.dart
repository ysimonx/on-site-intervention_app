// ignore_for_file: non_constant_identifier_names

import '../ui/utils/uuid.dart';
import 'model_section.dart';

class Formulaire {
  String form_on_site_uuid;
  String form_name;
  Map<String, Section> sections = {};

  Formulaire(
      {required this.form_on_site_uuid,
      required this.form_name,
      Map? sections});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['form_on_site_uuid'] = form_on_site_uuid;
    data['form_name'] = form_name;
    data['sections'] = ConvertMapSectionsToJson(sections);
    return data;
  }

  Formulaire.fromJson(Map<String, dynamic> json)
      : form_on_site_uuid = json.containsKey('form_on_site_uuid')
            ? json['form_on_site_uuid']
            : generateUUID(),
        form_name = json['form_name'] as String,
        sections = json.containsKey('sections')
            ? ConvertJsonToMapSections(json['sections'])
            : {};
}

Map<String, Section> ConvertJsonToMapSections(map) {
  Map<String, Section> res = {};

  map.forEach((key, value) {
    /* Section s = Section(
        section_name: value["section_name"],
        section_type: value["section_type"],
        section_on_site_uuid: value.containsKey('section_on_site_uuid')
            ? value["section_on_site_uuid"]
            : generateUUID());
    */
    Section s = Section.fromJson(value);
    res[key] = s;
  });
  // }
  return res;
}

Map<String, dynamic> ConvertMapSectionsToJson(Map<String, Section> map) {
  Map<String, dynamic> res = {};

  map.forEach((key, value) {
    dynamic json = value.toJSON();
    res[key] = json;
  });
  // }
  return res;
}
