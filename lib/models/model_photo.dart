// import 'package:app_renovadmin/models/location.dart';
import 'package:uuid/uuid.dart';

class Photo {
  final String photo_uuid;
  final String path;
  final String status;
  // final Location location;
  late final DateTime created_date_utc;

  Photo(
      {required this.path,
      required this.photo_uuid,
      this.status = "Pending",
      //  required this.location,
      required this.created_date_utc});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["photo_uuid"] = photo_uuid;
    data["path"] = path;
    data["status"] = status;
    // data["location"] = location.toJSON();
    data["created_date_utc"] = created_date_utc.toString();
    return data;
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }
}
