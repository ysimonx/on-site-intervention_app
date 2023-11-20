// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:app_renovadmin/models/models.dart';
import 'package:app_renovadmin/ui/formulaire.dart';
import 'package:app_renovadmin/files/formulaire_json_file.dart';

import 'package:flutter/material.dart';

class BeneficiaireSearch {
  static Widget getSearchWidget() {
    return TextField(
      // cf https://karthikponnam.medium.com/flutter-search-in-listview-1ffa40956685
      onChanged: (value) {},
      // controller: editingController,
      decoration: const InputDecoration(
          labelText: "Recherche",
          hintText: "Recherche",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)))),
    );
  }
}

class BeneficiaireWidgetBuilderNT {
  Map<String, dynamic> mapBeneficiaire;

  BeneficiaireWidgetBuilderNT(this.mapBeneficiaire);

  Widget buildBeneficiairesListGestes(BuildContext context) {
    return SizedBox(
        height: (mapBeneficiaire["gestes"].length * 200 + 80).toDouble(),
        // child: Card(

        // cf https://api.flutter.dev/flutter/material/Card-class.html
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mapBeneficiaire["name"],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge),
                Text("${mapBeneficiaire["distanceKm"]} km",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge)
              ]),
              const Icon(Icons.more_vert, size: 25)
            ]),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,

              separatorBuilder: (context, index) => const Divider(
                color: Colors.black,
              ),
              // Let the ListView know how many items it needs to build.
              itemCount: mapBeneficiaire["gestes"].length,
              // Provide a builder function. This is where the magic happens.

              itemBuilder: (context, indexGeste) {
                final Map<String, dynamic> geste =
                    mapBeneficiaire["gestes"][indexGeste];
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(geste["geste_name"],
                          style: Theme.of(context).textTheme.bodyMedium),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          // Let the ListView know how many items it needs to build.
                          itemCount: geste["formulaires"].length,
                          // Provide a builder function. This is where the magic happens.

                          itemBuilder: (context, indexFormulaire) {
                            final Map<String, dynamic> mapFormulaire =
                                geste["formulaires"][indexFormulaire];
                            return SizedBox(
                                height: 80,
                                child: Card(
                                    elevation: 8,
                                    shadowColor: Colors.red,
                                    child: ListTile(
                                        /* leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          child: Text((index + 1).toString(),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface)),
                                        ),*/
                                        trailing: IconButton(
                                            iconSize: 50,
                                            color: Colors.blue,
                                            onPressed: () async {
                                              String content =
                                                  await FormulaireJSONFile(
                                                          filename: mapFormulaire[
                                                              "formulaire_filename"])
                                                      .readFile();

                                              Map<String, dynamic> jsonContent =
                                                  jsonDecode(content);
                                              print(jsonContent.toString());

                                              Formulaire formulaire =
                                                  fromJSON(jsonContent);

                                              Beneficiaire beneficiaire = Beneficiaire(
                                                  [],
                                                  beneficiaire_uuid:
                                                      jsonContent[
                                                              "beneficiaire"]
                                                          ["beneficiaire_uuid"],
                                                  beneficiaire_name:
                                                      jsonContent[
                                                              "beneficiaire"][
                                                          "beneficiaire_name"]);
                                              Geste geste = Geste(
                                                  geste_uuid:
                                                      Geste.generateUUID(),
                                                  formulaires: [],
                                                  geste_name:
                                                      jsonContent["geste"]
                                                          ["geste_name"]);

                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FormulairePage(
                                                            title: 'Formulaire',
                                                            beneficiaire:
                                                                beneficiaire,
                                                            formulaire:
                                                                formulaire,
                                                            geste: geste),
                                                  ));
                                            },
                                            icon:
                                                const Icon(Icons.add_a_photo)),
                                        subtitle: Text(
                                            "${mapFormulaire["nbGivenData"]} / ${mapFormulaire["nbRequiredData"]} données"),
                                        title: Text(mapFormulaire[
                                            "formulaire_name"]))));
                          })
                    ]);
              },
            )
          ],
        ));
  }

  //
  Formulaire fromJSON(Map<String, dynamic> jsonContent) {
    List<Field> lf = [];
    for (var i = 0; i < jsonContent["fields"].length; i++) {
      List<Photo> lp = [];
      for (var j = 0; j < jsonContent["fields"][i]["photos"].length; j++) {
        var ip = jsonContent["fields"][i]["photos"][j];

        Photo p = Photo(
            photo_uuid: ip["photo_uuid"],
            path: ip["path"],
            status: ip["status"],
            location: Location(
                longitude: ip["location"]["longitude"],
                latitude: ip["location"]["latitude"]),
            created_date_utc: DateTime.parse(ip["created_date_utc"]));
        lp.add(p);
      }

      Field field = Field(
          field_uuid: jsonContent["fields"][i]["field_uuid"],
          field_name: jsonContent["fields"][i]["field_name"],
          photos: lp,
          commentaire: jsonContent["fields"][i]["commentaire"],
          noPhoto: jsonContent["fields"][i]["noPhoto"]);
      lf.add(field);
    }
    Formulaire formulaire = Formulaire(
        formulaire_uuid: jsonContent["formulaire_uuid"],
        formulaire_name: jsonContent["formulaire_name"],
        nbFilledFields: 0,
        fields: lf);

    return formulaire;
  }
  //
}

