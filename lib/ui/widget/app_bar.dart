import 'package:on_site_intervention_app/models/model_site.dart';

import '../../models/model_user.dart';
import '../../network/api/login_api.dart';
import 'package:flutter/material.dart';

import '../lists_page.dart';
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
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin"))
                      PopupMenuItem<int>(
                        value: valueUSERS,
                        child: Text(
                            I18N("gestion des utilisateurs").toCapitalized()),
                      ),
                  if (site != null)
                    if (site!.getRoleNamesForUser(user).contains("admin"))
                      PopupMenuItem<int>(
                        value: valueLIST,
                        child: Text(I18N("gestion des listes").toCapitalized()),
                      ),
                  PopupMenuItem<int>(
                    value: valueDECONNEXION,
                    child: Text(I18N("déconnexion").toCapitalized()),
                  ),
                ];
              }, onSelected: (value) async {
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ListsPage(tenants: user.tenants_administrator_of);
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
                            tenants: user.tenants_administrator_of);
                      }));
                    }
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
