import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_user.dart';
import 'package:on_site_intervention_app/ui/utils/i18n.dart';

import '../../network/api/site_api.dart';
import '_sites_page.dart';

class HomepageAuthentifiedContent extends StatefulWidget {
  final Function(int, String) onRefresh;
  final User user;

  const HomepageAuthentifiedContent(
      {super.key, required this.user, required this.onRefresh});

  @override
  State<HomepageAuthentifiedContent> createState() =>
      _HomepageAuthentifiedContentState();
}

class _HomepageAuthentifiedContentState
    extends State<HomepageAuthentifiedContent> {
  late TextEditingController _textController;

  SiteApi siteApi = SiteApi();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: getSitesWidget(
                context: context,
                user: widget.user,
                sites: widget.user.sites,
                onRefresh: (value) {
                  widget.onRefresh(1, "refreshing list");
                })),
        floatingActionButton: FloatingActionButton.extended(
            tooltip: 'Nouveau site',
            label: Text("SITE"),
            onPressed: (widget.user.tenants_administrator_of.length == 1)
                ? _showDialogOk
                : _showDialogNok,
            icon: const Icon(Icons.add)));
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  Future<void> _pullRefresh() async {
    widget.onRefresh(1, "refreshing list");
  }

  void _showDialogOk() {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('nouveau site'.toCapitalized()),
          content: Column(children: [
            Text(
              "En tant qu'administrateur de '${widget.user.tenants_administrator_of[0].name.toUpperCase()}', vous pouvez administrer la liste des sites et leurs comptes utilisateurs",
            ),
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: "Enter the name of the new site.".toCapitalized()),
            ),
          ]),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () async {
                String site_name = _textController.text;
                Response response = await siteApi.AddNewSite(
                    site_name: site_name,
                    tenant_id: widget.user.tenants_administrator_of[0].id);
                String snack_message = "";
                if (response.statusCode == 201) {
                  snack_message = 'Processing Data';
                } else {
                  snack_message =
                      'Processing Data Error ${response.statusCode.toString()}';
                }
                widget.onRefresh(1, snack_message);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogNok() {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Veuillez contacter FIDWORK'.toCapitalized()),
          content: const Column(children: [
            Text(
              "Vous n'avez pas encore souscrit une licence FIDWORK, veuillez nous contacter sur contact@fidwork.fr",
            ),
          ]),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
