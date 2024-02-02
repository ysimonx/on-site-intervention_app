// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';

import '../models/model_user.dart';
import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';

class UsersPage extends StatefulWidget {
  final List<Tenant> tenants;
  final Site site;
  const UsersPage({super.key, required this.tenants, required this.site});

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

// Create a corresponding State class.
class UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();

    dictUser = {};
    dictRolesUsers = {};
  }

  Map<String, User> dictUser = {};
  Map<String, List<String>> dictRolesUsers = {};
  late Site s;

  Future<List<User>> getUsersList() async {
    SiteApi siteApi = SiteApi();
    s = await siteApi.readSite(site_id: widget.site.id);
    dictUser = {};
    dictRolesUsers = {};

    for (var i = 0; i < s.roles.length; i++) {
      Map<String, dynamic> item = s.roles[i];
      item.forEach((key, jsonRole) {
        String role_name = jsonRole["name"];
        var users = jsonRole["users"];

        for (var i = 0; i < users.length; i++) {
          var jsonUser = users[i];
          User u = User.fromJson(jsonUser["user"]);
          print(u.id);
          dictUser[u.id] = u;

          if (!dictRolesUsers.containsKey(u.id)) {
            dictRolesUsers[u.id] = [];
          }
          dictRolesUsers[u.id]?.add(role_name);
        }
      });
    }

    List<User> res = [];

    dictUser.forEach((key, user) {
      res.add(user);
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Users"),
        ),
        body: FutureBuilder(
            future: getUsersList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<User> listUsers = snapshot.data;
                return ListTileTheme(
                    contentPadding: const EdgeInsets.all(15),
                    iconColor: Colors.green,
                    textColor: Colors.black54,
                    tileColor: Colors.yellow[10],
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: listUsers.length,
                        itemBuilder: (_, index) {
                          User u = listUsers[index];
                          String sroles = dictRolesUsers[u.id]!.join(", ");
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                                title: Text('${u.email}'),
                                subtitle: Text("roles: ${sroles}")),
                          );
                        }));
              }
              return Text("to");
            }),
        floatingActionButton: FAB_User(context: context, callback: go));
  }

  void go(String typeInterventionName) async {
    // String typeInterventionName = "scaffolding request";

    /*
    UserApi userAPI = UserApi();

    Map<String, Formulaire> initializedForms =
        await userAPI.getInterventionFormsFromTemplate(
            site_name: widget.site.name,
            type_intervention_name: typeInterventionName);

    Place nowhere = Place.nowhere(site_id: widget.site.id);

    Intervention newIntervention = Intervention(
      id: "new_${generateUUID()}",
      intervention_name: "nouvelle",
      site_id: widget.site.id,
      intervention_values_on_site_uuid: generateUUID(),
      type_intervention_id: typeInterventionName, // let's consider it is an ID
      type_intervention_name: typeInterventionName,
      forms: initializedForms,
      place: nowhere,
    );

    if (!context.mounted) {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InterventionPage(
                intervention: newIntervention,
                site: widget.site))).then((value) => setState(() {}));
    ;
    */
  }

  FloatingActionButton FAB_User(
      {required BuildContext context,
      required void Function(String typeInterventionName) callback}) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        _showDialog(callback: callback, site: s);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showDialog(
      {required void Function(String typeInterventionName) callback,
      required Site site}) {
    bool checkedValue = true;
    late TextEditingController textEmailController = TextEditingController();
    Map<String, bool> dictSiteRoles = {};

    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        List<Map<String, dynamic>> listRoles = [];
        for (var i = 0; i < site.roles.length; i++) {
          Map<String, dynamic> x = site.roles[i];
          x.forEach((key, jsonRole) {
            listRoles.add(jsonRole);
            dictSiteRoles[jsonRole["id"]] = false;
          });
        }
        // listRoles = ["admin", "supervisor", "gnass"];
        return AlertDialog(
          title: Text(I18N("nouvel utilisateur").toTitleCase()),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(children: [
              const Text(
                "En tant qu'administrateur  vous pouvez administrer la liste des utilisateurs",
              ), //
              TextField(
                controller: textEmailController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: "Enter the e-mail address of the new user"
                        .toCapitalized()),
              ),
              Container(
                  height: 300.0, // Change as per your requirement
                  width: 300.0, //
                  child: ListView.builder(
                      itemCount: listRoles.length,
                      itemBuilder: (_, index) {
                        Map<String, dynamic> jsonRole = listRoles[index];
                        return Card(
                            margin: const EdgeInsets.all(10),
                            child: CheckboxListTile(
                              title: Text(jsonRole["name"]),
                              value: dictSiteRoles[jsonRole["id"]],
                              onChanged: (newValue) {
                                setState(() {
                                  // checkedValue = newValue!;
                                  dictSiteRoles[jsonRole["id"]] = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ));
                      }))
            ]);
          }),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(I18N("annuler").toTitleCase()),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
