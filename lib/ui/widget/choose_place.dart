import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';

import '../../models/model_lists_for_places.dart';

class ChoosePlaceWidget extends StatefulWidget {
  final Site? site;
  final void Function(dynamic value) onChanged;
  const ChoosePlaceWidget({
    super.key,
    required this.site,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return ChoosePlaceWidgetState();
  }
}

// Create a corresponding State class.
class ChoosePlaceWidgetState extends State<ChoosePlaceWidget> {
  Map<String, String> dataForPlaces = {};
  late ListsForPlaces listsForPlaces;

  @override
  void initState() {
    super.initState();

    // initiation des valeurs des listes
    listsForPlaces = widget.site!.listsForPlaces;
    listsForPlaces.mapLists.forEach((key, listForPlaces) {
      listForPlaces.values.forEach((element) {
        dataForPlaces[listForPlaces.list_name] = "-";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrenW = [];

    listsForPlaces.mapLists.forEach((key, listForPlaces) {
      // valeur "nc" de chaque liste
      List<DropdownMenuItem> dropdownItems = [
        const DropdownMenuItem(value: "-", child: Text("-"))
      ];

      // remplit chaque liste avec les valeurs possibles
      listForPlaces.values.forEach((element) {
        dropdownItems
            .add(DropdownMenuItem(value: element, child: Text(element)));
      });

      childrenW.add(Wrap(
          direction: Axis.vertical,
          spacing: 1.0,
          runSpacing: 1.0,
          children: [
            SizedBox(width: 100, child: Text(listForPlaces.list_name)),
            DropdownButton(
                items: dropdownItems,

                // ici : spécifie la valeur actuelle
                value: dataForPlaces[listForPlaces.list_name],
                onChanged: (cvalue) {
                  setState(() {
                    if (cvalue is String) {
                      dataForPlaces[listForPlaces.list_name] = cvalue;
                      widget.onChanged(dataForPlaces);
                    }
                  });
                })
          ]));
    });

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Card(
          elevation: 10,
          child: ListTile(
              leading: const Icon(Icons.room),
              //subtitle:
              title: Wrap(
                runSpacing: 1.0,
                spacing: 30.0,
                children: childrenW,
              ),
              trailing: const Icon(Icons.travel_explore)),
        ));
  }
}
