// ignore_for_file: empty_statements, unused_import
import 'dart:async';
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

  Timer? timer;

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
    userAPI = UserApi();
    initTimer();
  }

  void initTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      //job
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
    interventionAPI.downloadPhotos(site: site);
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
                  return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: <Widget>[
                        searchBar(),
                        Expanded(
                            child: widgetListInterventions(
                                listInterventions, context)),
                        const SizedBox(height: 100)
                      ]));
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
        floatingActionButton:
            fabNewScaff(context: context, callback: addIntervention));
  }

  Widget widgetListInterventions(
      List<Intervention> listInterventions, BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return;
        },
        child: ListTileTheme(
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
                title: Row(children: [
                  SizedBox(
                      width: 50,
                      child: Text("#${listInterventions[index].hashtag}")),
                  Text(listInterventions[index].intervention_name.toUpperCase())
                ]),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listInterventions[index].status),
                      Text(listInterventions[index].type_intervention_name)
                    ]),
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
                                user: widget.user,
                                intervention: i,
                                site: widget.site);
                          })).then((value) => setState(() {}));
                        },
                        icon: const Icon(Icons.navigate_next)),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void addIntervention(String typeInterventionName) async {
    Map<String, Formulaire> initializedForms =
        await UserApi.getInterventionFormsFromTemplate(
            user: widget.user,
            site_name: widget.site.name,
            type_intervention_name: typeInterventionName);

    String defaultStatus = UserApi.getDefaultStatusFromTemplate(
        user: widget.user,
        site: widget.site,
        type_intervention_name: typeInterventionName);

    Place nowhere = Place.nowhere(site_id: widget.site.id);

    Intervention newIntervention = Intervention(
        id: "new_${generateUUID()}",
        intervention_name: "nouvelle",
        site_id: widget.site.id,
        intervention_values_on_site_uuid: generateUUID(),
        type_intervention_id:
            typeInterventionName, // let's consider it is an ID
        type_intervention_name: typeInterventionName,
        forms: initializedForms,
        place: nowhere,
        status: defaultStatus);

    if (!context.mounted) {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InterventionPage(
                user: widget.user,
                intervention: newIntervention,
                site: widget.site))).then((value) => setState(() {}));
    ;
  }

  FloatingActionButton fabNewScaff(
      {required BuildContext context,
      required void Function(String typeInterventionName) callback}) {
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
          listTypeInterventions.add({"key": key, "value": value});
        });

        return AlertDialog(
          title: Text(translateI18N("nouvelle intervention").toTitleCase()),
          content: //
              // ListView.builder(itemBuilder: ,)
              SizedBox(
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
              child: Text(translateI18N("annuler").toTitleCase()),
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
    return SearchAnchor(
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
      suggestionsBuilder: (BuildContext context, SearchController controller) {
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
    );
  }
}
