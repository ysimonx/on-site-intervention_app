// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/network/api/image.api.dart';
import 'package:on_site_intervention_app/ui/types_intervention_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/model_user.dart';
import '../../network/api/constants.dart';
import '../../network/api/intervention_api.dart';
import '../../network/api/login_api.dart';
import 'package:flutter/material.dart';

import '../lists_for_places_page.dart';
import '../lists_page.dart';
import '../signature_page.dart';
import '../users_page.dart';
import '../utils/i18n.dart';

// cf https://stackoverflow.com/a/64147831
class AuthentifiedBaseAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Function(int) onCallback;
  final User user;
  final Site? site;

  const AuthentifiedBaseAppBar(
      {super.key,
      required this.title,
      required this.onCallback,
      required this.user,
      this.site});

  static const int valueDECONNEXION = 0;
  static const int valueLIST = 1;
  static const int valueUSERS = 2;
  static const int valueACCOUNT = 4;
  static const int valueUPLOADIMAGES = 5;
  static const int valueREMOVEFILES = 6;
  static const int valueSIGNATURE = 7;
  static const int valueLISTFORPLACES = 8;
  static const int valueINFOAPP = 9;
  static const int valueGOOGLESTORE = 10;
  static const int valueTYPESINTERVENTION = 11;
  static const int valueEXPORTCSV = 12;

  @override
  Widget build(BuildContext context) {
    //
    //

    return AppBar(
      toolbarHeight: 200,
      centerTitle: true,
      // TRY THIS: Try changing the color here to a specific color (to
      // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      // change color while the other colors stay the same.
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Column(children: [
        Image.asset(
          'assets/icons/logo_fidwork.png',
          fit: BoxFit.contain,
          height: 40,
        ),
        Text(title.toUpperCase())
      ]),
      actions: [
        (title != "Login")
            ? PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: valueACCOUNT,
                    child: Text(user.email.toLowerCase()),
                  ),
                  PopupMenuItem<int>(
                    value: valueINFOAPP,
                    child: Text(translateI18N("App info").toCapitalized()),
                  ),
                  PopupMenuItem<int>(
                    value: valueGOOGLESTORE,
                    child: Text(translateI18N("App Store").toCapitalized()),
                  ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin") ||
                        site!
                            .getRoleNamesForUser(user)
                            .contains("site administrator"))
                      PopupMenuItem<int>(
                        value: valueUSERS,
                        child:
                            Text(translateI18N("utilisateurs").toCapitalized()),
                      ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin") ||
                        site!
                            .getRoleNamesForUser(user)
                            .contains("site administrator"))
                      PopupMenuItem<int>(
                        value: valueTYPESINTERVENTION,
                        child: Text(translateI18N("types d'interventions")
                            .toCapitalized()),
                      ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin") ||
                        site!
                            .getRoleNamesForUser(user)
                            .contains("site administrator"))
                      PopupMenuItem<int>(
                        value: valueLIST,
                        child: Text(translateI18N("listes").toCapitalized()),
                      ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin") ||
                        site!
                            .getRoleNamesForUser(user)
                            .contains("site administrator"))
                      PopupMenuItem<int>(
                        value: valueLISTFORPLACES,
                        child:
                            Text(translateI18N("emplacements").toCapitalized()),
                      ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin") ||
                        site!
                            .getRoleNamesForUser(user)
                            .contains("site administrator"))
                      PopupMenuItem<int>(
                        value: valueEXPORTCSV,
                        child:
                            Text(translateI18N("export csv").toCapitalized()),
                      ),
                  const PopupMenuItem<int>(
                      value: valueREMOVEFILES,
                      child: Text("remove local files")),
                  PopupMenuItem<int>(
                    value: valueDECONNEXION,
                    child: Text(translateI18N("déconnexion").toCapitalized()),
                  ),
                ];
              }, onSelected: (value) async {
                if (value == valueUPLOADIMAGES) {
                  ImageApi.uploadPhotos();
                }
                if (value == valueREMOVEFILES) {
                  await InterventionApi.deleteLocalUpdatedFiles();
                }
                if (value == valueDECONNEXION) {
                  LoginApi loginApi = LoginApi();
                  await loginApi.deleteTokens();

                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                  onCallback(1);
                }
                if (value == valueLIST) {
                  if (context.mounted) {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ListsPage(site: site, user: user);
                    }));
                  }
                }
                if (value == valueLISTFORPLACES) {
                  if (context.mounted) {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ListsForPlacesPage(site: site, user: user);
                    }));
                  }
                }

                if (value == valueUSERS) {
                  if (context.mounted) {
                    if (site != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return UsersPage(
                            site: site!,
                            tenants: user.tenants_administrator_of,
                            user: user);
                      }));
                    }
                  }
                }
                if (value == valueTYPESINTERVENTION) {
                  if (context.mounted) {
                    if (site != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TypesInterventionPage(
                            site: site!,
                            tenants: user.tenants_administrator_of,
                            user: user);
                      }));
                    }
                  }
                }
                if (value == valueINFOAPP) {
                  final info = await PackageInfo.fromPlatform();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${info.appName} version ${info.version}'),
                        duration: Duration(seconds: 5)),
                  );
                }
                if (value == valueGOOGLESTORE) {
                  //
                  final Uri _url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=fr.fidwork.app&hl=fr-FR');
                  if (!await launchUrl(_url)) {
                    throw Exception('Could not launch $_url');
                  }
                }
                if (value == valueEXPORTCSV) {
                  //
                  String url =
                      "${Endpoints.baseUrl}${Endpoints.exportInterventionsCSV.replaceAll("<site_id>", site!.id)}";

                  final Uri _url = Uri.parse(url);
                  if (!await launchUrl(_url)) {
                    throw Exception('Could not launch $_url');
                  }
                }
              })
            : const Text(''),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const BaseAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 200,
      centerTitle: true,
      // TRY THIS: Try changing the color here to a specific color (to
      // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      // change color while the other colors stay the same.
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Column(children: [
        Image.asset(
          'assets/icons/logo_fidwork.png',
          fit: BoxFit.contain,
          height: 40,
        ),
        Text(title.toUpperCase())
      ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
