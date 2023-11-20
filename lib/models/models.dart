// ignore_for_file: non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, depend_on_referenced_packages

import 'dart:convert';

import 'package:app_renovadmin/files/formulaire_json_file.dart';
import 'package:app_renovadmin/files/beneficiaire_json_file.dart';

import 'package:uuid/uuid.dart';

class Photo {
  final String photo_uuid;
  final String path;
  final String status;
  final Location location;
  late final DateTime created_date_utc;

  Photo(
      {required this.path,
      required this.photo_uuid,
      this.status = "Pending",
      required this.location,
      required this.created_date_utc}) {
    print("test");
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["photo_uuid"] = photo_uuid;
    data["path"] = path;
    data["status"] = status;
    data["location"] = location.toJSON();
    data["created_date_utc"] = created_date_utc.toString();
    return data;
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }
}

class Field {
  final String field_uuid;
  String field_name = "";
  String commentaire = "";
  List<Photo> photos = [];
  bool noPhoto = false;
  String attendu;
  late Map<String, dynamic> instructions;

  Field({
    required this.field_name,
    required this.field_uuid,
    required this.photos,
    this.commentaire = "",
    this.noPhoto = false,
    this.attendu = "",
  }) {
    Map<String, dynamic> x = getMapFieldsInstructions();
    if (x.containsKey(field_name)) {
      instructions = x[field_name];
    } else {
      instructions = {};
    }
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["field_uuid"] = field_uuid;
    data["field_name"] = field_name;
    data["commentaire"] = commentaire;
    data["noPhoto"] = noPhoto;
    data["instructions"] = instructions;
    List<dynamic> tempFields = [];
    for (var i = 0; i < photos.length; i++) {
      tempFields.add(photos[i].toJSON());
    }

    data["photos"] = tempFields;
    return data;
  }

  String getLabel() {
    if (instructions.keys.contains("label")) {
      return instructions["label"];
    }
    return "";
  }

  String getInstruction() {
    if (instructions.keys.contains("instruction")) {
      return instructions["instruction"];
    }
    return "";
  }

  List<String> getRequirements() {
    if (instructions.keys.contains("item_requirements")) {
      List requirements = instructions["item_requirements"];
      if (requirements.isNotEmpty) {
        return instructions["item_requirements"];
      }
    }
    return [];
  }

  String getExemple() {
    if (instructions.keys.contains("instruction")) {
      return instructions["exemple"];
    }
    return "";
  }

