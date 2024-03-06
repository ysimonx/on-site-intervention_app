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
  late List<Intervention> filteredListIntervention;
  Map<String, String> MaxIndices = {};

  @override
  void initState() {
    super.initState();
    interventionAPI = InterventionApi();
  }

  Future<List<Intervention>> getListInterventions() async {
    logger.d("ta da getListInterventions debut");
    List<Intervention> list = await interventionAPI.getListInterventions(
        site: widget.site, realtime: false, place: widget.place);
    filteredListIntervention = [];
    print(list.length);

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
    return filteredListIntervention;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getListInterventions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // return Text('yo ${filteredListIntervention.length}');
            List<DropdownMenuItem<Intervention>>
                listDropdownMenuItemsInterventions = [];
            for (var i = 0; i < filteredListIntervention.length; i++) {
              Intervention intervention = filteredListIntervention[i];

              listDropdownMenuItemsInterventions.add(DropdownMenuItem(
                  value: intervention,
                  child: Text(intervention.intervention_name)));
            }
            return DropdownButton<Intervention>(
                items: listDropdownMenuItemsInterventions,
                onChanged: (Intervention? intervention) {
                  if (intervention is Intervention) {
                    String? maxIndice = MaxIndices[intervention.num_chrono];

                    int value = maxIndice!.codeUnitAt(0);
                    String char = String.fromCharCode(value + 1);
                    widget.onChanged(
                        intervention: intervention, next_indice: char);
                  }
                });
          }
          return (Text("en attente"));
        });

    // TODO: implement build
  }
}
