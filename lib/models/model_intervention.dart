// ignore_for_file: non_constant_identifier_names

import '../ui/utils/uuid.dart';
import 'model_formulaire.dart';
import 'model_place.dart';
import 'model_user.dart';

class Intervention {
  String id;
  String intervention_name;
  String intervention_values_on_site_uuid;
  String site_id;
  String type_intervention_id;
  String type_intervention_name;
  String status;
  String hashtag = "";
  String? numChrono = "[numchrono]";
  String? indice = "A";
  int version = 1;
  Map<String, Formulaire> forms = {};
  Map<String, dynamic> field_on_site_uuid_values = {};
  Place place;
  String? assignee_user_id;

  Intervention(
      {required this.id,
      required this.intervention_name,
      required this.site_id,
      required this.intervention_values_on_site_uuid,
      required this.type_intervention_id,
      required this.type_intervention_name,
      required this.forms,
      required this.status,
      required this.place});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['intervention_name'] = intervention_name;
    data['field_on_site_uuid_values'] = field_on_site_uuid_values;
    data['site_id'] = site_id;
    data['intervention_values_on_site_uuid'] = intervention_values_on_site_uuid;
    data['version'] = version;
    data['type_intervention_id'] = type_intervention_id;
    data['forms'] = ConvertMapFormulairesToJson(forms);
    data['place_id'] = place.id;
    data['place'] = place.toJSON();
    data['place_name'] = place.name;
    data['place_json'] = place.place_json;
    data['place_on_site_uuid'] = place.place_on_site_uuid;
    data['status'] = status;
    data['assignee_user_id'] = assignee_user_id;
    data['hashtag'] = hashtag;
    return data;
  }

  Intervention.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        field_on_site_uuid_values = json['field_on_site_uuid_values'],
        intervention_name = json['intervention_name'] != null
            ? json['intervention_name'] as String
            : "",
        site_id = json.containsKey('site_id')
            ? json['site_id'] as String
            : json.containsKey('site')
                ? json['site']['id'] as String
                : "826eaeb6-7180-443d-bce4-f1840079a54d",
        version = json.containsKey('version') ? json['version'] : 1,
        intervention_values_on_site_uuid =
            json.containsKey('intervention_values_on_site_uuid')
                ? json['intervention_values_on_site_uuid'] as String
                : generateUUID(),
        type_intervention_id = json.containsKey('type_intervention_id')
            ? json['type_intervention_id'] as String
            : "scaffolding request",
        type_intervention_name = json.containsKey('type_intervention_name')
            ? json['type_intervention_name'] as String
            : "scaffolding request",
        forms = json.containsKey('forms')
            ? ConvertJsonToMapFormulaires(json['forms'])
            : {},
        place = json.containsKey('place')
            ? Place.fromJson(json['place'])
            : Place.nowhere(
                site_id: json.containsKey('site_id')
                    ? json['site_id'] as String
                    : json.containsKey('site')
                        ? json['site']['id'] as String
                        : "826eaeb6-7180-443d-bce4-f1840079a54d"),
        status = json.containsKey('status')
            ? json['status'] != null
                ? json['status']
                : ""
            : "",
        assignee_user_id = json.containsKey('assignee_user_id')
            ? json['assignee_user_id'] != null
                ? json['assignee_user_id']
                : User.nobody().id
            : User.nobody().id,
        hashtag = json.containsKey('hashtag') ? "${json['hashtag']}" : "";

  // forms2 = {};
  String BuildNumRegistre() {
    String s = "${place.name}-${numChrono}-${indice}";
    return s;
  }
}

Map<String, Formulaire> ConvertJsonToMapFormulaires(map) {
  Map<String, Formulaire> res = {};

  map.forEach((key, value) {
    Formulaire f = Formulaire.fromJson(value);
    res[key] = f;
  });
  // }
  return res;
}

Map<String, dynamic> ConvertMapFormulairesToJson(Map<String, Formulaire> map) {
  Map<String, dynamic> res = {};

  map.forEach((String index, Formulaire f) {
    dynamic json = f.toJSON();
    res[index] = json;
  });
  // }
  return res;
}