  static Map<String, dynamic> getMapFieldsInstructions() {
    return {
      "piece-identite": {
        "type": "photo",
        "label": "Pièce d’identité du bénéficiaire face recto",
        "instruction": "Pièce d’identité du bénéficiaire face recto",
        "item_requirements": ["Prénom", "nom"],
        "exemple": "assets/images_guides/piece-identite.png"
      },
      "ancienne-chaudiere": {
        "type": "photo",
        "label": "Ancienne chaudière avant dépose",
        "instruction": "Ancienne chaudière avant dépose",
        "item_requirements": ["Chaudière posée"],
        "exemple": "assets/images_guides/ancienne-chaudiere.png"
      },
      "plaque-signaletique-ancienne-chaudiere": {
        "type": "photo",
        "label": "Marque et référence de l'ancienne chaudière",
        "instruction": "Marque et référence de l'ancienne chaudière",
        "item_requirements": ["Marque de la chaudière", "Référence"],
        "exemple":
            "assets/images_guides/plaque-signaletique-ancienne-chaudiere.png"
      },
      "futur-emplacement-unite-exterieure": {
        "type": "photo",
        "label": "Emplacement prévu pour l'unité extérieure de la PAC",
        "instruction": "Emplacement prévu pour l'unité extérieure de la PAC",
        "item_requirements": [
          "Espace libre",
          "Les murs alentours",
          "Les fenêtres et portes alentours",
          "La nature du sol si la PAC est posée au sol",
          "L’espace au mur si la PAC est fixée au mur"
        ],
        "exemple": "assets/icons/renovadmin1024x1024.png"
      },
      "ajout-de-photo-avant-depose": {
        "type": "photo",
        "label": "Photos complémentaires si nécessaire",
        "instruction": "Photos complémentaires si nécessaire",
        "item_requirements": [],
        "exemple": "assets/icons/renovadmin1024x1024.png"
      },
      "ajout-de-photo-installation": {
        "type": "photo",
        "label": "Photos complémentaires si nécessaire",
        "instruction": "Photos complémentaires si nécessaire",
        "item_requirements": [],
        "exemple": "assets/icons/renovadmin1024x1024.png"
      },
      "depose-ancienne-chaudiere": {
        "type": "photo",
        "label": "Emplacement vide après dépose ancienne chaudière",
        "instruction": "Emplacement vide après dépose ancienne chaudière",
        "item_requirements": [
          "L’emplacement vide où se trouvait l’ancienne chaudière"
        ],
        "exemple": "assets/icons/renovadmin1024x1024.png"
      },
      "vue-d-ensemble-unite-interieure": {
        "type": "photo",
        "label": "Vue d’ensemble",
        "instruction": "Vue d’ensemble",
        "item_requirements": [
          "Absence de chaudière associée à la PAC",
          "Absence d’obstacle"
        ],
        "exemple": "assets/images_guides/vue-d-ensemble-unite-interieure.png"
      },
      "fixation-unite-interieure": {
        "type": "photo",
        "label": "Fixation unité intérieure",
        "instruction": "Fixation unité intérieure",
        "item_requirements": [
          "Élément de fixation sur châssis",
          "ou Fixation au mur",
          "ou Fixation par tubulures"
        ],
        "exemple": "assets/images_guides/fixation-unite-interieure.png"
      },
      "plaque-signaletique-unite-interieure": {
        "type": "photo",
        "label": "Plaque signalétique de l’unité intérieure",
        "instruction":
            "!! La plaque signalétique doit être lisible. Prendre la photo pour que les bords de la plaque opposés en largeur ou en hauteur touchent les bords de l’écran !!",
        "item_requirements": ["marque", "référence"],
        "exemple":
            "assets/images_guides/plaque-signaletique-unite-interieure.png"
      },
      "calorifuge-circuit-eau-chaude": {
        "type": "photo",
        "label":
            "Réseau des tuyauteries « eau chaude » calorifugé dans les espaces non chauffés",
        "instruction":
            "Réseau des tuyauteries « eau chaude » calorifugé dans les espaces non chauffés",
        "item_requirements": [
          "une tranche de tuyauterie caloriguée dans l'espace non chauffé",
        ],
        "exemple": "assets/images_guides/calorifuge-circuit-eau-chaude.png"
      },
      "calorifuge-circuit-frigorigene": {
        "type": "photo",
        "label":
            "Réseau des tuyauteries « Frigorigènes » calorifugé dans les espaces non chauffés",
        "instruction":
            "Réseau des tuyauteries « Frigorigènes » calorifugé dans les espaces non chauffés",
        "item_requirements": [
          "Une tranche de tuyauterie calorifugée à l'intérieur (en blanc sur l'exemple)",
        ],
        "exemple": "assets/images_guides/calorifuge-circuit-frigorigene.png"
      },
      "dispositifs-reglage-equilibrage-reseau": {
        "type": "photo",
        "label": "Dispositifs de réglage permettant l’équilibrage du réseau",
        "instruction":
            "Dispositifs de réglage permettant l’équilibrage du réseau",
        "item_requirements": [
          "Si radiateurs : Vanne d'équilibrage ou Té de réglage sur chaque radiateur",
          "Si plancher chauffant : Vanne sur clarinette",
        ],
        "exemple":
            "assets/images_guides/dispositifs-reglage-equilibrage-reseau.png"
      },
      "vue-d-ensemble-unite-exterieure": {
        "type": "photo",
        "label": "Vue d’ensemble unité extérieure",
        "instruction": "Vue d’ensemble unité extérieure",
        "item_requirements": [
          "L’unité",
          "Absence d’obstacles pouvant empêcher l’échange d’air",
          "Les murs et les cloisons autour de l’unité"
        ],
        "exemple": "assets/images_guides/vue-d-ensemble-unite-exterieure.png"
      },
      "unite-exterieure-aeration": {
        "type": "photo",
        "label": "Unité extérieure aération",
        "instruction": "Photographier la mesure au mètre ruban",
        "item_requirements": [
          "Les mesures entre l’unité et les éventuels murs à proximité",
          "Arrière, côté, dessus ou devant selon la configuration."
        ],
        "exemple": "assets/images_guides/unite-exterieure-aeration.png"
      },
      "plaque-signaletique-unite-exterieure": {
        "type": "photo",
        "label": "Plaque signalétique unité extérieure",
        "instruction":
            "Prendre la photo pour que les bords opposés en largeur ou en hauteur de la plaque touchent les bords de l’écran. Dans l’exemple, le haut et le bas de la plaque touchent les bords hauts et bas de la photo",
        "item_requirements": ["Référence"],
        "exemple":
            "assets/images_guides/plaque-signaletique-unite-exterieure.png"
      },
      "fixation-unite-exterieure": {
        "type": "photo",
        "label": "Fixation de l’unité extérieure",
        "instruction": "Fixation de l’unité extérieure",
        "item_requirements": ["Eléments de fixation"],
        "exemple": "assets/images_guides/fixation-unite-exterieure.png"
      },
      "radiateur": {
        "type": "photo",
        "label": "Un radiateur ou le sol (Si plancher chauffant)",
        "instruction": "Un radiateur ou le sol (Si plancher chauffant)",
        "item_requirements": [
          "Si radiateur : Un radiateur dans le contexte des pièces chauffées par la PAC.",
          "Si plancher chauffant : La pièce principale sans radiateurs"
        ],
        "exemple": "assets/images_guides/radiateur.png"
      },
      "facade-maison": {
        "type": "photo",
        "label": "Façade de la maison depuis la rue",
        "instruction": "Façade de la maison depuis la rue",
        "item_requirements": ["L’étage ou l’absence d’étage de la maison."],
        "exemple": "assets/images_guides/facade-maison.png"
      },
    };
  }
}

