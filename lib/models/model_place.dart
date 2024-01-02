import '../ui/utils/uuid.dart';

class Place {
  String id;
  String place_on_site_uuid;
  String name;
  String organization_id;

  Place(
      {required this.id,
      required this.place_on_site_uuid,
      required this.name,
      required this.organization_id});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['place_on_site_uuid'] = organization_id;
    data['name'] = name;
    data['organization_id'] = organization_id;
    return data;
  }

  Place.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        place_on_site_uuid = json.containsKey('place_on_site_uuid')
            ? json['place_on_site_uuid']
            : generateUUID(),
        name = json['name'] as String,
        organization_id = json['organization_id'] as String;

  static Place nowhere({required String organization_id}) {
    return Place(
        id: organization_id, // hack pour avoir un id unique
        name: "nowhere",
        place_on_site_uuid: organization_id, // hack pour avoir un id unique
        organization_id: organization_id);
  }
}
