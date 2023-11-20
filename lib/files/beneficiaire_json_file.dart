// cette fonction refabrique un fichier JSON par BENEFICIAIRE,
// afin d'avoir un affichage rapide sur l'application de la
// liste des BENEFICIARIES !
// ignore_for_file: depend_on_referenced_packages, avoid_print, unnecessary_brace_in_string_interps

/*
    objectif : contruire une liste de ce genre d'éléments
    pour afficher une belle liste de "bénéficiaires"

       
    /* {
          beneficiaire_name: MANUE,
          beneficiaire_id: 070 d6700 - 10e8 - 11 ee - b340 - 513 da2c843eb,
          gestes: {
            Pompe à Chaleur Air / Eau: {
              id: 070 db520 - 10e8 - 11 ee - b340 - 513 da2c843eb,
              name: Pompe à Chaleur Air / Eau,
              formulaires: [{
                formulaire_filename: 070 d6700 - 10e8 - 11 ee - b340 - 513 da2c843eb_070db521 - 10e8 - 11 ee - b340 - 513 da2c843eb.json,
                formulaire_name: Avant dépose,
                nbRequiredData: 5,
                nbGivenData: 5,
                average_location: {
                  longitude: 5.60172925,
                  latitude: 43.447572550000004
                }
              }, {
                formulaire_filename: 070 d6700 - 10e8 - 11 ee - b340 - 513 da2c843eb_070e2a54 - 10e8 - 11 ee - b340 - 513 da2c843eb.json,
                formulaire_name: Installation,
                nbRequiredData: 14,
                nbGivenData: 0,
                average_location: {
                  longitude: 0.0,
                  latitude: 0.0
                }
              }]
            }
          },
          location: {
            longitude: 0.0,
            latitude: 0.0
          },
          average_location: {
            longitude: 5.60172925,
            latitude: 43.447572550000004
          }
          }*/
    */

import 'dart:io';
import 'dart:convert';
import '../models/models.dart';
import '../files/formulaire_json_file.dart';
import 'package:path_provider/path_provider.dart';

const String localSubDirectoryFormulaires = 'formulaires';
const String localSubDirectoryBeneficiaires = 'beneficiaires';

class BeneficiaireJSONFile {
  Beneficiaire beneficiaire;
  late String filename = "";

  BeneficiaireJSONFile({required this.beneficiaire});

  // listing de tous les Bénéficiaires
  static Future<List<FileSystemEntity>> getJSONFilesList() async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = [];
    try {
      files =
          Directory("${localDirectory.path}/${localSubDirectoryBeneficiaires}")
              .listSync();
    } on PathNotFoundException {
      files = [];
    }

