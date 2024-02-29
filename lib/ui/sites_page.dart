// ignore_for_file: empty_statements, unused_import
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:on_site_intervention_app/ui/intervention_page.dart';
import 'package:on_site_intervention_app/ui/widget/common_widgets.dart';

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

  late Future<String> myFuture;

  late List<Intervention> list;

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
    userAPI = UserApi();
    myFuture = Future<String>.delayed(
      const Duration(seconds: 1),
      () => getListInterventions(),
    );
    // initTimer();
  }

  void refreshUI() {
    setState(() {
      myFuture = Future<String>.delayed(
        const Duration(seconds: 1),
        () => getListInterventions(),
      );
    });
  }

  void initTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      //job
      refreshUI();
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

  Future<String> getListInterventions() async {
    logger.i("ta da getListInterventions debut");
    list = await interventionAPI.getListInterventions(site: widget.site);
    list.sort((i, j) => int.parse(j.hashtag).compareTo(int.parse(i.hashtag)));
    logger.i("ta da getListInterventions fin");
    return "ok";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widgetAppBar(
            title: widget.site.name, user: widget.user, site: widget.site),
        body: FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                // List<Intervention> listInterventions = snapshot.data;
                List<Intervention> listInterventions = list;
                if (listInterventions.isNotEmpty) {
                  logger.i("ta da builder ${listInterventions.length}");
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
                return widgetError();
              } else {
                return widgetWaiting();
              }
            }),
        floatingActionButton:
            fabNewScaff(context: context, callback: addIntervention));
  }

  Widget widgetListInterventions(
      List<Intervention> listInterventions, BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          refreshUI();

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
                          Intervention intervention = listInterventions[index];
                          logger.i(
                              "ta da avant push ${intervention.field_on_site_uuid_values['36448a1b-3f11-463a-bf60-7668f32da094']}");
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return InterventionPage(
                                user: widget.user,
                                intervention: intervention,
                                site: widget.site);
                          })).then((intervention) => setState(() {
                                list[index] = intervention;
                                logger.i(
                                    "ta da apres push ${intervention.field_on_site_uuid_values['36448a1b-3f11-463a-bf60-7668f32da094']}");
                              }));
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
