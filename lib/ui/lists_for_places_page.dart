// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'widget/app_bar.dart';

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
  late Map<String, dynamic> dictOfListsForPlaces = {};

  @override
  void initState() {
    super.initState();
    _title = "${widget.site!.name} : lists for places";
    dictOfListsForPlaces = widget.site!.dictOfListsForPlaces;
  }

  Future<Map<String, dynamic>> getMyInformations() async {
    return widget.site!.dictOfListsForPlaces;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dictOfListsForPlaces = snapshot.data;
            return widgetBody(
                user: widget.user, dictOfListsForPlaces: dictOfListsForPlaces);
          } else if (snapshot.hasError) {
            return widgetError(widget.user);
          } else {
            return widgetWaiting(widget.user);
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
      {required User user,
      required Map<String, dynamic> dictOfListsForPlaces}) {
    return Scaffold(
      appBar: widgetAppBar(user),
      body: widgetListOfListContent(
        user: user,
        dictOfListsForPlaces: dictOfListsForPlaces,
        onRefresh: (valueint, valueString) => setState(() {
          if (valueString != "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  duration: const Duration(milliseconds: 100),
                  content: Text(valueString)),
            );
          }
        }),
      ),
      floatingActionButton: fabNewList(context: context, callback: callBack),
    );
  }

  void callBack(
      {required String message,
      required Map<String, dynamic> dictOfListsForPlaces}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    widget.site!.dictOfListsForPlaces = dictOfListsForPlaces;
    setState(() {});
  }

  FloatingActionButton fabNewList(
      {required BuildContext context, required callback}) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        //  _showDialog(callback);
        _showDialog(callback: callback, site: widget.site, listname: null);
      },
      child: const Icon(Icons.add),
    );
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

  Widget widgetListOfListContent(
      {required User user,
      required void Function(dynamic valueint, dynamic valueString) onRefresh,
      required Map<String, dynamic> dictOfListsForPlaces}) {
    List<String> list = [];
    dictOfListsForPlaces.forEach((key, value) {
      list.add(key);
    });
    list.sort();

    return ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        style: ListTileStyle.list,
        dense: true,
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              var x = dictOfListsForPlaces[list[index]];

              int max = 5;
              if (max > x.length) {
                max = x.length;
              }

              var subvalues = x.sublist(0, max);
              subvalues.sort();

              return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(list[index]),
                    subtitle: Text(
                        "${subvalues.join(", ")} ... (${x.length} items) "),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.manage_search),
                          onPressed: () {
                            _showDialog(
                                callback: callBack,
                                site: widget.site,
                                listname: list[index]);
                          },
                        ),
                      ],
                    ),
                  ));
            }));
  }

  void _showDialog({
    required void Function(
            {required String message,
            required Map<String, dynamic> dictOfListsForPlaces})
        callback,
    required Site? site,
    required String? listname,
  }) {
    late TextEditingController controllerListName = TextEditingController();
    late TextEditingController controllerValues = TextEditingController();

    List<dynamic> listValues = [];

    if (listname != null) {
      controllerListName.text = listname;

      if (site!.dictOfListsForPlaces.keys.contains(listname)) {
        listValues = site.dictOfListsForPlaces[listname];
      }

      listValues.sort();
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
                        dictOfListsForPlaces.remove(listname);
                        dictOfListsForPlaces[controllerListName.text] =
                            controllerValues.text.split("\n");

                        SiteApi siteApi = SiteApi();

                        try {
                          Response response =
                              await siteApi.updateSiteListsForPlaces(
                                  idSite: widget.site!.id,
                                  dictOfListsForPlaces: dictOfListsForPlaces);

                          if (response.statusCode == 200) {
                            Navigator.pop(context);

                            callback(
                                message: "Processing Data",
                                dictOfListsForPlaces: dictOfListsForPlaces);
                            return;
                          }
                          if (response.statusCode == 400) {
                            callback(
                                message:
                                    "Processing Data Error ${response.data["error"]}",
                                dictOfListsForPlaces: dictOfListsForPlaces);
                            return;
                          }
                        } catch (e) {
                          callback(
                              message: e.toString(),
                              dictOfListsForPlaces: dictOfListsForPlaces);
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
