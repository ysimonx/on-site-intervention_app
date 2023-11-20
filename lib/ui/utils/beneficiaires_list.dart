// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';
import 'dart:convert';

import 'package:app_renovadmin/models/models.dart';
import 'package:app_renovadmin/files/beneficiaire_json_file.dart';
import 'package:geolocator/geolocator.dart';

class BeneficiairesList {
  Future<List<Map<String, dynamic>>>
      buildListOfBeneficiairesFromSavedFormulaires(
          int dummy, Position? myLocation) async {
    //
    // pour trier la liste par distance croissante par rapport à ma position
    //
    // je recupere la geoloc actuelle
    //
    //
    if (myLocation != null) {
    } else {
      myLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    print(myLocation.toString());

    // listing de tous les Bénéficiaires
    List<FileSystemEntity> files =
        await BeneficiaireJSONFile.getJSONFilesList();

    // Pour chaque Bénéficiaire stocké en json dans /beneficiares/....json
    // je vais chercher les informations nécessaires et suffisantes pour afficher la liste dans beneficiaires*.dart
    List<Map<String, dynamic>> resultListBeneficiaires = [];
    for (var i = 0; i < files.length; i++) {
      var f = files[i];
      print(f.path);
      File f2 = File(f.path);
      String content = await f2.readAsString();
      dynamic json = jsonDecode(content);
      print(json.toString());

      // Calcul d'une variable appelée distance, mais qui est une formule approximative simple pour trier par ordre croissant ()
      double distance =
          calcDistanceBetween(myLocation, json["average_location"]);
      print(distance);

      Map<String, dynamic> b = Beneficiaire.fromJSON(json);
      b["distance"] = distance;

      String jsonRes = jsonEncode(b);
      print(jsonRes);
      resultListBeneficiaires.add(b);
    }

    // tri de la liste sur cette distance
    resultListBeneficiaires
        .sort((a, b) => a["distance"].compareTo(b["distance"]));

    print(resultListBeneficiaires.length);
    return resultListBeneficiaires;
  }

  double calcDistanceBetween(Position myPosition, jsonPosition) {
    if (jsonPosition["longitude"] == 0.0 || jsonPosition["latitude"] == 0.0) {
      return 0.0;
    }
    double dlng = myPosition.longitude - jsonPosition["longitude"];
    double dlat = myPosition.latitude - jsonPosition["latitude"];
    double result = dlng * dlng + dlat * dlat;
    return result;
  }
}
