import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_organization.dart';

import '../organizationpage.dart';

Widget getOrganizationsWidget(
    {required BuildContext context,
    required List<Organization> organizations}) {
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
          subtitle: const Text('subtitle'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrganizationPage(
                                organization: Organization(
                                    id: organizations[index].id,
                                    name: organizations[index].name))));
                  },
                  icon: const Icon(Icons.add_box)),
            ],
          ),
        ),
      ),
    ),
  );
}