class BeneficiaireWidgetBuilder {
  final Beneficiaire beneficiaire;

  BeneficiaireWidgetBuilder(this.beneficiaire);

  Widget buildBeneficiairesListGestes(BuildContext context) {
    return SizedBox(
        height: beneficiaire.gestes.length * 200 + 80,
        // child: Card(

        // cf https://api.flutter.dev/flutter/material/Card-class.html
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(beneficiaire.beneficiaire_name,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge),
                Text("${beneficiaire.distance} km",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge)
              ]),
              const Icon(Icons.more_vert, size: 25)
            ]),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,

              separatorBuilder: (context, index) => const Divider(
                color: Colors.black,
              ),
              // Let the ListView know how many items it needs to build.
              itemCount: beneficiaire.gestes.length,
              // Provide a builder function. This is where the magic happens.

              itemBuilder: (context, index) {
                final geste = beneficiaire.gestes[index];
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(geste.geste_name,
                          style: Theme.of(context).textTheme.bodyMedium),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          // Let the ListView know how many items it needs to build.
                          itemCount: geste.formulaires.length,
                          // Provide a builder function. This is where the magic happens.

                          itemBuilder: (context, index) {
                            final Formulaire formulaire =
                                geste.formulaires[index];
                            return SizedBox(
                                height: 80,
                                child: Card(
                                    elevation: 8,
                                    shadowColor: Colors.red,
                                    child: ListTile(
                                        /* leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          child: Text((index + 1).toString(),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inverseSurface)),
                                        ),*/
                                        trailing: IconButton(
                                            iconSize: 50,
                                            color: Colors.blue,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FormulairePage(
                                                          title: 'Formulaire',
                                                          geste: geste,
                                                          beneficiaire:
                                                              beneficiaire,
                                                          formulaire:
                                                              formulaire,
                                                        )),
                                              );
                                            },
                                            icon:
                                                const Icon(Icons.add_a_photo)),
                                        subtitle: Text(
                                            "${formulaire.nbFilledFields} / ${formulaire.fields.length} données"),
                                        title:
                                            Text(formulaire.formulaire_name))));
                          })
                    ]);
              },
            )
          ],
        ));
  }
}

Future<Beneficiaire> createAlertDialogNewBeneficiaire(
    BuildContext context) async {
  String dropdownValue = 'Pompe à Chaleur Air/Eau';

  Beneficiaire beneficiaireNew = Beneficiaire(
      beneficiaire_uuid: Beneficiaire.generateUUID(),
      /* beneficiaire_name: "Cristiano Ronaldo",*/
      beneficiaire_name: "",
      distance: 0,
      [
        Geste(
            geste_name: "Pompe à Chaleur Air/Eau",
            geste_uuid: Geste.generateUUID(),
            formulaires: [
              Formulaire(
                  formulaire_uuid: Formulaire.generateUUID(),
                  formulaire_name: "Avant dépose",
                  nbFilledFields: 0,
                  fields: []),
              Formulaire(
                  formulaire_uuid: Formulaire.generateUUID(),
                  nbFilledFields: 0,
                  formulaire_name: "Installation",
                  fields: [])
            ])
      ]);
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouveau Bénéficiaire"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Nom:"),
              TextFormField(
                /* initialValue: 'Cristiano Ronaldo'.toUpperCase(),*/
                initialValue: '',
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  beneficiaireNew.beneficiaire_name = value.toUpperCase();
                },
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<String>(
                  value: dropdownValue,
                  isExpanded: true,
                  items: <String>[
                    'Pompe à Chaleur Air/Eau',
                    'Chaudière biomasse'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? selectedvalue) {
                    setState(() {
                      if (selectedvalue != null) {
                        dropdownValue = selectedvalue;
                      }
                    });
                  },
                );
              }),
            ],
          ),
          actions: <Widget>[
            MaterialButton(
                elevation: 5.0,
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(beneficiaireNew);
                })
          ],
        );
      });
}