class Location {
  final double longitude;
  final double latitude;
  Location({required this.longitude, required this.latitude});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["longitude"] = longitude;
    data["latitude"] = latitude;
    return data;
  }
}

class Formulaire {
  final String formulaire_uuid;
  final String formulaire_name;
  final int nbFilledFields;
  late List<Field> fields;

  Formulaire(
      {required this.formulaire_uuid,
      required this.formulaire_name,
      required this.nbFilledFields,
      required this.fields}) {
    // ajoute les fields manquants si le formulaire vient juste d'etre créé
    if (fields.isEmpty) {
      List<String> x = getListFields();
      for (var i = 0; i < x.length; i++) {
        fields.add(Field(
            field_uuid: Field.generateUUID(),
            field_name: x[i],
            photos: [])); // pas de photo par defaut
      }
    }
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  /*

  {
	"id": "f4dddf61-0c37-11ee-a66f-13b0cf16df23",
	"name": "Avant dépose",
	"geste": {
		"id": "f4dddf60-0c37-11ee-a66f-13b0cf16df23",
		"name": "Pompe à Chaleur Air/Eau"
	},
	"beneficiaire": {
		"id": "f4dd9140-0c37-11ee-a66f-13b0cf16df23",
		"name": "Cristiano Ronaldo"
	},
	"location": {
		"longitude": 0.0,
		"latitude": 0.0
	},
	"fields": [{
		"id": "f4de2d80-0c37-11ee-a66f-13b0cf16df23",
		"name": "piece-identite",
		"commentaire": "",
		"noPhoto": false,
		"photos": [{
			"id": "fbb2aeb0-0c37-11ee-a66f-13b0cf16df23",
			"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP6906419912472902598.jpg",
			"status": "Pending",
			"location": {
				"longitude": 0.0,
				"latitude": 0.0
			}
		}]
	}, {
		"id": "f4de2d81-0c37-11ee-a66f-13b0cf16df23",
		"name": "ancienne-chaudiere",
		"commentaire": "",
		"noPhoto": true,
		"photos": []
	}, {
		"id": "f4de2d82-0c37-11ee-a66f-13b0cf16df23",
		"name": "plaque-signaletique-ancienne-chaudiere",
		"commentaire": "",
		"noPhoto": false,
		"photos": []
	}, {
		"id": "f4de2d83-0c37-11ee-a66f-13b0cf16df23",
		"name": "futur-emplacement-unite-exterieure",
		"commentaire": "",
		"noPhoto": false,
		"photos": []
	}, {
		"id": "f4de2d84-0c37-11ee-a66f-13b0cf16df23",
		"name": "ajout-de-photo",
		"commentaire": "",
		"noPhoto": false,
		"photos": []
	}]
}
*/

  Future<void> save(Geste geste, Beneficiaire beneficiaire) async {
    var x = toJSON(geste: geste, beneficiaire: beneficiaire);
    var json = jsonEncode(x);

    String filename = buildFileName(beneficiaire, this);
    //  "${beneficiaire.id}_${id}.json";

    // attention le nom de fichier commence par l'id du bénéficiaire , ceci est utile pour d'autres parties de l'appli

    // ECRITURE A SURVEILLER (attention au nom du fichier !)
    FormulaireJSONFile f = FormulaireJSONFile(filename: filename);
    await f.writeToFile(json);

    // update theses informations at "beneficiaire" level
    await beneficiaire.save();
  }

  Location getAverageLocation() {
    Location l = Location(longitude: 0.0, latitude: 0.0);
    double longitudeMoy = 0;
    double latitudeMoy = 0;
    int nbPhotos = 0;

    for (var i = 0; i < fields.length; i++) {
      for (var j = 0; j < fields[i].photos.length; j++) {
        longitudeMoy = longitudeMoy + fields[i].photos[j].location.longitude;
        latitudeMoy = latitudeMoy + fields[i].photos[j].location.latitude;
        nbPhotos++;
      }
    }
    if (nbPhotos > 0) {
      Location l2 = Location(
          longitude: longitudeMoy / nbPhotos, latitude: latitudeMoy / nbPhotos);
      return l2;
    }

    return l;
  }

  Map<String, dynamic> toJSON(
      {required Beneficiaire beneficiaire, required Geste geste}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['formulaire_uuid'] = formulaire_uuid;
    data['formulaire_name'] = formulaire_name;
    data['geste'] = geste.toJSON();
    data['beneficiaire'] = beneficiaire.toJSON();

    List<dynamic> tempFields = [];

    for (var i = 0; i < fields.length; i++) {
      tempFields.add(fields[i].toJSON());
    }

    data["average_location"] = getAverageLocation().toJSON();
    data['fields'] = tempFields;

    return data;
  }

  // final List<Field> fields;
  // Formulaire(this.name, this.fields);

  List<String> getListFields() {
    if (getFormsFields().containsKey(formulaire_name)) {
      var l = getFormsFields()[formulaire_name];
      if (l != null) {
        return l;
      }
    }

    return [];
  }

  static Map<int, String> getFormsOrder() {
    return {0: "Avant dépose", 1: "Installation"};
  }

  Map<String, List<String>> getFormsFields() {
    return {
      "Avant dépose": [
        "piece-identite",
        "ancienne-chaudiere",
        "plaque-signaletique-ancienne-chaudiere",
        "futur-emplacement-unite-exterieure",
        "facade-maison",
        "ajout-de-photo-avant-depose"
      ],
      "Installation": [
        "depose-ancienne-chaudiere",
        "vue-d-ensemble-unite-interieure",
        "fixation-unite-interieure",
        "plaque-signaletique-unite-interieure",
        "calorifuge-circuit-eau-chaude",
        "calorifuge-circuit-frigorigene",
        "dispositifs-reglage-equilibrage-reseau",
        "vue-d-ensemble-unite-exterieure",
        "unite-exterieure-aeration",
        "plaque-signaletique-unite-exterieure",
        "fixation-unite-exterieure",
        "radiateur",
        "ajout-de-photo-installation"
      ]
    };
  }

  static String buildFileName(Beneficiaire b, Formulaire f) {
    String result = "${b.beneficiaire_uuid}_${f.formulaire_uuid}.json";
    return result;
  }
}

class Geste {
  final String geste_uuid;
  final String geste_name;
  final List<Formulaire> formulaires;
  Geste(
      {required this.geste_name,
      required this.formulaires,
      required this.geste_uuid});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geste_uuid'] = geste_uuid;
    data['geste_name'] = geste_name;
    return data;
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }
}

