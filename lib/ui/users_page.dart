// ignore_for_file: unused_import, prefer_conditional_assignment

import 'package:diacritic/diacritic.dart';
import 'package:dio/dio.dart';
import 'package:flex_list/flex_list.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';

import '../models/model_user.dart';
import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'widget/app_bar.dart';
import 'widget/common_widgets.dart';

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
            return widgetError();
          } else {
            return widgetWaiting();
          }
        });
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
    listUsers.sort((u1, u2) => u1.lastname.compareTo(u2.lastname));

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
                        title: Text(
                            "${u.lastname.toUpperCase()}, ${u.firstname.toCapitalized()}"),
                        leading: const Icon(Icons.person_2_outlined),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.company.toUpperCase()),
                            Text(u.phone),
                            Text(u.email),
                            Text(
                              "roles: $sroles",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              onPressed: () async {
                                _showDialog(
                                    callback: callBack,
                                    site: s,
                                    user: u,
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
        _showDialog(
            callback: callback, site: s, user: User.nobody(), roles: []);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showDialog(
      {required void Function(String message) callback,
      required Site site,
      required List<String> roles,
      required User user}) {
    late TextEditingController textEmailController = TextEditingController();
    late TextEditingController textFirstnameController =
        TextEditingController();
    late TextEditingController textLastnameController = TextEditingController();
    late TextEditingController textPhoneController = TextEditingController();
    late TextEditingController textCompanyController = TextEditingController();

    Map<String, bool> dictSiteRoles = {};
    SiteApi siteApi = SiteApi();

    textEmailController.text = user.email;
    textFirstnameController.text = user.firstname;
    textLastnameController.text = user.lastname;
    textPhoneController.text = user.phone;
    textCompanyController.text = user.company;
    List<String> listCompanies = [];

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
            List<dynamic> users = jsonRole["users"];
            for (var j = 0; j < users.length; j++) {
              Map<String, dynamic> userJSON = users[j]["user"];

              if (userJSON["company"] != null) {
                String company = userJSON["company"];

                if (listCompanies.contains(company) == false) {
                  listCompanies.add(company);
                }
              }
            }
          });
        }
        return AlertDialog(
          title: (user.isNobody())
              ? Text(translateI18N("nouvel utilisateur").toTitleCase())
              : Text(user.email.toTitleCase()),
          content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(children: [
                  /*const Text(
                            "En tant qu'administrateur  vous pouvez administrer la liste des utilisateurs",
                          ),*/

                  SizedBox(
                      width: double.maxFinite,
                      child: TextField(
                        controller: textFirstnameController,
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.name,
                        autofocus: true,
                        onChanged: (value) {
                          value = value.replaceAll(" ", "");
                          // value = removeDiacritics(value);
                          textFirstnameController.value = TextEditingValue(
                              text: value.toLowerCase(),
                              selection: textFirstnameController.selection);
                        },
                        decoration:
                            InputDecoration(hintText: "Prénom".toCapitalized()),
                      )),
                  SizedBox(
                    width: double.maxFinite,
                    child: TextField(
                      controller: textLastnameController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.name,
                      autofocus: true,
                      onChanged: (value) {
                        value = value.replaceAll(" ", "");
                        // value = removeDiacritics(value);
                        textLastnameController.value = TextEditingValue(
                            text: value.toLowerCase(),
                            selection: textLastnameController.selection);
                      },
                      decoration:
                          InputDecoration(hintText: "Nom".toCapitalized()),
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: TextField(
                      controller: textPhoneController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      onChanged: (value) {
                        value = value.replaceAll(" ", "");
                        // value = removeDiacritics(value);
                        textPhoneController.value = TextEditingValue(
                            text: value.toLowerCase(),
                            selection: textPhoneController.selection);
                      },
                      decoration: InputDecoration(
                          hintText: "Téléphone".toCapitalized()),
                    ),
                  ),
                  (user.isNobody())
                      ? SizedBox(
                          width: double.maxFinite,
                          child: TextField(
                            controller: textEmailController,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                            onChanged: (value) {
                              value = value.replaceAll(" ", "");
                              value = removeDiacritics(value);
                              textEmailController.value = TextEditingValue(
                                  text: value.toLowerCase(),
                                  selection: textEmailController.selection);
                            },
                            decoration: InputDecoration(
                                hintText: "E-mail".toCapitalized()),
                          ),
                        )
                      : const SizedBox(width: double.maxFinite, height: 0),
                  genRawAutoCompleteCompany(
                      companies: listCompanies,
                      onSubmit: (value) {
                        textCompanyController.text = value;
                      },
                      initialValue: textCompanyController.text),
                  Flexible(
                      // width: constrains.maxWidth * .8,
                      //height: constrains.maxHeight * .7, //
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
              })),
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
                String email = textEmailController.text.toLowerCase();
                List<String> idsRole = [];
                user.email = textEmailController.text.toLowerCase();
                user.firstname = textFirstnameController.text.toLowerCase();
                user.lastname = textLastnameController.text.toLowerCase();
                user.phone = textPhoneController.text.toLowerCase();
                user.company = textCompanyController.text.toLowerCase();
                dictSiteRoles.forEach((key, value) {
                  if (value) {
                    idsRole.add(key);
                  }
                });

                try {
                  Response response = await siteApi.addUserRoles(
                      idSite: s.id,
                      email: email,
                      user: user,
                      idsRoles: idsRole);

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    callback("Processing Data");
                    return;
                  }
                  if (response.statusCode == 400) {
                    Navigator.pop(context);
                    callback("Processing Data Error ${response.data["error"]}");
                    return;
                  }
                } on Exception catch (e) {
                  callback("Processing Data Error ${e.toString()}");
                }
              },
            ),
          ],
        );
      },
    );
  }

  RawAutocomplete<String> genRawAutoCompleteCompany(
      {required String? initialValue,
      required Null Function(dynamic value) onSubmit,
      required List<String> companies}) {
    if (initialValue == null) {
      initialValue = "";
    }
    companies.sort();

    return RawAutocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textEditingValue) {
        List<String> options = companies;

        return options.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          // initialValue: initialValue,
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (String value) {
            onSubmit(value);
          },
          onFieldSubmitted: (String value) {
            //  onFieldSubmitted();

            onSubmit(value);
          },
        );
      },
      onSelected: (value) {
        // ICI !
        onSubmit(value);
      },
      optionsViewBuilder: (BuildContext context,
          void Function(String) onSelected, Iterable<String> options) {
        return Align(
            alignment: Alignment.topLeft,
            child: Material(
                elevation: 4.0,
                child: SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option),
                          ),
                        );
                      },
                    ))));
      },
    );
  }
}
