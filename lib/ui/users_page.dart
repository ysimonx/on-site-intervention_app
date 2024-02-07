// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';

import '../models/model_user.dart';
import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'widget/app_bar.dart';

class UsersPage extends StatefulWidget {
  final List<Tenant> tenants;
  final Site site;
  final User user;
  const UsersPage(
      {super.key,
      required this.tenants,
      required this.site,
      required this.user});

  @override
  State<StatefulWidget> createState() {
    return UsersPageState();
  }
}

// Create a corresponding State class.
class UsersPageState extends State<UsersPage> {
  Map<String, User> dictUser = {};
  Map<String, List<String>> dictRolesUsers = {};
  late Site s;

  late String _title = 'users';

  @override
  void initState() {
    super.initState();

    dictUser = {};
    dictRolesUsers = {};
    _title = "${widget.site.name} : users";
  }

  Future<List<User>> getMyInformations() async {
    SiteApi siteApi = SiteApi();
    s = await siteApi.readSite(idSite: widget.site.id);
    dictUser = {};
    dictRolesUsers = {};

    for (var i = 0; i < s.roles.length; i++) {
      Map<String, dynamic> item = s.roles[i];
      item.forEach((key, jsonRole) {
        String roleName = jsonRole["name"];
        var users = jsonRole["users"];

        for (var i = 0; i < users.length; i++) {
          var jsonUser = users[i];
          User u = User.fromJson(jsonUser["user"]);
          dictUser[u.id] = u;

          if (!dictRolesUsers.containsKey(u.id)) {
            dictRolesUsers[u.id] = [];
          }
          dictRolesUsers[u.id]?.add(roleName);
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
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<User> listUsers = snapshot.data;
            return widgetBody(listUsers);
          } else if (snapshot.hasError) {
            return widgetError(widget.user);
          } else {
            return widgetWaiting(widget.user);
          }
        });
  }

  Scaffold widgetWaiting(User? user) {
    return Scaffold(
        appBar: widgetAppBar(user),
        body: const Center(
            child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        )));
  }

  Scaffold widgetError(User? user) {
    return Scaffold(appBar: widgetAppBar(user), body: const Text("error"));
  }

  PreferredSize widgetAppBar(User? me) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: (me != null && me.isAuthorized())
            ? AuthentifiedBaseAppBar(
                title: _title, user: me, onCallback: (value) => setState(() {}))
            : const BaseAppBar(title: "login"));
  }

  Widget widgetBody(List<User> listUsers) {
    return Scaffold(
      appBar: widgetAppBar(widget.user),
      body: ListTileTheme(
          contentPadding: const EdgeInsets.all(15),
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
                        title: Text(u.email),
                        leading: const Icon(Icons.person_2_outlined),
                        subtitle: Text("roles: $sroles"),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              onPressed: () async {
                                _showDialog(
                                    callback: callBack,
                                    site: s,
                                    email: u.email,
                                    roles:
                                        dictRolesUsers[u.id] as List<String>);
                              },
                              icon: const Icon(Icons.manage_accounts)),
                          IconButton(
                              onPressed: () async {
                                SiteApi siteApi = SiteApi();

                                Response response =
                                    await siteApi.removeUserRoles(
                                        idSite: s.id, email: u.email);

                                if (response.statusCode == 200) {
                                  callBack("Processing Data");
                                }
                                if (response.statusCode == 400) {
                                  callBack(
                                      "Processing Data Error ${response.data["error"]}");
                                }
                              },
                              icon: const Icon(Icons.cancel)),
                        ])));
              })),
      floatingActionButton: fabAddUser(context: context, callback: callBack),
    );
  }

  void callBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {});
  }

  FloatingActionButton fabAddUser(
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
                      ? Text(translateI18N("nouvel utilisateur").toTitleCase())
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
                      child: Text(translateI18N("annuler").toTitleCase()),
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
                        List<String> idsRole = [];

                        dictSiteRoles.forEach((key, value) {
                          if (value) {
                            idsRole.add(key);
                          }
                        });
                        Response response = await siteApi.addUserRoles(
                            idSite: s.id, email: email, idsRoles: idsRole);

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