class Beneficiaire {
  String beneficiaire_uuid;
  String beneficiaire_name;
  final List<Geste> gestes;
  final String address = "";
  final int distance;
  Beneficiaire(this.gestes,
      {required this.beneficiaire_uuid,
      required this.beneficiaire_name,
      this.distance = 0});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['beneficiaire_uuid'] = beneficiaire_uuid;
    data['beneficiaire_name'] = beneficiaire_name;
    return data;
  }

  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  Future<void> save() async {
    BeneficiaireJSONFile f = BeneficiaireJSONFile(beneficiaire: this);
    await f.updateBeneficiaireFileFromFormulaires();
  }

  static Map<String, dynamic> fromJSON(json) {
    List<Map<String, dynamic>> lg = [];
    Map<String, dynamic> itemGestes = json["gestes"];
    for (String geste_name in itemGestes.keys) {
      List<Map<String, dynamic>> itemFormulaire = [];
      print(geste_name);
      var gesteItem = itemGestes[geste_name];
      var fs = gesteItem["formulaires"];
      for (var i = 0; i < fs.length; i++) {
        var f = fs[i];

        itemFormulaire.add({
          "formulaire_filename": f["formulaire_filename"],
          "formulaire_name": f["formulaire_name"],
          "nbRequiredData": f["nbRequiredData"],
          "nbGivenData": f["nbGivenData"]
        });
      }
      Map<String, dynamic> g = {
        "geste_name": geste_name,
        "geste_uuid": gesteItem["geste_uuid"],
        "formulaires": itemFormulaire
      };
      lg.add(g);
    }

    Map<String, dynamic> b = {
      "name": json["beneficiaire_name"],
      "beneficiaire_name": json["beneficiaire_name"],
      "beneficiaire_id": json["beneficiaire_id"],
      "gestes": lg,
      "average_location": json["average_location"],
      "distance": 0
    };
    return b;
  }
}
