// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

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
            return widgetBody(user: widget.user, dict_of_lists: dictOfLists);
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
      {required User user, required Map<String, List<String>> dict_of_lists}) {
    return Scaffold(
      appBar: widgetAppBar(user),
      body: widgetListOfListContent(
        user: user,
        dict_of_lists: dict_of_lists,
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
      floatingActionButton: fabNewList(context: context, callback: CB),
    );
  }

  void CB(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${message}")),
    );
    setState(() {});
  }

  FloatingActionButton fabNewList(
      {required BuildContext context, required callback}) {
    return FloatingActionButton(
      // onPressed: {},
      onPressed: () async {
        //  _showDialog(callback);
        _showDialog(callback: callback, site: widget.site);
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
      required Map<String, List<String>> dict_of_lists}) {
    List<String> list = [];
    dict_of_lists.forEach((key, value) {
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
              List<String>? values = dict_of_lists[list[index]];

              int max = 5;
              if (max > values!.length) {
                max = values.length;
              }

              List<String> subvalues = values.sublist(0, max);

              return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text('${list[index]}'),
                    subtitle: Text(
                        "${subvalues.join(", ")} ... (${values.length} items) "),
                  ));
            }));
  }

  void _showDialog({
    required void Function(String message) callback,
    required Site? site,
  }) {
    late TextEditingController controllerListName = TextEditingController();
    late TextEditingController controllerValues = TextEditingController();
    List<String> listValues = ["val1", "val2"];
    controllerValues.text = listValues.join("\n");

    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
            builder: (_, constrains) => AlertDialog(
                  title: Text(I18N("nouvelle liste").toTitleCase()),
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
                            fillColor: Color(0xFFF2F2F2),
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
                      child: Text(I18N("annuler").toTitleCase()),
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
                        Navigator.pop(context);
                        dictOfLists[controllerListName.text] =
                            controllerValues.text.split("\n");
                        callback(controllerListName.text);
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
