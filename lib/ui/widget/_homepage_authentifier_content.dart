import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import 'sites.dart';

class HomepageAuthentifiedContent extends StatefulWidget {
  final Function(int) onRefresh;

  const HomepageAuthentifiedContent(
      {super.key, required this.user, required this.onRefresh});

  final User user;

  @override
  State<HomepageAuthentifiedContent> createState() =>
      _HomepageAuthentifiedContentState();
}

class _HomepageAuthentifiedContentState
    extends State<HomepageAuthentifiedContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getSitesWidget(
          context: context,
          sites: widget.user.sites,
          onRefresh: (value) {
            widget.onRefresh(1);
          }),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
