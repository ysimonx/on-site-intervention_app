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
  final String tenant;
  final Function(int) onCallback;
  final User user;

  const AuthentifiedBaseAppBar(
      {super.key,
      required this.title,
      required this.onCallback,
      required this.tenant,
      required this.user});

  static const int valueDECONNEXION = 0;
  static const int valueLIST = 1;
  static const int valueUSERS = 2;
  static const int valueREFRESH = 3;

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
                    value: valueREFRESH,
                    child: Text(I18N("Refresh").toTitleCase()),
                  ),
                  PopupMenuItem<int>(
                    value: valueUSERS,
                    child: Text(I18N("gestion des utilisateurs").toTitleCase()),
                  ),
                  PopupMenuItem<int>(
                    value: valueLIST,
                    child: Text(I18N("gestion des listes").toTitleCase()),
                  ),
                  PopupMenuItem<int>(
                    value: valueDECONNEXION,
                    child: Text(I18N("déconnexion").toTitleCase()),
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
                      return ListsPage(tenant: tenant);
                    }));
                  }
                }
                if (value == valueUSERS) {
                  if (context.mounted) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UsersPage(tenant: tenant);
                    }));
                  }
                }
                if (value == valueREFRESH) {
                  onCallback(1);
                }
              })
            : const Text(''),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// cf https://stackoverflow.com/a/64147831
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
