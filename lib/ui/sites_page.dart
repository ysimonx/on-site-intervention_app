// ignore_for_file: empty_statements, unused_import, non_constant_identifier_names
import 'dart:async';
import 'dart:math' as math;

import 'package:flex_list/flex_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api/tc.dart';
import 'intervention_page.dart';
import 'widget/common_widgets.dart';
import 'widget/filter_list.dart';
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
  final User user;
  final Site site;

  const SitePage({super.key, required this.user, required this.site});

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  late UserApi userAPI;
  late InterventionApi interventionAPI;
  bool isDark = false;
  final _storage = const FlutterSecureStorage(
      mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
          synchronizable: true));

  Timer? timer;

  late Future<String> myFuture;

  late List<Intervention> list;
  late FilterList filterList;

  List<Intervention> prec_result = [];

  late TC tc;

  @override
  void initState() {
    super.initState();

    interventionAPI = InterventionApi();
    userAPI = UserApi();
    tc = TC();
  }

  @override
  void didChangeDependencies() {
    filterList = FilterList(
        user: widget.user, user_coordinator: User.nobody(), site: widget.site);
    myFuture = futureMethod();
    initTimer();
    super.didChangeDependencies();
  }

  void refreshUI() {
    setState(() {
      myFuture = futureMethod();
    });
  }

  Future<String> futureMethod() {
    return Future<String>.delayed(
      const Duration(microseconds: 100),
      () {
        return getListInterventions();
      },
    );
  }

  void initTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
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

    List<Intervention> result = [];

    result = await interventionAPI.getListInterventions(
        site: widget.site,
        realtime: false,
        prec_result: prec_result,
        from: "sites_page");

    prec_result = result;

    if (await _storage.containsKey(key: "searchText")) {
      String? filteredSearchString = await _storage.read(key: "searchText");
      if (filteredSearchString is String) {
        filterList.searchText = filteredSearchString;
      }
    }

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
      filteredList = result
          .where((intervention) =>
              intervention.assignee_user_id == filterList.user_coordinator.id)
          .toList();
      result = filteredList;
    }

    if (filterList.status != null) {
      if (filterList.status != "") {
        if (filterList.status != "-") {
          List<Intervention> filteredList = [];
          filteredList = result
              .where((intervention) => intervention.status == filterList.status)
              .toList();
          result = filteredList;
        }
      }
    }

    if (filterList.searchText != "") {
      List<Intervention> filteredList = [];
      filteredList = result
          .where((intervention) => intervention.intervention_name
              .toLowerCase()
              .contains(filterList.searchText.toLowerCase()))
          .toList();
      result = filteredList;
    }

    result.sort((i, j) {
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

    list = result;
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

                tc.sendCustomEvent(
                    key: "view_ui", value: "site : ${widget.site.name}");

                return Column(children: <Widget>[
                  widgetFilterList(filterList,
                      user: widget.user, site: widget.site,
                      onChangedFilterList: (FilterList value) async {
                    await _storage.write(
                        key: "lastStatus", value: value.status);
                    await _storage.write(
                        key: "lastCoordinatorUserId",
                        value: value.user_coordinator.id);
                    await _storage.write(
                        key: "searchText", value: value.searchText);

                    filterList = value;
                    refreshUI();
                    return "";
                  }),
                  Expanded(
                      child:
                          widgetListInterventions(listInterventions, context)),
                  const SizedBox(height: 100)
                ]);
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
}
