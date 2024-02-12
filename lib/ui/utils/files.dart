import 'package:path_provider/path_provider.dart';

import 'logger.dart';

Future<String> get localPath async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  } catch (e) {
    logger.d(e.toString());
    rethrow;
  }
}
