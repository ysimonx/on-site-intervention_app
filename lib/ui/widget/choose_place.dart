// ignore_for_file: non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_site.dart';

import '../../models/model_lists_for_places.dart';
import '../../models/model_place.dart';

class ChoosePlaceWidget extends StatefulWidget {
  final Site? site;
  final void Function(dynamic value) onChanged;
  final Place? place;
  const ChoosePlaceWidget({
    super.key,
    required this.site,
    required this.onChanged,
    required this.place,
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
      dataForPlaces[listForPlaces.list_name] = "-"; // valeur par defaut

      if (widget.place!.place_json.containsKey(listForPlaces.list_name)) {
        // si les données en entrée contiennent bien une valeur pour la liste
        String initial_value =
            widget.place!.place_json[listForPlaces.list_name]; //  b1, l1, r1
        if (listForPlaces.values.contains(initial_value)) {
          // si la valeur fait bien partie des valeurs possibles
          dataForPlaces[listForPlaces.list_name] = initial_value;
        }
      }
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

      childrenW.add(Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
          ),
          child: Wrap(
              direction: Axis.vertical,
              spacing: 0.0,
              runSpacing: 10.0,
              children: [
                Text(listForPlaces.list_name),
                DropdownButton(
                    items: dropdownItems,

                    // ici : spécifie la valeur actuelle
                    value: dataForPlaces[listForPlaces.list_name],
                    onChanged: (cvalue) {
                      setState(() {
                        if (cvalue is String) {
                          dataForPlaces[listForPlaces.list_name] = cvalue;

                          List<String> names = [];
                          listsForPlaces.mapLists.forEach((key, listForPlaces) {
                            if (dataForPlaces[listForPlaces.list_name]! ==
                                "-") {
                              names.add("[${listForPlaces.list_name}]");
                            } else {
                              names
                                  .add(dataForPlaces[listForPlaces.list_name]!);
                            }
                          });

                          Place p = Place.newPlace(
                              place_json: dataForPlaces,
                              site_id: widget.site!.id,
                              place_name: names.join("-"));

                          widget.onChanged(p);
                        }
                      });
                    })
              ])));
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
