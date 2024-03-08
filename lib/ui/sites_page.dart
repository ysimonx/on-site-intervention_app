// ignore_for_file: empty_statements, unused_import
import 'dart:async';
import 'dart:math' as math;

import 'package:flex_list/flex_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _storage = const FlutterSecureStorage();

  Timer? timer;

  late Future<String> myFuture;

  late List<Intervention> list;
  late FilterList filterList;

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
    userAPI = UserApi();

    filterList = FilterList(
        user: widget.user, user_coordinator: User.nobody(), site: widget.site);

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
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
    logger.d("ta da getListInterventions debut");
    list = await interventionAPI.getListInterventions(
        site: widget.site, realtime: false);

    if (await _storage.containsKey(key: "lastStatus")) {
      String? filteredStatusString = await _storage.read(key: "lastStatus");
      if (filterList.listStatus.contains(filteredStatusString)) {
        filterList.status = filteredStatusString;
      }
    }

    if (await _storage.containsKey(key: "lastCoordinatorUserId")) {
      String? filteredUserId =
          await _storage.read(key: "lastCoordinatorUserId");
      if (filterList.usersCoordinators.isNotEmpty) {
        filterList.user_coordinator = filterList.usersCoordinators[0];
        for (var i = 0; i < filterList.usersCoordinators.length; i++) {
          User u = filterList.usersCoordinators[i];
          if (u.id == filteredUserId) {
            filterList.indiceCoordinator = i;
            filterList.user_coordinator = filterList.usersCoordinators[i];
          }
        }
      }
    }

    if (filterList.user_coordinator.isNobody() == false) {
      List<Intervention> filteredList = [];
      filteredList = list
          .where((intervention) =>
              intervention.assignee_user_id == filterList.user_coordinator.id)
          .toList();
      list = filteredList;
    }

    if (filterList.status != null) {
      if (filterList.status != "") {
        if (filterList.status != "-") {
          List<Intervention> filteredList = [];
          filteredList = list
              .where((intervention) => intervention.status == filterList.status)
              .toList();
          list = filteredList;
        }
      }
    }

    list.sort((i, j) {
      int indiceI;
      int indiceJ;

      if (i.hashtag == "") {
        indiceI = 9999999;
      } else {
        indiceI = int.parse(i.hashtag);
      }
      if (j.hashtag == "") {
        indiceJ = 9999999;
      } else {
        indiceJ = int.parse(j.hashtag);
      }
      return indiceJ.compareTo(indiceI);
    });
    logger.d("ta da getListInterventions fin");

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
                // if (listInterventions.isNotEmpty) {
                logger.d("ta da builder ${listInterventions.length}");
                return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: <Widget>[
                      widgetFilterList(filterList,
                          onChangedFilterList: (FilterList value) {
                        _storage.write(key: "lastStatus", value: value.status);
                        _storage.write(
                            key: "lastCoordinatorUserId",
                            value: value.user_coordinator.id);
                        filterList = value;
                        refreshUI();
                      }),
                      Expanded(
                          child: widgetListInterventions(
                              listInterventions, context)),
                      const SizedBox(height: 100)
                    ]));
                //}
                /* else {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Empty List, go back'),
                    ),
                  );
                }*/
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
                      Text(listInterventions[index].assignee_user!.email),
                      Text(listInterventions[index].type_intervention_name)
                    ]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          Intervention intervention = listInterventions[index];
                          logger.d(
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
                          })).then((intervention) {
                            if (intervention is Intervention) {
                              list[index] = intervention;
                            }
                            refreshUI();
                          });
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
                site: widget.site))).then((value) => refreshUI());
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

  Widget widgetFilterList(FilterList filterList,
      {required Null Function(FilterList value) onChangedFilterList}) {
    List<dynamic> listStatus = UserApi.getListStatusFromTemplate(
        user: widget.user,
        site: widget.site,
        type_intervention_name: "scaffolding request");

    if (listStatus.contains("-")) {
    } else {
      listStatus.insert(0, "-");
    }

    List<User> usersCoordinators =
        UserApi.getCoordinatorsList(user: widget.user, site: widget.site);
    if (usersCoordinators.contains(User.nobody)) {
    } else {
      usersCoordinators.insert(0, User.nobody());
    }

    List<DropdownMenuItem<String>> listStatusDropdownMenuItems = [];
    List<DropdownMenuItem<int>> listDropdownMenuItemsUsers = [];

    for (var i = 0; i < listStatus.length; i++) {
      listStatusDropdownMenuItems.add(
          DropdownMenuItem(value: listStatus[i], child: Text(listStatus[i])));
    }

    for (var i = 0; i < usersCoordinators.length; i++) {
      User u = usersCoordinators[i];
      listDropdownMenuItemsUsers
          .add(DropdownMenuItem(value: i, child: Text(u.email)));
    }
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          SearchAnchor(
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
          ),
          FlexList(horizontalSpacing: 5, verticalSpacing: 10, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Status"),
              DropdownButton<String>(
                  value: filterList.status,
                  items: listStatusDropdownMenuItems,
                  onChanged: (value) {
                    filterList.status = value;
                    onChangedFilterList(filterList);
                    print(value);
                  })
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Coordinator"),
              DropdownButton<int>(
                  value: filterList.indiceCoordinator,
                  items: listDropdownMenuItemsUsers,
                  onChanged: (value) {
                    print(filterList.toString());

                    if (value is int) {
                      filterList.user_coordinator =
                          filterList.usersCoordinators[value];
                      filterList.indiceCoordinator = value;
                      onChangedFilterList(filterList);
                      print(value.toString());
                    }
                  })
            ])
          ]),
        ]));
  }
}

class FilterList {
  final User user;
  String? status = "";
  late List<User> usersCoordinators;
  User user_coordinator;
  late List<dynamic> listStatus;

  int indiceCoordinator = 0;

  FilterList(
      {this.status,
      required this.user_coordinator,
      required this.user,
      required Site site}) {
    listStatus = UserApi.getListStatusFromTemplate(
        user: user, site: site, type_intervention_name: "scaffolding request");

    usersCoordinators = UserApi.getCoordinatorsList(user: user, site: site);
    if (usersCoordinators.contains(User.nobody())) {
    } else {
      usersCoordinators.insert(0, User.nobody());
    }

    if (listStatus.contains("-")) {
    } else {
      listStatus.insert(0, "-");
    }
  }
}
