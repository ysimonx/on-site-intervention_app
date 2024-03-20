// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_tenant.dart';
import '../models/model_user.dart';
import 'widget/app_bar.dart';

class FormulairePage extends StatefulWidget {
  final Site site;
  final User user;
  final String type_intervention;
  const FormulairePage(
      {super.key,
      required this.site,
      required this.user,
      required this.type_intervention});

  @override
  State<StatefulWidget> createState() {
    return FormulairePageState();
  }
}

// Create a corresponding State class.
class FormulairePageState extends State<FormulairePage> {
  late String _title;
  late Map<String, dynamic> mapTypesIntervention;
  late Map<String, Formulaire> mapFormulaires;
  @override
  void initState() {
    super.initState();
    _title = "formulaires ${widget.type_intervention}";
    mapTypesIntervention = widget.user.myconfig.config_types_intervention;
    mapFormulaires = ConvertJsonToMapFormulaires(
        mapTypesIntervention[widget.type_intervention]["forms"]);
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
                itemCount: mapFormulaires.length,
                itemBuilder: (BuildContext context, int index) {
                  String x = mapFormulaires.keys.elementAt(index);
                  Formulaire? f = mapFormulaires[x];

                  return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.list),
                        // ignore: unnecessary_string_interpolations
                        title: Text(f!.form_name),
                        //subtitle:
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                /* Map<String, Formulaire> mapFormulaires =
                                    ConvertJsonToMapFormulaires(
                                        mapTypesIntervention[type_intervention]
                                            ["forms"]);
                                print(mapFormulaires.toString());
                                */
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
