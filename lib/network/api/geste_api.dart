// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, non_constant_identifier_names

// ignore: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import '../../files/formulaire_json_file.dart';
import '../../network/api/constants.dart';
import 'package:dio/dio.dart';

import '../dio_client.dart';

class GesteApi {
  final DioClient dioClient;

  GesteApi({required this.dioClient});

  Future<Response?> sendGeste({
    required String beneficiaire_id,
    required String beneficiaire_name,
    required String geste_uuid,
    required String geste_name,
    required dynamic gestes,
  }) async {
    var formData = {
      "beneficiaire_uuid": beneficiaire_id,
      "beneficiaire_name": beneficiaire_name,
      "geste_uuid": geste_uuid,
      "geste_name": geste_name,
      "formulaires": [],
    };

    var listFormulaires = [];

    for (var i = 0; i < gestes.length; i++) {
      Map<String, dynamic> geste = gestes[i];
      print(geste.toString());
      if (geste["geste_uuid"] == geste_uuid) {
        var formulaires = geste["formulaires"];
        for (var j = 0; j < formulaires.length; j++) {
          Map<String, dynamic> formulaire = formulaires[j];
          String content = await FormulaireJSONFile(
                  filename: formulaire["formulaire_filename"])
              .readFile();
          Map<String, dynamic> jsonFormulaire = jsonDecode(content);
          listFormulaires.add(jsonFormulaire);
        }
      }
    }

    formData["formulaires"] = listFormulaires;

    print(formData);
    String json = jsonEncode(formData);

    /* exemple : 

{
	"beneficiaire_uuid": "969a1550-14c4-11ee-8b30-7323fbdfde82",
	"beneficiaire_name": "YANNICK",
	"geste_uuid": "969a3c60-14c4-11ee-8b30-7323fbdfde82",
	"geste_name": "Pompe à Chaleur Air/Eau",
	"formulaires": [{
		"formulaire_uuid": "969a3c61-14c4-11ee-8b30-7323fbdfde82",
		"formulaire_name": "Avant dépose",
		"geste": {
			"geste_uuid": "969a3c60-14c4-11ee-8b30-7323fbdfde82",
			"geste_name": "Pompe à Chaleur Air/Eau"
		},
		"beneficiaire": {
			"beneficiaire_uuid": "969a1550-14c4-11ee-8b30-7323fbdfde82",
			"beneficiaire_name": "YANNICK"
		},
		"average_location": {
			"longitude": 5.67391146,
			"latitude": 43.44475396
		},
		"fields": [{
			"field_uuid": "969a8a80-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "piece-identite",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Pièce d’identité du bénéficiaire face recto",
				"instruction": "Pièce d’identité du bénéficiaire face recto",
				"item_requirements": ["Prénom", "nom"],
				"exemple": "assets/images_guides/piece-identite.png"
			},
			"photos": [{
				"photo_uuid": "a1d60f50-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP4426933886892042614.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739097,
					"latitude": 43.4447517
				},
				"created_date": "2023-06-27 08:28:45.638051Z"
			}]
		}, {
			"field_uuid": "969affb0-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "ancienne-chaudiere",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Ancienne chaudière avant dépose",
				"instruction": "Ancienne chaudière avant dépose",
				"item_requirements": ["Chaudière posée"],
				"exemple": "assets/images_guides/ancienne-chaudiere.png"
			},
			"photos": [{
				"photo_uuid": "a5b0ff90-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP1281461026810661599.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739234,
					"latitude": 43.4447612
				},
				"created_date": "2023-06-27 08:28:52.105364Z"
			}]
		}, {
			"field_uuid": "969b26c0-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "plaque-signaletique-ancienne-chaudiere",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Plaque signalétique de l’ancienne chaudière",
				"instruction": "Plaque signalétique de l’ancienne chaudière",
				"item_requirements": ["Marque de la chaudière", "Référence"],
				"exemple": "assets/images_guides/plaque-signaletique-ancienne-chaudiere.png"
			},
			"photos": [{
				"photo_uuid": "a9da0fd0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP4846045763176587190.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.67391,
					"latitude": 43.4447539
				},
				"created_date": "2023-06-27 08:28:59.085881Z"
			}]
		}, {
			"field_uuid": "969b26c1-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "futur-emplacement-unite-exterieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Emplacement unité extérieure",
				"instruction": "Emplacement unité extérieure",
				"item_requirements": ["Espace libre", "Les murs alentours", "Les fenêtres et portes alentours", "La nature du sol si la PAC est posée au sol", "L’espace au mur si la PAC est fixée au mur"],
				"exemple": "assets/icons/renovadmin1024x1024.png"
			},
			"photos": [{
				"photo_uuid": "afd45da0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP8367521594095112410.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739065,
					"latitude": 43.4447501
				},
				"created_date": "2023-06-27 08:29:09.114772Z"
			}]
		}, {
			"field_uuid": "969b26c2-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "ajout-de-photo",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Toutes photos complémentaires jugées nécessaires",
				"instruction": "Toutes photos complémentaires jugées nécessaires",
				"item_requirements": [""],
				"exemple": "assets/icons/renovadmin1024x1024.png"
			},
			"photos": [{
				"photo_uuid": "b4092db0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP3324226121048350426.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739077,
					"latitude": 43.4447529
				},
				"created_date": "2023-06-27 08:29:16.171585Z"
			}]
		}]
	}, {
		"formulaire_uuid": "969b26c3-14c4-11ee-8b30-7323fbdfde82",
		"formulaire_name": "Installation",
		"geste": {
			"geste_uuid": "969a3c60-14c4-11ee-8b30-7323fbdfde82",
			"geste_name": "Pompe à Chaleur Air/Eau"
		},
		"beneficiaire": {
			"beneficiaire_uuid": "969a1550-14c4-11ee-8b30-7323fbdfde82",
			"beneficiaire_name": "YANNICK"
		},
		"average_location": {
			"longitude": 5.673909757142859,
			"latitude": 43.44475300714284
		},
		"fields": [{
			"field_uuid": "969b26c4-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "depose-ancienne-chaudiere",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Dépose de l’ancienne chaudière",
				"instruction": "Dépose de l’ancienne chaudière",
				"item_requirements": ["L’emplacement vide où se trouvait l’ancienne chaudière"],
				"exemple": "assets/icons/renovadmin1024x1024.png"
			},
			"photos": [{
				"photo_uuid": "c0168170-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP2164211543444728576.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739098,
					"latitude": 43.4447538
				},
				"created_date": "2023-06-27 08:30:04.657288Z"
			}]
		}, {
			"field_uuid": "969b26c5-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "vue-d-ensemble-unite-interieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Vue d’ensemble",
				"instruction": "Vue d’ensemble",
				"item_requirements": ["Absence de chaudière associée à la PAC", "Absence d’obstacle"],
				"exemple": "assets/images_guides/vue-d-ensemble-unite-interieure.png"
			},
			"photos": [{
				"photo_uuid": "c25db250-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP7918041035789740090.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739098,
					"latitude": 43.4447538
				},
				"created_date": "2023-06-27 08:30:04.657442Z"
			}]
		}, {
			"field_uuid": "969b4dd0-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "fixation-unite-interieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Montrer l'élément de fixation",
				"instruction": "Montrer l'élément de fixation",
				"item_requirements": ["Élément de fixation sur châssis", "ou Fixation au mur", "ou Fixation par tubulures"],
				"exemple": "assets/images_guides/fixation-unite-interieure.png"
			},
			"photos": [{
				"photo_uuid": "c51cd250-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP8904475459438654243.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739094,
					"latitude": 43.4447522
				},
				"created_date": "2023-06-27 08:30:04.657496Z"
			}]
		}, {
			"field_uuid": "969b4dd1-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "plaque-signaletique-unite-interieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Plaque signalétique de l’unité intérieure",
				"instruction": "!! La plaque signalétique doit être lisible. Prendre la photo pour que les bords de la plaque opposés en largeur ou en hauteur touchent les bords de l’écran !!",
				"item_requirements": ["marque", "référence"],
				"exemple": "assets/images_guides/plaque-signaletique-unite-interieure.png"
			},
			"photos": [{
				"photo_uuid": "c77d3080-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP3173541024847803237.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739094,
					"latitude": 43.4447522
				},
				"created_date": "2023-06-27 08:30:04.657543Z"
			}]
		}, {
			"field_uuid": "969b4dd2-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "calorifuge-circuit-eau-chaude",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Réseau des tuyauteries « eau chaude » calorifugé dans les espaces non chauffés",
				"instruction": "Réseau des tuyauteries « eau chaude » calorifugé dans les espaces non chauffés",
				"item_requirements": ["une tranche de tuyauterie calorifugée dans l'espace non chauffé"],
				"exemple": "assets/images_guides/calorifuge-circuit-eau-chaude.png"
			},
			"photos": [{
				"photo_uuid": "ca167900-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP7228053014973169734.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.673908,
					"latitude": 43.4447517
				},
				"created_date": "2023-06-27 08:30:04.657587Z"
			}]
		}, {
			"field_uuid": "969b4dd3-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "calorifuge-circuit-frigorigene",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Réseau des tuyauteries « Frigorigènes » calorifugé dans les espaces non chauffés",
				"instruction": "Réseau des tuyauteries « Frigorigènes » calorifugé dans les espaces non chauffés",
				"item_requirements": ["Une tranche de tuyauterie calorifugée à l'intérieur (en blanc sur l'exemple)"],
				"exemple": "assets/images_guides/calorifuge-circuit-frigorigene.png"
			},
			"photos": [{
				"photo_uuid": "cc5b38e0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP5064473003683757737.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.673908,
					"latitude": 43.4447517
				},
				"created_date": "2023-06-27 08:30:04.657667Z"
			}]
		}, {
			"field_uuid": "969b4dd4-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "dispositifs-reglage-equilibrage-reseau",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Dispositifs de réglage permettant l’équilibrage du réseau",
				"instruction": "Dispositifs de réglage permettant l’équilibrage du réseau",
				"item_requirements": ["Si radiateurs : Vanne d'équilibrage ou Té de réglage sur chaque radiateur", "Si plancher chauffant : Vanne sur clarinette si planché chauffant"],
				"exemple": "assets/images_guides/dispositifs-reglage-equilibrage-reseau.png"
			},
			"photos": [{
				"photo_uuid": "cf534330-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP4839614300354784455.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739097,
					"latitude": 43.4447533
				},
				"created_date": "2023-06-27 08:30:04.657726Z"
			}]
		}, {
			"field_uuid": "969b4dd5-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "vue-d-ensemble-unite-exterieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Vue d’ensemble unité extérieure",
				"instruction": "Vue d’ensemble unité extérieure",
				"item_requirements": ["L’unité", "Absence d’obstacles pouvant empêcher l’échange d’air", "Les murs et les cloisons autour de l’unité"],
				"exemple": "assets/images_guides/vue-d-ensemble-unite-exterieure.png"
			},
			"photos": [{
				"photo_uuid": "d71c0f70-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP1656938961339673656.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739091,
					"latitude": 43.4447542
				},
				"created_date": "2023-06-27 08:30:15.016054Z"
			}]
		}, {
			"field_uuid": "969b4dd6-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "unite-exterieure-aeration",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Unité extérieure aération",
				"instruction": "Photographier la mesure au mètre ruban",
				"item_requirements": ["Les mesures entre l’unité et les éventuels murs à proximité", "Arrière, côté, dessus ou devant selon la configuration."],
				"exemple": "assets/images_guides/unite-exterieure-aeration.png"
			},
			"photos": [{
				"photo_uuid": "d9cf6fa0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP1996837324492726753.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739091,
					"latitude": 43.4447535
				},
				"created_date": "2023-06-27 08:30:19.547255Z"
			}]
		}, {
			"field_uuid": "969b4dd7-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "plaque-signaletique-unite-exterieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Plaque signalétique unité extérieure",
				"instruction": "Prendre la photo pour que les bords opposés en largeur ou en hauteur de la plaque touchent les bords de l’écran. Dans l’exemple, le haut et le bas de la plaque touchent les bords hauts et bas de la photo",
				"item_requirements": ["Référence"],
				"exemple": "assets/images_guides/plaque-signaletique-unite-exterieure.png"
			},
			"photos": [{
				"photo_uuid": "dbe3f7c0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP3163231615627003091.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739091,
					"latitude": 43.4447535
				},
				"created_date": "2023-06-27 08:30:23.037452Z"
			}]
		}, {
			"field_uuid": "969b4dd8-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "fixation-unite-exterieure",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Fixation de l’unité extérieure",
				"instruction": "Fixation de l’unité extérieure",
				"item_requirements": ["Eléments de fixation"],
				"exemple": "assets/images_guides/fixation-unite-exterieure.png"
			},
			"photos": [{
				"photo_uuid": "dec37100-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP3721741219475056146.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739118,
					"latitude": 43.444753
				},
				"created_date": "2023-06-27 08:30:27.857080Z"
			}]
		}, {
			"field_uuid": "969b4dd9-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "radiateur",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Un radiateur",
				"instruction": "Un radiateur",
				"item_requirements": ["Si radiateur : Un radiateur dans le contexte des pièces chauffées par la PAC.", "-\tSi plancher chauffant : La pièce principale sans radiateurs"],
				"exemple": "assets/images_guides/radiateur.png"
			},
			"photos": [{
				"photo_uuid": "e100dde0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP3123721096461316746.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739118,
					"latitude": 43.444753
				},
				"created_date": "2023-06-27 08:30:31.614881Z"
			}]
		}, {
			"field_uuid": "969b4dda-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "facade-maison",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Façade de la maison depuis la rue",
				"instruction": "Façade de la maison depuis la rue",
				"item_requirements": ["L’étage ou l’absence d’étage de la maison."],
				"exemple": "assets/images_guides/facade-maison.png"
			},
			"photos": [{
				"photo_uuid": "e4645430-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP2689224175511573164.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739108,
					"latitude": 43.4447531
				},
				"created_date": "2023-06-27 08:30:37.301312Z"
			}]
		}, {
			"field_uuid": "969b4ddb-14c4-11ee-8b30-7323fbdfde82",
			"field_name": "ajout-de-photo",
			"commentaire": "",
			"noPhoto": false,
			"instructions": {
				"type": "photo",
				"label": "Toutes photos complémentaires jugées nécessaires",
				"instruction": "Toutes photos complémentaires jugées nécessaires",
				"item_requirements": [""],
				"exemple": "assets/icons/renovadmin1024x1024.png"
			},
			"photos": [{
				"photo_uuid": "e696eba0-14c4-11ee-8b30-7323fbdfde82",
				"path": "/data/user/0/com.renovadmin.app_renovadmin/cache/CAP4367907703116164446.jpg",
				"status": "Pending",
				"location": {
					"longitude": 5.6739108,
					"latitude": 43.4447531
				},
				"created_date": "2023-06-27 08:30:40.986894Z"
			}]
		}]
	}]
}




    */
    try {
      final Response response = await dioClient.post(
        Endpoints.uploadGeste,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );
      return response;
    } on DioException catch (e) {
      print(e.response?.statusCode);

      /* if (e.response?.statusCode == 400) {
        if (e.response?.data.contains("photo already uploaded")) {
          return e.response;
        }
      }*/
      rethrow;
    }
  }

  Future<Response?> processDownloadBackOfficeFeedback(
      List<String> listGestesUuidForBackOfficeFeedback) async {
    print(listGestesUuidForBackOfficeFeedback.length);
    print("processDownloadBackOfficeFeedback call");
    List<Map<String, String>> gestes = [];
    for (var i = 0; i < listGestesUuidForBackOfficeFeedback.length; i++) {
      gestes.add({"geste_uuid": listGestesUuidForBackOfficeFeedback[i]});
    }
    print(gestes);
    Map<String, dynamic> data = {"gestes": gestes};
    String json = jsonEncode(data);
    print(json);
    try {
      final Response response = await dioClient.post(
        Endpoints.downloadBackOfficeFeedBack,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: json,
      );
      print(response.statusCode);
      return response;
    } on DioException catch (e) {
      print(e.response?.statusCode);

      /* if (e.response?.statusCode == 400) {
        if (e.response?.data.contains("photo already uploaded")) {
          return e.response;
        }
      }*/
      rethrow;
    }
  }
}
