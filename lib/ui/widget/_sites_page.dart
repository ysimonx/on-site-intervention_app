import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';

import '../sites_page.dart';
import '../utils/sizes.dart';

Widget getSitesWidget(
    {required BuildContext context,
    required List<Site> sites,
    required Function(int) onRefresh,
    required user}) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(15),
    iconColor: Colors.green,
    textColor: Colors.black54,
    tileColor: Colors.yellow[10],
    style: ListTileStyle.list,
    dense: true,
    child: ListView.builder(
      itemCount: sites.length,
      itemBuilder: (_, index) => Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Text("${sites[index].name.toUpperCase()}"),
          subtitle: Text("${sites[index].tenant.name.toUpperCase()}",
              style: TextStyle(fontSize: ThemeSize.text(xs))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sites[index].getRoleNamesForUser(user).join(", ")),
              IconButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SitePage(user: user, site: sites[index])));
                    onRefresh(1);
                  },
                  icon: const Icon(Icons.navigate_next)),
            ],
          ),
        ),
      ),
    ),
  );
}
