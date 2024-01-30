import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import 'sites.dart';

class HomepageAuthentifiedContent extends StatefulWidget {
  const HomepageAuthentifiedContent({super.key, required this.user});

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
      body: getSitesWidget(context: context, sites: widget.user.sites),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
