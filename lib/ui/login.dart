// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import 'dart:async';

import 'package:airplane_mode_checker/airplane_mode_checker.dart';
import '../network/api/login_api.dart';
import '../network/dio_client.dart';
import 'beneficiaires.dart';
import 'utils/permission_location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'widget/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

// cf https://blog.logrocket.com/flutter-form-validation-complete-guide/

// complet avec https://medium.com/@yshean/validating-custom-textformfields-the-flutter-way-182a7bb915a2

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  @override
  State<LoginPage> createState() => _LoginPageState();

  final String title;
}

class _LoginPageState extends State<LoginPage> {
  late DioClient dioClient;

  int _dummy = 0;

  late Timer t;

  // late GlobalKey<FormState> _formKey;
  bool? _statusAirplaneMode = false;
  String _platformVersion = 'Unknown';
  bool? _jailbroken = false;
  bool? _developerMode = false;
  String _deviceModel = 'Unknown';
  bool? _physicalDevice = true;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool alreadyStartBeneficiairePage = false;

  Widget submit() {
    return MaterialButton(
        onPressed: () async {
          final LoginApi loginApi = LoginApi(dioClient: dioClient);

          /* if (!_formKey.currentState!.validate()) {
            return;
          } */

          String email = "";

          email = emailController.text.trim();
          email = email.replaceAll("\n", " ");
          email = email.replaceAll("\r", " ");

          String password = "";

          password = passwordController.text.trim();
          password = password.replaceAll("\n", " ");
          password = password.replaceAll("\r", " ");

          if (email.length > 1) {
            try {
              Response result =
                  await loginApi.login(email: email, password: password);

              if (result.statusCode == 401) {
                const snackBar = SnackBar(
                  content: Text('identification failed'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
            } catch (e) {
              var snackBar = SnackBar(
                content: Text('identification failed : ${e}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }
          }

          alreadyStartBeneficiairePage = false;

          if (!_deviceModel.contains("7 Pro")) {
            if (_statusAirplaneMode!) {
              const snackBar = SnackBar(
                content: Text('Impossible en mode AVION !'),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if (_developerMode != null) {
              if (_developerMode!) {
                const snackBar = SnackBar(
                  content: Text('Impossible en mode DEVELOPER !'),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                // return;
              }
            }

            if (_jailbroken != null) {
              if (_jailbroken!) {
                const snackBar = SnackBar(
                  content: Text('Impossible en iphone jailbrake !'),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
            }
          }

          if (!mounted) return;

          setState(() {
            _dummy++;
          });
        },
        color: Theme.of(context).colorScheme.inversePrimary,
        textColor: Colors.white,
        child: const Text("Submit"));
  }

  Widget emailForm() {
    return TextFormField(
        controller: emailController,
        decoration: const InputDecoration(hintText: "email"),
        validator: validateEmail);
  }

  Widget passwordForm() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(hintText: "Password"),
    );
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();

    dioClient = DioClient(Dio());
    // _formKey = GlobalKey<FormState>();

    t = Timer.periodic(const Duration(seconds: 120), (timer) async {
      bool jailbroken;
      bool developerMode;

      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        jailbroken = await FlutterJailbreakDetection.jailbroken;
        developerMode = await FlutterJailbreakDetection.developerMode;
      } on PlatformException {
        jailbroken = true;
        developerMode = true;
      } on MissingPluginException {
        jailbroken = false;
        developerMode = false;
      }

      _jailbroken = jailbroken;
      _developerMode = developerMode;

      try {
        var status = await AirplaneModeChecker.checkAirplaneMode();
        if (status == AirplaneModeStatus.on) {
          _statusAirplaneMode = true;
        } else {
          _statusAirplaneMode = false;
        }
      } on MissingPluginException {
        _statusAirplaneMode = false;
      }

      setState(() {});
    });
  }

  Future<dynamic> isAlreadyLoggedInAndGeolocAuthorized(int dummy) async {
    bool isAlreadLoggedIn = await LoginApi.hasAnAccessToken();

    bool locationEnabled = await Permission.location.serviceStatus.isEnabled;

    bool isLocationGranted = false;

    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      isLocationGranted = true;
    }

    if (isAlreadLoggedIn && locationEnabled && isLocationGranted) {
      return true;
    }
    return false;
  }
  /*

  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: BaseAppBar(widget.title)),
        body: FutureBuilder(
            future: isAlreadyLoggedInAndGeolocAuthorized(
                _dummy), // il suffit de changer la valeur _dummy pour rafraichir cette liste :)
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  Future.delayed(const Duration(seconds: 1), () async {
                    print("beneficiaires push");
                    if (alreadyStartBeneficiairePage) {
                      return;
                    }
                    alreadyStartBeneficiairePage = true;

                    bool isAlreadLoggedIn = await LoginApi.hasAnAccessToken();
                    if (!isAlreadLoggedIn) {
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BeneficiairesPage(
                                title: 'Bénéficiaires',
                              )),
                    );
                    alreadyStartBeneficiairePage = false;
                    if (!mounted) return;

                    await Future.delayed(const Duration(seconds: 1));

                    setState(() {
                      _dummy++;
                    });
                  });

                  return const Center(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ));
                }
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),*/
                        emailForm(),
                        const SizedBox(
                          height: 10,
                        ),
                        passwordForm(),
                        const SizedBox(
                          height: 10,
                        ),
                        submit(),
                        const SizedBox(
                          height: 80,
                        ),
                        /* Text('Model ${_deviceModel}'),
                        Text('Version $_platformVersion'),
                        Text(
                            'Emulateur ${_physicalDevice == null ? "Unknown" : _physicalDevice! ? "Non" : "Oui"}'),
                        Text(
                            'Mode Avion  ${_statusAirplaneMode == null ? "Unknown" : _statusAirplaneMode! ? "Oui" : "Non"}'),
                        Text(
                            'Jailbroken: ${_jailbroken == null ? "Unknown" : _jailbroken! ? "Oui" : "Non"}'),
                        Text(
                            'Developer mode: ${_developerMode == null ? "Unknown" : _developerMode! ? "Oui" : "Non"}'),
                            */
                        const PermissionLocationWidget(),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = (await AirplaneModeChecker.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    } on MissingPluginException {
      platformVersion = 'Plugin inexistant pour cette plateforme';
    }

    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
            _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            },
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    _deviceModel = deviceData["model"];
    _physicalDevice = deviceData["isPhysicalDevice"];

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }
}

String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Enter a valid email address'
      : null;
}
