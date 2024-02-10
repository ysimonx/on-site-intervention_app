import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';

import '../sites_page.dart';
import '../utils/sizes.dart';

Widget getSitesWidget(
    {required BuildContext context,
    required List<Site> sites,
    required Function(int) onRefresh,
    required user}) {
  //
  // sort list
  //
  sites.sort((s1, s2) => s1.name.compareTo(s2.name));

  return Column(children: <Widget>[
    Expanded(
      child: ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        style: ListTileStyle.list,
        dense: true,
        child: ListView.builder(
          itemCount: sites.length,
          itemBuilder: (_, index) => Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.business, size: 40),
              title: Text(sites[index].name.toUpperCase()),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                        "Organization : ${sites[index].tenant.name.toUpperCase()}",
                        style: TextStyle(fontSize: ThemeSize.text(xs))),
                    Text(
                        "Roles : ${sites[index].getRoleNamesForUser(user).join(", ")}",
                        style: TextStyle(fontSize: ThemeSize.text(xs))),
                  ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    iconSize: 30,
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SitePage(user: user, site: sites[index])));
                      onRefresh(1);
                    },
                    icon: const Icon(Icons.navigate_next))
              ]),
            ),
          ),
        ),
      ),
    )
  ]);
}
