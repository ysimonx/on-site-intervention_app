// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_tenant.dart';
import '../models/model_user.dart';
import 'formulaire_page.dart';
import 'widget/app_bar.dart';

class TypesInterventionPage extends StatefulWidget {
  final Site site;
  final User user;
  const TypesInterventionPage(
      {super.key, required this.site, required this.user});

  @override
  State<StatefulWidget> createState() {
    return TypesInterventionPageState();
  }
}

// Create a corresponding State class.
class TypesInterventionPageState extends State<TypesInterventionPage> {
  final String _title = "types d'intervention";
  late Map<String, dynamic> mapTypesIntervention;

  @override
  void initState() {
    super.initState();
    mapTypesIntervention = widget.user.myconfig.config_types_intervention;
    print(mapTypesIntervention.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widgetAppBar(widget.user),
        body: ListTileTheme(
            contentPadding: const EdgeInsets.all(15),
            style: ListTileStyle.list,
            dense: true,
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: mapTypesIntervention.length,
                itemBuilder: (BuildContext context, int index) {
                  String type_intervention =
                      mapTypesIntervention.keys.elementAt(index);

                  return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.list),
                        title: Text("${type_intervention}"),
                        //subtitle:
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return FormulairePage(
                                      site: widget.site,
                                      user: widget.user,
                                      type_intervention: type_intervention);
                                }));
                              },
                            ),
                          ],
                        ),
                      ));
                })));
  }

  PreferredSize widgetAppBar(User? me) {
    return PreferredSize(
        preferredSize: Size.fromHeight(100), child: BaseAppBar(title: _title));
  }
}
