// ignore_for_file: empty_statements, unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:on_site_intervention_app/ui/interventionpage.dart';

import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_place.dart';
import '../models/model_user.dart';
import '../network/api/intervention_api.dart';
import '../network/api/login_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'utils/uuid.dart';

class SitePage extends StatefulWidget {
  const SitePage({super.key, required this.site});

  final Site site;

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  late UserApi userAPI;
  late InterventionApi interventionAPI;

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
    userAPI = UserApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.site.name.toUpperCase()),
        ),
        body: FutureBuilder(
            future: getInterventions(site: widget.site),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Intervention> listInterventions = snapshot.data;
                if (listInterventions.isNotEmpty) {
                  return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: ListTileTheme(
                        contentPadding: const EdgeInsets.all(15),
                        iconColor: Colors.green,
                        textColor: Colors.black54,
                        tileColor: Colors.yellow[10],
                        style: ListTileStyle.list,
                        dense: true,
                        child: ListView.builder(
                          itemCount: listInterventions.length,
                          itemBuilder: (_, index) => Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(listInterventions[index]
                                  .intervention_name
                                  .toUpperCase()),
                              subtitle: Text(listInterventions[index]
                                  .type_intervention_name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /* IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete)),*/
                                  IconButton(
                                      onPressed: () async {
                                        Intervention i =
                                            listInterventions[index];

                                        UserApi userAPI = UserApi();

                                        /* Map<String, Formulaire> initializedForms =
                                        await userAPI
                                            .getInterventionInitializedFormsFromTemplate(
                                                site:
                                                    widget.site.name,
                                                type_intervention:
                                                    i.type_intervention_name);
                                    */

                                        /* Place nowhere = Place.nowhere(
                                        site_id:
                                            widget.site.id);
                                    */
                                        /* i.forms = initializedForms; */

                                        if (!context.mounted) {
                                          return;
                                        }
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return InterventionPage(
                                              intervention: i,
                                              site: widget.site);
                                        })).then((value) => setState(() {}));
                                      },
                                      icon: const Icon(Icons.navigate_next)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
                } else {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Empty List, go back'),
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }),
        floatingActionButton: FloatingActionButton(
          // onPressed: {},
          tooltip: 'Increment',
          onPressed: () async {
            if (kDebugMode) {
              // ignore: avoid_print
              logger.d("onPressed");
            }

            String typeInterventionName = "scaffolding request";
            String typeInterventionId = "aec24222-6893-4f46-b1e0-1439b0a9a165";

            UserApi userAPI = UserApi();

            Map<String, Formulaire> initializedForms =
                await userAPI.getInterventionFormsFromTemplate(
                    site_name: widget.site.name,
                    type_intervention_name: typeInterventionName);

            Place nowhere = Place.nowhere(site_id: widget.site.id);

            Intervention newIntervention = Intervention(
              id: "new_${generateUUID()}",
              intervention_name: "nouvelle",
              site_id: widget.site.id,
              intervention_values_on_site_uuid: generateUUID(),
              type_intervention_id: typeInterventionId,
              type_intervention_name: typeInterventionName,
              forms: initializedForms,
              place: nowhere,
            );

            if (!context.mounted) {
              return;
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InterventionPage(
                        intervention: newIntervention,
                        site: widget.site))).then((value) => setState(() {}));
            ;
          },
          child: const Icon(Icons.add),
        ));
  }

  Future<List<Intervention>> getInterventions({required Site site}) async {
    List<Intervention> list = await interventionAPI.getList(site: site);

    return list;
  }

  /* 
  */
}
