// import 'package:app_renovadmin/models/location.dart';
// ignore_for_file: non_constant_identifier_names

import 'package:uuid/uuid.dart';

class Photo {
  final String photo_on_site_uuid;
  final String field_on_site_uuid;
  final String filename;
  late final DateTime created_date_utc;

  Photo(
      {required this.filename,
      required this.photo_on_site_uuid,
      required this.field_on_site_uuid,
      //  required this.location,
      required this.created_date_utc});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["photo_on_site_uuid"] = photo_on_site_uuid;
    data["field_on_site_uuid"] = field_on_site_uuid;
    data["filename"] = filename;
    // data["location"] = location.toJSON();
    data["created_date_utc"] = created_date_utc.toString();
    return data;
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }
}
