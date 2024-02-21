// import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/*Future<Future<bool>> requestPermission() async {
  await [Permission.locationWhenInUse].request();
  return checkStatusPermission();
}

Future<bool> checkStatusPermission() async {
  return await Permission.location.isGranted;
}*/

Future<bool> requestPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return false;
  }

  return true;
}
