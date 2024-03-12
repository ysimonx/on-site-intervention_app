import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/model_intervention.dart';
import '../../models/model_place.dart';
import '../../models/model_site.dart';
import '../../network/api/intervention_api.dart';
import '../utils/logger.dart';

class widgetListInterventionSamePlace extends StatefulWidget {
  final Site site;
  final Place place;
  final void Function(
      {required Intervention intervention,
      required String next_indice}) onChanged;
  const widgetListInterventionSamePlace({
    super.key,
    required this.site,
    required this.place,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return widgetListInterventionSamePlaceState();
  }
}

// Create a corresponding State class.
class widgetListInterventionSamePlaceState
    extends State<widgetListInterventionSamePlace> {
  late InterventionApi interventionAPI;
  Map<String, String> MaxIndices = {};
  List<Intervention> filteredListIntervention = [];
  late Future<String> myFuture;

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getWriterName() {
    return Future.delayed(
        const Duration(seconds: 2), () => xgetListInterventions());
  }

  Future<String> xgetListInterventions() async {
    logger.d("ta da getListInterventions debut");

    List<Intervention> list = await interventionAPI.getListInterventions(
        site: widget.site, realtime: false, place: widget.place);

    for (var i = 0; i < list.length; i++) {
      Intervention intervention = list[i];
      if (intervention.num_chrono != null) {
        filteredListIntervention.add(intervention);
        if (MaxIndices.containsKey(intervention.num_chrono)) {
          if (intervention.indice!
                  .compareTo(MaxIndices[intervention.num_chrono]!) >
              0) {
            MaxIndices[intervention.num_chrono!] = intervention.indice!;
          }
        } else {
          MaxIndices[intervention.num_chrono!] = intervention.indice!;
        }
      }
    }
    print(MaxIndices.toString());
    return "full";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWriterName(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            if (filteredListIntervention.isNotEmpty) {
              List<DropdownMenuItem<Intervention>>
                  listDropdownMenuItemsInterventions = [];
              if (listDropdownMenuItemsInterventions.isEmpty) {
                // return Text("");
              }
              for (var i = 0; i < filteredListIntervention.length; i++) {
                Intervention intervention = filteredListIntervention[i];

                listDropdownMenuItemsInterventions.add(DropdownMenuItem(
                    value: intervention,
                    child: Row(
                      children: [
                        Text(intervention.intervention_name),
                        Text(" - (${intervention.status})"),
                      ],
                    )));
              }
              return Column(children: [
                Text('reprendre un chrono existant'),
                DropdownButton<Intervention>(
                    items: listDropdownMenuItemsInterventions,
                    onChanged: (Intervention? intervention) {
                      if (intervention is Intervention) {
                        String? maxIndice = MaxIndices[intervention.num_chrono];

                        int value = maxIndice!.codeUnitAt(0);
                        String char = String.fromCharCode(value + 1);
                        widget.onChanged(
                            intervention: intervention, next_indice: char);
                      }
                    })
              ]);
            }
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else {
            children = const <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text('recherche de numero chrono.'),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            ];
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );

          /*
          if (filteredListIntervention.isNotEmpty) {
            // return Text('yo ${filteredListIntervention.length}');
            // List<Intervention> filteredListIntervention = snapshot.data;
            List<DropdownMenuItem<Intervention>>
                listDropdownMenuItemsInterventions = [];
            if (listDropdownMenuItemsInterventions.isEmpty) {
              return Text("");
            }
            for (var i = 0; i < filteredListIntervention.length; i++) {
              Intervention intervention = filteredListIntervention[i];

              listDropdownMenuItemsInterventions.add(DropdownMenuItem(
                  value: intervention,
                  child: Row(
                    children: [
                      Text(intervention.intervention_name),
                      Text(" - (${intervention.status})"),
                    ],
                  )));
            }
            return Column(children: [
              Text('reprendre un chrono existant'),
              DropdownButton<Intervention>(
                  items: listDropdownMenuItemsInterventions,
                  onChanged: (Intervention? intervention) {
                    if (intervention is Intervention) {
                      String? maxIndice = MaxIndices[intervention.num_chrono];

                      int value = maxIndice!.codeUnitAt(0);
                      String char = String.fromCharCode(value + 1);
                      widget.onChanged(
                          intervention: intervention, next_indice: char);
                    }
                  })
            ]);
          }
          return (Text("en attente"));
          */
        });

    // TODO: implement build
  }
}
