import '../../network/api/login_api.dart';
import 'package:flutter/material.dart';

import '../utils/i18n.dart';

// cf https://stackoverflow.com/a/64147831
class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(int) onDeconnexion;

  const BaseAppBar(this.title, {super.key, required this.onDeconnexion});

  static const int valueDECONNEXION = 0;
  static const int valueLIST = 1;

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
                  onDeconnexion(1);
                }
                if (value == valueLIST) {
                  LoginApi loginApi = LoginApi();
                  await loginApi.deleteTokens();

                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                  onDeconnexion(1);
                }
              })
            : const Text(''),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
