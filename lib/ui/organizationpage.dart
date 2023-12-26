import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/ui/interventionpage.dart';

import '../models/model_intervention.dart';
import '../models/model_organization.dart';
import '../network/api/intervention_api.dart';
import '../network/api/login_api.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key, required this.organization});

  final Organization organization;

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  LoginApi loginApi = LoginApi();
  late InterventionApi interventionAPI;

  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.interventionAPI = InterventionApi();
  }

  void refreshList() {
    _counter = _counter + 1;
    setState() {
      _counter = _counter + 1;
    }

    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.organization.name.toUpperCase()),
        ),
        body: FutureBuilder(
            future: getInterventions(
                organization: widget.organization, toto: _counter),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Intervention> list = snapshot.data;
                if (list.length > 0) {
                  return ListTileTheme(
                    contentPadding: const EdgeInsets.all(15),
                    iconColor: Colors.green,
                    textColor: Colors.black54,
                    tileColor: Colors.yellow[10],
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) => Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(list[index].name.toUpperCase()),
                          subtitle: Text('subtitle'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InterventionPage(
                                                        intervention:
                                                            list[index])))
                                        .then((value) => setState(() {}));
                                    ;
                                  },
                                  icon: const Icon(Icons.add_box)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Empty List, go back, ${_counter}'),
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
          onPressed: () {
            if (kDebugMode) {
              // ignore: avoid_print
              print("onPressed");
            }
          },
          child: Icon(Icons.add),
        ));
  }

  Future<List<Intervention>> getInterventions(
      {required Organization organization, required int toto}) async {
    print(widget.organization.id);
    print(toto);

    List<Intervention> list =
        await interventionAPI.getList(organization: organization);

    return list;
  }

  /* 
  */
}

Widget getInterventionsWidget({
  required BuildContext context,
  required List<Intervention> interventions,
  required void Function() callback,
}) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(15),
    iconColor: Colors.green,
    textColor: Colors.black54,
    tileColor: Colors.yellow[10],
    style: ListTileStyle.list,
    dense: true,
    child: ListView.builder(
      itemCount: interventions.length,
      itemBuilder: (_, index) => Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Text(interventions[index].name.toUpperCase()),
          subtitle: Text('subtitle'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InterventionPage(
                                intervention: interventions[index])));
                  },
                  icon: const Icon(Icons.add_box)),
            ],
          ),
        ),
      ),
    ),
  );
}
