import 'package:flutter/foundation.dart' show kIsWeb;

bool isMobileFirst() {
  if (kIsWeb) {
    return false;
  }
  return true;
}
