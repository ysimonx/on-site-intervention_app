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
  late List<String> listOfLists = [];

  @override
  void initState() {
    super.initState();
    _title = "${widget.site!.name} : lists";
    listOfLists = ["A"];
  }

  Future<List<String>> getMyInformations() async {
    return listOfLists;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            listOfLists = snapshot.data;
            return widgetBody(user: widget.user, list: listOfLists);
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

  Widget widgetBody({required User user, required List<String> list}) {
    return Scaffold(
      appBar: widgetAppBar(user),
      body: widgetListOfListContent(
          user: user,
          list: list,
          onRefresh: (valueint, valueString) => setState(() {
                if (valueString != "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        duration: const Duration(milliseconds: 100),
                        content: Text(valueString)),
                  );
                }
              })),
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
        CB("coucou");
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
      required List<String> list,
      required void Function(dynamic valueint, dynamic valueString)
          onRefresh}) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: listOfLists.length,
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 50,
            child: Center(child: Text('Entry ${listOfLists[index]}')),
          );
        });
  }

  void _showDialog({
    required void Function(String message) callback,
    required Site? site,
  }) {
    late TextEditingController textListController = TextEditingController();
    List<String> listValues = ["val1", "val2"];

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
                        controller: textListController,
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: "Enter the name of this new list"
                                .toCapitalized()),
                      ),
                      SizedBox(
                          width: constrains.maxWidth * .8,
                          height: constrains.maxHeight * .3, //
                          child: ListView.builder(
                              itemCount: listValues.length,
                              itemBuilder: (_, index) {
                                String value = listValues[index];
                                return Text(value);
                              }))
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
                        /*
                        
                        String email = textListController.text;
                        List<String> roles_id = [];

                        dictSiteRoles.forEach((key, value) {
                          if (value) {
                            roles_id.add(key);
                          }
                        });
                        Response response = await siteApi.AddUserRoles(
                            site_id: s.id, email: email, roles_id: roles_id);

                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          callback("Processing Data");
                          return;
                        }
                        if (response.statusCode == 400) {
                          Navigator.pop(context);
                          callback(
                              "Processing Data Error ${response.data["error"]}");
                          return;
                        }*/
                      },
                    ),
                  ],
                ));
      },
    );
  }
}
