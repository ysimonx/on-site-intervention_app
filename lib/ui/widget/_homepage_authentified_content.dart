import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_user.dart';
import 'package:on_site_intervention_app/ui/utils/i18n.dart';

import '../../network/api/site_api.dart';
import 'sites.dart';

class HomepageAuthentifiedContent extends StatefulWidget {
  final Function(int) onRefresh;
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
        body: getSitesWidget(
            context: context,
            user: widget.user,
            sites: widget.user.sites,
            onRefresh: (value) {
              widget.onRefresh(1);
            }),
        floatingActionButton: (widget.user.tenants_administrator_of.length == 1)
            ? FloatingActionButton.extended(
                tooltip: 'Nouveau site',
                label: Text("SITE"),
                onPressed: _showDialog,
                icon: const Icon(Icons.add))
            : Container());
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _showDialog() {
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
                print(widget.user.tenants_administrator_of.length);
                String site_name = _textController.text;
                print(site_name);
                Response response = await siteApi.AddNewSite(
                    site_name: site_name,
                    tenant_id: widget.user.tenants_administrator_of[0].id);
                print(response.data);
                print(response.statusCode);
                if (response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data Error')),
                  );
                }
                widget.onRefresh(1);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
