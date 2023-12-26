import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.interventionAPI = InterventionApi(organization: widget.organization);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.organization.name.toUpperCase()),
        ),
        body: FutureBuilder(
            future: getInterventions(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Intervention> list = snapshot.data;
                if (list.length > 0) {
                  return getInterventionsWidget(
                      context: context, interventions: list);
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
          onPressed: () {
            if (kDebugMode) {
              // ignore: avoid_print
              print("onPressed");
            }
          },
          child: Icon(Icons.add),
        ));
  }

  Future<List<Intervention>> getInterventions() async {
    print(widget.organization.id);

    List<Intervention> list = await interventionAPI.getList();

    return list;
  }

  /* 
  */
}

Widget getInterventionsWidgetOld(
    {required BuildContext context,
    required List<Intervention> interventions}) {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Go back 1!'),
    ),
  );
}

Widget getInterventionsWidget(
    {required BuildContext context,
    required List<Intervention> interventions}) {
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
                            builder: (context) => OrganizationPage(
                                organization: Organization(
                                    id: interventions[index].id,
                                    name: interventions[index].name))));
                  },
                  icon: const Icon(Icons.add_box)),
            ],
          ),
        ),
      ),
    ),
  );
}
