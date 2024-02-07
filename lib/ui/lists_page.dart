// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import '../network/api/site_api.dart';
import 'utils/i18n.dart';
import 'widget/app_bar.dart';

class ListsPage extends StatefulWidget {
  final Site? site;
  final User user;
  const ListsPage({super.key, required this.site, required this.user});

  @override
  State<StatefulWidget> createState() {
    return ListsPageState();
  }
}

// Create a corresponding State class.
class ListsPageState extends State<ListsPage> {
  late String _title = 'lists';
  late Map<String, List<String>> dictOfLists = {};

  @override
  void initState() {
    super.initState();
    _title = "${widget.site!.name} : lists";
    dictOfLists = {
      "batiments": ["R1", "R2"]
    };
  }

  Future<Map<String, List<String>>> getMyInformations() async {
    return dictOfLists;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dictOfLists = snapshot.data;
            return widgetBody(user: widget.user, dictOfLists: dictOfLists);
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
      {required User user, required Map<String, List<String>> dictOfLists}) {
    return Scaffold(
      appBar: widgetAppBar(user),
      body: widgetListOfListContent(
        user: user,
        dictOfLists: dictOfLists,
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
      required Map<String, List<String>> dictOfLists}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    widget.site!.dictOfLists = dictOfLists;
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
      required Map<String, List<String>> dictOfLists}) {
    List<String> list = [];
    dictOfLists.forEach((key, value) {
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
              List<String>? values = dictOfLists[list[index]];

              int max = 5;
              if (max > values!.length) {
                max = values.length;
              }

              List<String> subvalues = values.sublist(0, max);
              subvalues.sort();

              return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(list[index]),
                    subtitle: Text(
                        "${subvalues.join(", ")} ... (${values.length} items) "),
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
            required Map<String, List<String>> dictOfLists})
        callback,
    required Site? site,
    required String? listname,
  }) {
    late TextEditingController controllerListName = TextEditingController();
    late TextEditingController controllerValues = TextEditingController();
    List<String> listValues = [];
    if (listname != null) {
      controllerListName.text = listname;
      listValues = dictOfLists[listname]!;
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
                        dictOfLists.remove(listname);
                        dictOfLists[controllerListName.text] =
                            controllerValues.text.split("\n");

                        SiteApi siteApi = SiteApi();

                        try {
                          Response response = await siteApi.updateSiteLists(
                              idSite: widget.site!.id,
                              dictOfLists: dictOfLists);

                          if (response.statusCode == 200) {
                            Navigator.pop(context);

                            callback(
                                message: "Processing Data",
                                dictOfLists: dictOfLists);
                            return;
                          }
                          if (response.statusCode == 400) {
                            callback(
                                message:
                                    "Processing Data Error ${response.data["error"]}",
                                dictOfLists: dictOfLists);
                            return;
                          }
                        } catch (e) {
                          print("error");
                          callback(
                              message: e.toString(), dictOfLists: dictOfLists);
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
