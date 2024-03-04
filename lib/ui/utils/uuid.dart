import 'package:uuid/uuid.dart';

String generateUUID() {
  var uuid = const Uuid();
  return uuid.v1();
}

String generateUUIDFromString(String s) {
  var uuid = const Uuid();
  return uuid.v5(Uuid.NAMESPACE_X500, s);
}
