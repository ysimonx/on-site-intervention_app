// ignore_for_file: unused_import

import 'package:dio/dio.dart';
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
                                  leading: Icon(Icons.person),
                                  subtitle: Text("roles: ${sroles}"),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              _showDialog(
                                                  callback: CB,
                                                  site: s,
                                                  email: u.email,
                                                  roles: dictRolesUsers[u.id]
                                                      as List<String>);
                                            },
                                            icon: const Icon(
                                                Icons.manage_accounts)),
                                        IconButton(
                                            onPressed: () async {
                                              SiteApi siteApi = SiteApi();

                                              Response response =
                                                  await siteApi.RemoveUserRoles(
                                                      site_id: s.id,
                                                      email: u.email);

                                              if (response.statusCode == 200) {
                                                CB("Processing Data");
                                              }
                                              if (response.statusCode == 400) {
                                                CB("Processing Data Error ${response.data["error"]}");
                                              }
                                            },
                                            icon: const Icon(Icons.cancel)),
                                      ])));
                        }));
              }
              return Text("loading");
            }),
        floatingActionButton: FAB_User(context: context, callback: CB));
  }

  void CB(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${message}")),
    );
    setState(() {});
  }

  FloatingActionButton FAB_User(
      {required BuildContext context,
      required void Function(String message) callback}) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        _showDialog(callback: callback, site: s, email: null, roles: []);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showDialog(
      {required void Function(String message) callback,
      required Site site,
      required String? email,
      required List<String> roles}) {
    late TextEditingController textEmailController = TextEditingController();

    Map<String, bool> dictSiteRoles = {};
    SiteApi siteApi = SiteApi();

    if (email != null) {
      textEmailController.text = email;
    }

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
            if (roles.contains(jsonRole["name"])) {
              dictSiteRoles[jsonRole["id"]] = true;
            }
          });
        }
        return LayoutBuilder(
            builder: (_, constrains) => AlertDialog(
                  title: (email == null)
                      ? Text(I18N("nouvel utilisateur").toTitleCase())
                      : Text(email.toTitleCase()),
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(children: [
                      /*const Text(
                            "En tant qu'administrateur  vous pouvez administrer la liste des utilisateurs",
                          ),*/
                      (email == null)
                          ? TextField(
                              controller: textEmailController,
                              autofocus: true,
                              decoration: InputDecoration(
                                  hintText:
                                      "Enter the e-mail address of the new user"
                                          .toCapitalized()),
                            )
                          : const Text(""),
                      SizedBox(
                          width: constrains.maxWidth * .8,
                          height: constrains.maxHeight * .7, //
                          child: ListView.builder(
                              itemCount: listRoles.length,
                              itemBuilder: (_, index) {
                                Map<String, dynamic> jsonRole =
                                    listRoles[index];
                                return Card(
                                    margin: const EdgeInsets.all(10),
                                    child: CheckboxListTile(
                                      title: Text(jsonRole["name"]),
                                      value: dictSiteRoles[jsonRole["id"]],
                                      onChanged: (newValue) {
                                        setState(() {
                                          // checkedValue = newValue!;
                                          dictSiteRoles[jsonRole["id"]] =
                                              newValue!;
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
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Ok'),
                      onPressed: () async {
                        String email = textEmailController.text;
                        List<String> roles_id = [];

                        dictSiteRoles.forEach((key, value) {
                          if (value) {
                            roles_id.add(key);
                          }
                        });
                        Response response = await siteApi.AddUserRoles(
                            site_id: s.id, email: email, roles_id: roles_id);

                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          callback("Processing Data");
                          return;
                        }
                        if (response.statusCode == 400) {
                          Navigator.pop(context);
                          callback(
                              "Processing Data Error ${response.data["error"]}");
                          return;
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
