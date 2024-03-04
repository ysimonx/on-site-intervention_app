// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import '../ui/utils/uuid.dart';

class Place {
  String id;
  String place_on_site_uuid;
  String name;
  String site_id;
  Map<String, dynamic> place_json;

  Place(
      {required this.id,
      required this.place_on_site_uuid,
      required this.name,
      required this.site_id,
      required this.place_json});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['place_on_site_uuid'] =
        generateUUIDFromString("$site_id${jsonEncode(place_json)}");
    data['name'] = name;
    data['site_id'] = site_id;
    data['place_json'] = jsonEncode(place_json);
    return data;
  }

  Place.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        place_on_site_uuid = json.containsKey('place_on_site_uuid')
            ? json['place_on_site_uuid']
            : generateUUID(), // todo : bof ici ...
        name = json['name'] as String,
        site_id = json['site_id'] as String,
        place_json = json.containsKey("place_json")
            ? json["place_json"] != null
                ? jsonDecode(json["place_json"])
                : {}
            : {};

  static Place nowhere({required String site_id}) {
    return Place(
        id: site_id, // hack pour avoir un id unique
        name: "nowhere",
        place_on_site_uuid: site_id, // hack pour avoir un id unique
        site_id: site_id,
        place_json: {});
  }

  static Place newPlace(
      {required String site_id,
      required Map<String, dynamic> place_json,
      required String place_name}) {
    return Place(
        id: generateUUIDFromString("$site_id${jsonEncode(place_json)}"),
        place_on_site_uuid: generateUUIDFromString(
            "$site_id${jsonEncode(place_json)}"), // hack pour avoir un id unique
        site_id: site_id,
        name: place_name,
        place_json: place_json);
  }

  void set_place_json(Map<String, dynamic> value) {
    place_json = value;
    place_on_site_uuid =
        generateUUIDFromString("$site_id${jsonEncode(place_json)}");
  }
}
