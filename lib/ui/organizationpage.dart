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
  InterventionApi interventionAPI = InterventionApi();

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
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go back!'),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Future<List<Intervention>> getInterventions() async {
    print(widget.organization.id);

    List<Intervention> list =
        await interventionAPI.getList(organization: widget.organization);

    return list;
  }

  /* 
  */
}
