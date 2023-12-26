import '../ui/utils/uuid.dart';

class Intervention {
  String id;
  String name;

  String intervention_on_site_uuid;

  Intervention(
      {required this.id,
      required this.name,
      required this.intervention_on_site_uuid});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['intervention_on_site_uuid'] = intervention_on_site_uuid;
    return data;
  }

  Intervention.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        intervention_on_site_uuid =
            json.containsKey('intervention_on_site_uuid')
                ? json['intervention_on_site_uuid']
                : generateUUID();
}
