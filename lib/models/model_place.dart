// ignore_for_file: non_constant_identifier_names

import '../ui/utils/uuid.dart';

class Place {
  String id;
  String place_on_site_uuid;
  String name;
  String site_id;

  Place(
      {required this.id,
      required this.place_on_site_uuid,
      required this.name,
      required this.site_id});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['place_on_site_uuid'] = site_id;
    data['name'] = name;
    data['site_id'] = site_id;
    return data;
  }

  Place.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        place_on_site_uuid = json.containsKey('place_on_site_uuid')
            ? json['place_on_site_uuid']
            : generateUUID(),
        name = json['name'] as String,
        site_id = json['site_id'] as String;

  static Place nowhere({required String site_id}) {
    return Place(
        id: site_id, // hack pour avoir un id unique
        name: "nowhere",
        place_on_site_uuid: site_id, // hack pour avoir un id unique
        site_id: site_id);
  }
}
