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

Widget getOrganizationsWidgets2(
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
          subtitle: Text('subtitle'),
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
                            builder: (context) => const SecondRoute()));
                  },
                  icon: const Icon(Icons.add_box)),
            ],
          ),
        ),
      ),
    ),
  );
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
