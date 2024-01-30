import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';

import '../sitepage.dart';

Widget getSitesWidget(
    {required BuildContext context, required List<Site> sites}) {
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
          title: Text(sites[index].name.toUpperCase()),
          subtitle: const Text('subtitle'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SitePage(
                                site: Site(
                                    id: sites[index].id,
                                    name: sites[index].name))));
                  },
                  icon: const Icon(Icons.navigate_next)),
            ],
          ),
        ),
      ),
    ),
  );
}
