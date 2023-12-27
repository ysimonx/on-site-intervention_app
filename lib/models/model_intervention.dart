import '../ui/utils/uuid.dart';

class Intervention {
  String id;
  String intervention_name;
  String intervention_on_site_uuid;
  String organization_id;
  int version = 1;

  Intervention({
    required this.id,
    required this.intervention_name,
    required this.organization_id,
    required this.intervention_on_site_uuid,
  });

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['intervention_name'] = intervention_name;
    data['organization_id'] = organization_id;
    data['intervention_on_site_uuid'] = intervention_on_site_uuid;
    data['version'] = version;
    return data;
  }

  Intervention.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        intervention_name = json['intervention_name'] != null
            ? json['intervention_name'] as String
            : "",
        organization_id = json.containsKey('organization_id')
            ? json['organization_id']
            : "826eaeb6-7180-443d-bce4-f1840079a54d",
        version = json.containsKey('version') ? json['version'] : 1,
        intervention_on_site_uuid =
            json.containsKey('intervention_on_site_uuid')
                ? json['intervention_on_site_uuid']
                : generateUUID();
}
