// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

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

  @override
  void initState() {
    super.initState();
    _title = "${widget.site!.name} : lists";
  }

  late List<String> listOfLists = [];

  Future<List<String>> getMyInformations() async {
    return ["A", "B", "C"];
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
                })));
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
}