    return files;
  }

  // cette fonction met à jour le fichier du bénéficiaire en fonction des fichiers de formulaires trouvés
  Future<void> updateBeneficiaireFileFromFormulaires() async {
    // init : je reconstitue à zero le fichier du bénéficiaire qui sera utilisé pour la liste (dans beneficiaires.dart)
    Map<String, dynamic> resultBeneficiaire = {
      "beneficiaire_name": beneficiaire.beneficiaire_name,
      "beneficiaire_id": beneficiaire.beneficiaire_uuid,
      "gestes": {},
      "average_location": {"longitude": 0.0, "latitude": 0.0}
    };

    List<Map<String, dynamic>> beneficiaireLocations = [];

    // dans le repertoire dédié à l'application
    final Directory localDirectory = await getApplicationDocumentsDirectory();

    // pour tous les formulaires trouvés !
    List<FileSystemEntity> listFormulairesFiles =
        Directory("${localDirectory.path}/${localSubDirectoryFormulaires}")
            .listSync();

    //

    // boucle sur tous les fichiers de Formulaires stockés en local ...
    for (var i = 0; i < listFormulairesFiles.length; i++) {
      var f = listFormulairesFiles[i];
      String relativePath = f.path.replaceAll(
          "${localDirectory.path}/${localSubDirectoryFormulaires}/", "");

      // si le fichier du formulaire itéré correspond au bon bénéficiaire
      if (relativePath.startsWith("${beneficiaire.beneficiaire_uuid}_")) {
        // je lis le Json du formulaire itéré
        var f2 = FormulaireJSONFile(filename: relativePath);
        String result = await f2.readFile();
        dynamic resultFormulaireJSON = jsonDecode(result);
        print(resultFormulaireJSON.toString());

        // j'en extrais le nom du  geste
        String gesteName = resultFormulaireJSON["geste"]["geste_name"];

        String gesteId = resultFormulaireJSON["geste"]["geste_uuid"];
        var gs = resultBeneficiaire["gestes"];

        int nbRequiredData = resultFormulaireJSON["fields"].length;

        // je recalcule le nombre de champs renseignés
        int nbGivenData = 0;
        for (var ifield = 0;
            ifield < resultFormulaireJSON["fields"].length;
            ifield++) {
          var field = resultFormulaireJSON["fields"][ifield];
          print(field.toString());
          if (field["photos"].length > 0 || field["noPhoto"] == true) {
            nbGivenData++;
          }
        }

        beneficiaireLocations.add(resultFormulaireJSON["average_location"]);

        // je rajoute le formulaire dans la liste des gestes du bénéficiaire
        // dont je suis en train de refaire un JSON pour affichage en liste
        if (gs.containsKey(gesteName)) {
          Map<String, dynamic> g = resultBeneficiaire["gestes"][gesteName];

          var formulaires = g["formulaires"];
          formulaires.add({
            "formulaire_filename": relativePath,
            "formulaire_name": resultFormulaireJSON["formulaire_name"],
            "nbRequiredData": nbRequiredData,
            "nbGivenData": nbGivenData,
            "average_location": resultFormulaireJSON["average_location"]
          });
          resultBeneficiaire["gestes"][gesteName]["formulaires"] = formulaires;
        } else {
          resultBeneficiaire["gestes"][gesteName] = {
            "geste_uuid": gesteId,
            "geste_name": gesteName,
            "formulaires": [
              {
                "formulaire_filename": relativePath,
                "formulaire_name": resultFormulaireJSON["formulaire_name"],
                "nbRequiredData": nbRequiredData,
                "nbGivenData": nbGivenData,
                "average_location": resultFormulaireJSON["average_location"]
              }
            ]
          };
        }
      }
    } // fin boucle for

    print(beneficiaireLocations.length);
    double averageLongitude = 0;
    double averageLatitude = 0;

    int nb = 0;
    for (var i = 0; i < beneficiaireLocations.length; i++) {
      double longitude = beneficiaireLocations[i]["longitude"];
      double latitude = beneficiaireLocations[i]["latitude"];
      if (longitude > 0.0 && latitude > 0.0) {
        averageLongitude = averageLongitude + longitude;
        averageLatitude = averageLatitude + latitude;
        nb++;
      }
    }
    if (nb > 0) {
      resultBeneficiaire["average_location"] = {
        "longitude": averageLongitude / nb,
        "latitude": averageLatitude / nb
      };
    }

    // ce fichier de bénéficiaire, je le stocke dans le repertoire qui contient un fichier json par beneficiaire
    String jsonBeneficiaireForList = jsonEncode(resultBeneficiaire);
    filename = "${beneficiaire.beneficiaire_uuid}.json";
    await writeToFile(jsonBeneficiaireForList);
  }

  /// Initially check if there is already a local file.
  /// If not, create one with the contents of the initial json in assets
  Future<File> _initializeFile() async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String path =
        "${localDirectory.path}/${localSubDirectoryBeneficiaires}/${filename}";

    final file = File(path);

    // si le fichier existe, ok
    if (await file.exists()) {
      return file;
    }

    // il faut donc creer le fichier

    // est-ce que le repertoire existe ?
    final String pathDirectory =
        "${localDirectory.path}/${localSubDirectoryBeneficiaires}";
    final fileDirectory = File(pathDirectory);
    if (!await fileDirectory.exists()) {
      await Directory(pathDirectory).create();
    }

    // allez, on créé ce fichier
    final file2 = File(path);
    await file2.create();

    return file2;
  }

  Future<String> readFile() async {
    final file = await _initializeFile();
    return await file.readAsString();
  }

  Future<void> writeToFile(String data) async {
    final file = await _initializeFile();
    await file.writeAsString(data);
  }

  // delete the json file for a specific beneficiaire (it will be for a specific geste ... after this PoC )
  // deletes also the json files for the matching formulaires json files
  static Future<void> deleteJSONFile(
      {required beneficiaire_id, required geste_uuid}) async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String beneficiaireJSONFilename =
        "${localDirectory.path}/${localSubDirectoryBeneficiaires}/${beneficiaire_id}.json";
    print(beneficiaireJSONFilename);
    File f = File(beneficiaireJSONFilename);
    String content = f.readAsStringSync();
    Map<String, dynamic> json = jsonDecode(content);
    print(json);

    Map<String, dynamic> jsonGestes = json["gestes"];
    for (var item in jsonGestes.entries) {
      print(item.key);
      print(item.value);
      var jsonGeste = item.value;
      List<dynamic> jsonFormulaires = jsonGeste["formulaires"];
      for (var i = 0; i < jsonFormulaires.length; i++) {
        Map<String, dynamic> jsonFormulaire = jsonFormulaires[i];
        String formulaireFilename =
            "${localDirectory.path}/${localSubDirectoryFormulaires}/${jsonFormulaire["formulaire_filename"]}";
        print("must delete ${formulaireFilename}");
        File f2 = File(formulaireFilename);
        f2.deleteSync();
      }
    }

    print("must delete ${beneficiaireJSONFilename}");
    File f3 = File(beneficiaireJSONFilename);
    f3.deleteSync();
  }
}
