import '../ui/utils/uuid.dart';
import 'model_formulaire.dart';
import 'model_place.dart';

class Intervention {
  String id;
  String intervention_name;
  String intervention_values_on_site_uuid;
  String organization_id;
  String type_intervention_id;
  String type_intervention_name;
  int version = 1;
  Map<String, Formulaire> forms = {};
  Place place;

  Intervention(
      {required this.id,
      required this.intervention_name,
      required this.organization_id,
      required this.intervention_values_on_site_uuid,
      required this.type_intervention_id,
      required this.type_intervention_name,
      required this.forms,
      required this.place});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['intervention_name'] = intervention_name;
    data['organization_id'] = organization_id;
    data['intervention_values_on_site_uuid'] = intervention_values_on_site_uuid;
    data['version'] = version;
    data['type_intervention_id'] = type_intervention_id;
    data['forms'] = ConvertMapFormulairesToJson(forms);
    data['place_id'] = place.id;
    data['place_name'] = place.name;
    data['place_on_site_uuid'] = place.place_on_site_uuid;
    return data;
  }

  Intervention.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        intervention_name = json['intervention_name'] != null
            ? json['intervention_name'] as String
            : "",
        organization_id = json.containsKey('organization_id')
            ? json['organization_id'] as String
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
                organization_id: json.containsKey('organization_id')
                    ? json['organization_id'] as String
                    : "826eaeb6-7180-443d-bce4-f1840079a54d");

  // forms2 = {};
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
