import 'package:flutter/foundation.dart' show kIsWeb;

bool isMobileFirst() {
  if (kIsWeb) {
    return false;
  }
  return true;
}

bool isOfflineFirst() {
  if (kIsWeb) {
    return false;
  }
  return true;
}
