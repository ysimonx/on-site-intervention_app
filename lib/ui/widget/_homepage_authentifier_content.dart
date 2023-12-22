import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_user.dart';
import 'organizations.dart';

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
      body: getOrganizationsWidget(
          context: context, organizations: widget.user.organizations),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
