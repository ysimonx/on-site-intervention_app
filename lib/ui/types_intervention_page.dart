// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';

import '../models/model_site.dart';
import '../models/model_tenant.dart';
import '../models/model_user.dart';
import 'widget/app_bar.dart';

class TypesInterventionPage extends StatefulWidget {
  final List<Tenant> tenants;
  final Site site;
  final User user;
  const TypesInterventionPage(
      {super.key,
      required this.tenants,
      required this.site,
      required this.user});

  @override
  State<StatefulWidget> createState() {
    return TypesInterventionPageState();
  }
}

// Create a corresponding State class.
class TypesInterventionPageState extends State<TypesInterventionPage> {
  Map<String, User> dictUser = {};
  Map<String, List<String>> dictRolesUsers = {};
  late Site s;

  late String _title = "types d'intervention";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widgetAppBar(widget.user),
        body: const Center(
            child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        )));
  }

  PreferredSize widgetAppBar(User? me) {
    return PreferredSize(
        preferredSize: Size.fromHeight(100), child: BaseAppBar(title: _title));
  }
}
