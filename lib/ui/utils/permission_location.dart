// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

// cf https://pub.dev/packages/permission_handler !
// cf https://medium.com/@santokimaulik/flutter-location-permission-with-permission-handler-ad2c7564b596

class PermissionLocationWidget extends StatefulWidget {
  const PermissionLocationWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return PermissionLocationWidgetState();
  }
}

class PermissionLocationWidgetState extends State<PermissionLocationWidget> {
  bool isLocationEnabled = false;
  bool isLocationGranted = false;
  // late Timer _timer;

  late bool processingLocationAutorization;

  @override
  void initState() {
    super.initState();
    processingLocationAutorization = false;
  }

  @override
  void dispose() {
    super.dispose();
    // _timer.cancel();
  }

  Future<bool> isLocationOk() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      isLocationEnabled = false;
      isLocationGranted = false;
      return false;
    }
    final enabled = await Permission.location.serviceStatus.isEnabled;
    if (enabled) {
      isLocationEnabled = true;
    } else {
      isLocationEnabled = false;
    }

    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      isLocationGranted = true;
    } else {
      isLocationGranted = false;
    }

    if (isLocationGranted) {
      return true;
    }

    if (processingLocationAutorization) {
      return false;
    }

    try {
      processingLocationAutorization = true;

      Map<Permission, PermissionStatus> statuses =
          await [Permission.locationWhenInUse].request();

      if (statuses[Permission.locationWhenInUse]!.isPermanentlyDenied ||
          statuses[Permission.locationWhenInUse]!.isDenied) {
        isLocationGranted = false;
      } else {
        isLocationGranted = true;
      }

      processingLocationAutorization = false;
    } catch (_) {
      processingLocationAutorization = false;
      rethrow;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isLocationOk(), // a previously-obtained Future or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print("${isLocationEnabled}");
            if (isLocationEnabled) {
              // return const Text("geoloc : Oui");
              return const Text("");
            } else {
              // return const Text("geoloc : Non");
              return const Text("");
            }
          } else if (snapshot.hasError) {
            return const Text("error");
          }
          return const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          );
        });
  }
}
