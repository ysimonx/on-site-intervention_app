import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';

Widget getOrganizationsWidgets({required List<Organization> organizations}) {
  List<Widget> res = [];

  for (var i = 0; i < organizations.length; i++) {
    Organization organization = organizations[i];
    Widget item = ListTile(
      title: Text(organization.name),
      subtitle: Text('subtitle'),
      trailing: Icon(Icons.star),
      leading:
          CircleAvatar(backgroundColor: Colors.amber, child: Text("${i + 1}")),
    );
    res.add(item);
  }
  return ListView(padding: const EdgeInsets.all(15), children: res);
}

Widget getOrganizationsWidgets2({required List<Organization> organizations}) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(15),
    iconColor: Colors.green,
    textColor: Colors.black54,
    tileColor: Colors.yellow[10],
    style: ListTileStyle.list,
    dense: true,
    child: ListView.builder(
      itemCount: organizations.length,
      itemBuilder: (_, index) => Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Text(organizations[index].name.toUpperCase()),
          subtitle: Text('subtitle'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add_box)),
            ],
          ),
        ),
      ),
    ),
  );
}
