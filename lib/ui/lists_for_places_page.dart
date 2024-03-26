// ignore_for_file: unused_import, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import '../models/model_lists_for_places.dart';
import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'widget/app_bar.dart';
import 'widget/common_widgets.dart';

class ListsForPlacesPage extends StatefulWidget {
  final Site? site;
  final User user;
  const ListsForPlacesPage({super.key, required this.site, required this.user});

  @override
  State<StatefulWidget> createState() {
    return ListsForPlacesPageState();
  }
}

// Create a corresponding State class.
class ListsForPlacesPageState extends State<ListsForPlacesPage> {
  late String _title = 'lists';
  late ListsForPlaces lists_for_places;

  @override
  void initState() {
    super.initState();
    _title = "${widget.site!.name} : lists for places";
    lists_for_places = widget.site!.listsForPlaces;
  }

  Future<ListsForPlaces> getMyInformations() async {
    return lists_for_places;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return widgetBody(
                user: widget.user, lists_for_places: lists_for_places);
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

  Widget widgetBody(
      {required User user, required ListsForPlaces lists_for_places}) {
    return Scaffold(
      appBar: widgetAppBar(user),
      body: widgetListOfListContent(
        user: user,
        lists_for_places: lists_for_places,
        onRefresh: (valueint, valueString) => setState(() {
          if (valueString != "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  duration: const Duration(milliseconds: 500),
                  content: Text(valueString)),
            );
          }
        }),
      ),
      floatingActionButton: fabNewList(context: context, callback: callBack),
    );
  }

  void callBack({
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {});
  }

  FloatingActionButton fabNewList(
      {required BuildContext context, required callback}) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        //  _showDialog(callback);
        _showDialog(
            callback: callback,
            listname: null,
            order: lists_for_places.mapLists.length); // ajoute à la fin
      },
      child: const Icon(Icons.add),
    );
  }

  Widget widgetListOfListContent(
      {required User user,
      required void Function(dynamic valueint, dynamic valueString) onRefresh,
      required ListsForPlaces lists_for_places}) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        style: ListTileStyle.list,
        dense: true,
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: lists_for_places.mapLists.length,
            itemBuilder: (BuildContext context, int index) {
              ListForPlaces lfp = lists_for_places.mapLists[index]!;

              int max = 5;
              if (max > lfp.values.length) {
                max = lfp.values.length;
              }

              var subvalues = lfp.values.sublist(0, max);
              subvalues.sort();

              return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(lfp.list_name),
                    subtitle: Text(
                        "${subvalues.join(", ")} ... (${lfp.values.length} items) "),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDialogDelete(
                                callback: callBack,
                                listname: lfp.list_name,
                                order: index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.manage_search),
                          onPressed: () {
                            _showDialog(
                                callback: callBack,
                                listname: lfp.list_name,
                                order: index);
                          },
                        ),
                      ],
                    ),
                  ));
            }));
  }

  void _showDialogDelete({
    required void Function({
      required String message,
    }) callback,
    // required Site? site,
    required String? listname,
    required int order,
  }) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title:
                Text("Confirmez-vous la suppression de la liste '$listname'"),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(translateI18N("annuler").toTitleCase()),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(translateI18N("supprimer").toTitleCase()),
                onPressed: () async {
                  lists_for_places.removeFromList(index: order);
                  saveListForPlaces(callback: callback);
                },
              ),
            ],
          );
        }).then((exit) {
      if (exit == null) return;

      if (exit) {
        // user pressed Yes button
      } else {
        // user pressed No button
      }
    });
  }

  void _showDialog({
    required void Function({
      required String message,
    }) callback,
    // required Site? site,
    required String? listname,
    required int order,
  }) {
    late TextEditingController controllerListName = TextEditingController();
    late TextEditingController controllerValues = TextEditingController();

    List<dynamic> listValues = [];

    if (lists_for_places.mapLists.containsKey(order)) {
      ListForPlaces lfp = lists_for_places.mapLists[order]!;
      controllerListName.text = lfp.list_name;
      listValues = lfp.values;
      listValues.sort();
    } else {
      controllerListName.text = "";
    }

    controllerValues.text = listValues.join("\n");

    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
            builder: (_, constrains) => AlertDialog(
                  title: Text(translateI18N("nouvelle liste").toTitleCase()),
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(children: [
                      TextField(
                        onChanged: (v) {
                          controllerListName.text =
                              controllerListName.text.toLowerCase();
                        },
                        controller: controllerListName,
                        autofocus: true,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2F2F2),
                            hintText: "Enter the name of this new list"
                                .toCapitalized()),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controllerValues,
                        autofocus: true,
                        autocorrect: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1),
                          ),
                        ),
                      ),
                    ]);
                  }),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text(translateI18N("annuler").toTitleCase()),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Ok'),
                      onPressed: () async {
                        ListForPlaces lfp = ListForPlaces(
                            list_name: controllerListName.text,
                            values: controllerValues.text.split("\n"));

                        lists_for_places.mapLists[order] = lfp;
                        saveListForPlaces(callback: callback);
                      },
                    ),
                  ],
                ));
      },
    );
  }

  void saveListForPlaces(
      {required void Function({required String message}) callback}) async {
    try {
      Response response = await SiteApi.updateSiteListsForPlaces(
          idSite: widget.site!.id, lists_for_places: lists_for_places);

      if (response.statusCode == 200) {
        Navigator.pop(context);

        callback(
          message: "Processing Data",
        );
        return;
      }
      if (response.statusCode == 400) {
        callback(
          message: "Processing Data Error ${response.data["error"]}",
        );
        return;
      }
    } catch (e) {
      callback(
        message: e.toString(),
      );
    }
  }
}
