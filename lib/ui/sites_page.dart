// ignore_for_file: empty_statements, unused_import
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:on_site_intervention_app/ui/intervention_page.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_place.dart';
import '../models/model_user.dart';
import '../network/api/intervention_api.dart';
import '../network/api/login_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'utils/logger.dart';
import 'utils/uuid.dart';
import 'widget/app_bar.dart';

class SitePage extends StatefulWidget {
  const SitePage({super.key, required this.site, required this.user});

  final Site site;
  final User user;
  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  late UserApi userAPI;
  late InterventionApi interventionAPI;
  bool isDark = false;
  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
    userAPI = UserApi();
  }

  PreferredSize widgetAppBar(
      {required String title, required User user, required Site site}) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: user.isAuthorized()
            ? AuthentifiedBaseAppBar(
                title: title,
                user: user,
                site: site,
                onCallback: (value) => setState(() {}))
            : BaseAppBar(title: title));
  }

  Future<List<Intervention>> getInterventions({required Site site}) async {
    List<Intervention> list = await interventionAPI.getList(site: site);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widgetAppBar(
            title: widget.site.name, user: widget.user, site: widget.site),
        body: FutureBuilder(
            future: getInterventions(site: widget.site),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Intervention> listInterventions = snapshot.data;
                if (listInterventions.isNotEmpty) {
                  return Column(children: <Widget>[
                    searchBar(),
                    Expanded(
                        child:
                            widgetListInterventions(listInterventions, context))
                  ]);
                } else {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Empty List, go back'),
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }),
        floatingActionButton: fabNewScaff(context, addIntervention));
  }

  ListTileTheme widgetListInterventions(
      List<Intervention> listInterventions, BuildContext context) {
    return ListTileTheme(
      contentPadding: const EdgeInsets.all(15),
      style: ListTileStyle.list,
      dense: true,
      child: ListView.builder(
        itemCount: listInterventions.length,
        itemBuilder: (_, index) => Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: (listInterventions[index].type_intervention_name ==
                    "calorifuge")
                ? const Icon(Icons.local_fire_department)
                : const Icon(Icons.foundation),
            title:
                Text(listInterventions[index].intervention_name.toUpperCase()),
            subtitle: Text(listInterventions[index].type_intervention_name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () async {
                      Intervention i = listInterventions[index];

                      if (!context.mounted) {
                        return;
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return InterventionPage(
                            intervention: i, site: widget.site);
                      })).then((value) => setState(() {}));
                    },
                    icon: const Icon(Icons.navigate_next)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addIntervention(String typeInterventionName) async {
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
  }

  FloatingActionButton fabNewScaff(BuildContext context,
      void Function(String typeInterventionName) callback) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        _showDialog(callback);
      },
      child: const Icon(Icons.add),
    );
  }

  void _showDialog(void Function(String typeInterventionName) callback) {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> x = widget.user.myconfig.config_types_intervention;
        List<Map<String, dynamic>> listTypeInterventions = [];
        x.forEach((key, value) {
          print(key);
          listTypeInterventions.add({"key": key, "value": value});
        });

        return AlertDialog(
          title: Text(I18N("nouvelle intervention").toTitleCase()),
          content: //
              // ListView.builder(itemBuilder: ,)
              Container(
                  height: 300.0, // Change as per your requirement
                  width: 300.0, //
                  child: ListView.builder(
                      itemCount: listTypeInterventions.length,
                      itemBuilder: (_, index) => Card(
                            margin: const EdgeInsets.all(10),
                            child: ElevatedButton(
                                onPressed: () async {
                                  String typeInterventionName =
                                      listTypeInterventions[index]["key"];
                                  Navigator.pop(context);
                                  callback(typeInterventionName);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(listTypeInterventions[index]
                                      ["key"]), // <-- Text
                                )),
                          ))),
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

  Widget searchBar() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Change brightness mode',
                  child: IconButton(
                    isSelected: isDark,
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.brightness_2_outlined),
                  ),
                )
              ],
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          },
        ));
  }
}
