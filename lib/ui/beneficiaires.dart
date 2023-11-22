// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import '../network/api/geste_api.dart';
import '../files/formulaire_json_file.dart';
import '../files/beneficiaire_json_file.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:map_launcher/map_launcher.dart';

import '../network/api/image_api.dart';
import '../network/dio_client.dart';
import '../ui/formulaire.dart';
import '../ui/widget/app_bar.dart';
import '../models/models.dart';
import './widget/beneficiaires/beneficiaires_item.dart';
import './utils/beneficiaires_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// cf https://blog.logrocket.com/how-add-list-tile-flutter/

class BeneficiairesPage extends StatefulWidget {
  const BeneficiairesPage({super.key, required this.title});

  @override
  State<BeneficiairesPage> createState() => _BeneficiairesPageState();
  final String title;
}

class _BeneficiairesPageState extends State<BeneficiairesPage> {
  late final List<Beneficiaire> listBeneficiaires;
  late List<String> listGestesUuidForBackOfficeFeedback;
  late Map<String, String> mapGestesUuidControleStatus;
  late Map<String, String> mapGestesUuidControleCommentaire;

  late BeneficiairesList classBeneficiairesListUtil;
  late Timer timerProcessUploadPending;
  late Timer timerProcessDownloadBackOfficeFeedback;
  late DioClient dioClient;
  late ImageApi imageApi;
  late Position? myLocation;

  late FlutterSecureStorage _storage;

  int _dummy = 0;

  TextEditingController editingController = TextEditingController();

  bool processingImageUpload = false;

  var mapLastSendDate = {};

  _BeneficiairesPageState();

  @override
  void initState() {
    Intl.defaultLocale = 'fr_FR';
    initializeDateFormatting('fr_FR', null);
    mapLastSendDate = {};

    listBeneficiaires = [];
    mapGestesUuidControleStatus = {};
    mapGestesUuidControleCommentaire = {};
    listGestesUuidForBackOfficeFeedback = [];

    dioClient = DioClient(Dio());
    imageApi = ImageApi(dioClient: dioClient);

    classBeneficiairesListUtil = BeneficiairesList();

    _storage = const FlutterSecureStorage();

    myLocation = null;

    processingImageUpload = false;
    /*
    timerProcessUploadPending =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (processingImageUpload) {
        print("processUploadPendingImages aborted");
        return;
      }
      print("processUploadPendingImages start");
      processingImageUpload = true;
      await imageApi.processUploadPendingImages();
      processingImageUpload = false;
    });
    

    Future.delayed(const Duration(seconds: 2), () async {
      await processBackOfficeFeedback();
      myLocation = (await Geolocator.getLastKnownPosition())!;
    });

    timerProcessDownloadBackOfficeFeedback =
        Timer.periodic(const Duration(seconds: 20), (timer) async {
      print("timerProcessDownloadBackOfficeFeedback");
      await processBackOfficeFeedback();
      myLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    });
    */
    super.initState();
  }

  Future<void> processBackOfficeFeedback() async {
    GesteApi gesteAPI = GesteApi(dioClient: dioClient);
    try {
      Response? response = await gesteAPI.processDownloadBackOfficeFeedback(
          listGestesUuidForBackOfficeFeedback);
      if (response != null) {
        print(response.statusCode);
        if (response.statusCode == 200) {
          var listControles = response.data;

          print(listControles);
          for (var i = 0; i < listControles.length; i++) {
            var controle = listControles[i];
            print(controle["controle_status"]);
            mapGestesUuidControleStatus[controle["geste_uuid"]] =
                controle["controle_status"];
            mapGestesUuidControleCommentaire[controle["geste_uuid"]] =
                controle["commentaires"];
          }
          setState(() {
            _dummy++;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    print("processUploadPendingImages dispose timer");
    //timerProcessUploadPending.cancel();
    //timerProcessDownloadBackOfficeFeedback.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: BaseAppBar(widget.title)),
        body: FutureBuilder(
          future: classBeneficiairesListUtil
              .buildListOfBeneficiairesFromSavedFormulaires(_dummy,
                  myLocation), // il suffit de changer la valeur _dummy pour rafraichir cette liste :)
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> listJSONBeneficiaires = snapshot.data;
              return Column(children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50), // NEW
                        ),
                        onPressed: onNewBeneficiaire,
                        child: const Text(
                          'AJOUTER UN CHANTIER',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: ListView.builder(
                        // Let the ListView know how many items it needs to build.
                        itemCount: listJSONBeneficiaires.length,
                        // Provide a builder function. This is where the magic happens.
                        // Convert each item into a widget based on the type of item it is.
                        itemBuilder: (context, index) {
                          return buildBeneficiairesListGestes(
                              listJSONBeneficiaires[index]);

                          /* return Text("${index} : ${l[index]["name"]}"); */
                        },
                      )),
                )
              ]);
            } else if (snapshot.hasError) {
              return const Text("error");
            } else {
              return const Center(
                  child: Center(
                child: CircularProgressIndicator(),
              ));
            }
          },
        )
        /* ,floatingActionButton: FloatingActionButton(
          onPressed: onNewBeneficiaire,
          tooltip: 'Nouveau Bénéficiaire',
          child: const Icon(Icons.add),
        )*/
        );
  }

  void onNewBeneficiaire() {
    createAlertDialogNewBeneficiaire(context)
        .then((Beneficiaire beneficiaire) async {
      Geste geste = beneficiaire.gestes[0];

      List<Formulaire> formulaires = geste.formulaires;
      for (var i = 0; i < formulaires.length; i++) {
        Formulaire formulaire = formulaires[i];
        await formulaire.save(geste, beneficiaire);
      }

      setState(() {
        _dummy++;
      });
    });

    return;
  }

  Future<void> deleteBeneficiaireGeste(
      {required beneficiaire_id, required geste_uuid}) async {
    // TODO supprimer geste dans beneficiaire plutot que le beneficiaire complet
    await BeneficiaireJSONFile.deleteJSONFile(
        beneficiaire_id: beneficiaire_id, geste_uuid: geste_uuid);
  }

  // POUR UN BENEFICIAIRE
  Widget buildBeneficiairesListGestes(Map<String, dynamic> mapBeneficiaire) {
    return SizedBox(
        height: (mapBeneficiaire["gestes"].length * 200 + 100).toDouble(),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mapBeneficiaire["name"].toUpperCase(),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge),
                /*Text("${mapBeneficiaire["distance"]} km",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge)*/
              ]),
              PopupMenuButton<int>(
                onSelected: (newValue) async {
                  if (newValue == 3) {
                    final availableMaps = await MapLauncher.installedMaps;
                    print(
                        availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

                    await availableMaps.first.showMarker(
                      title: mapBeneficiaire["name"].toUpperCase(),
                      coords: Coords(
                          mapBeneficiaire["average_location"]["latitude"],
                          mapBeneficiaire["average_location"]["longitude"]),
                    );
                  }
                  if (newValue == 4) {
                    print(mapBeneficiaire.toString());
                    await deleteBeneficiaireGeste(
                        beneficiaire_id: mapBeneficiaire["beneficiaire_id"],
                        geste_uuid: mapBeneficiaire["geste_uuid"]);
                    const snackBar = SnackBar(
                      content: Text('Bénéficiaire Supprimé'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    setState(() {
                      _dummy++;
                    });
                  }
                  if (newValue == 5) {
                    var gestes = mapBeneficiaire["gestes"];
                    var geste = gestes[
                        0]; // TODO: ce n'est pas normal ici !! je choisis le geste 0 par defaut
                    await _storage.delete(key: "send_${geste["geste_uuid"]}");

                    setState(() {
                      _dummy++;
                    });
                  }
                },
                itemBuilder: (context) => [
                  /*const PopupMenuItem(
                    value: 1,
                    child: Text("supprimer"),
                  ),*/
                  /*const PopupMenuItem(
                    value: 2,
                    child: Text("ajouter opération"),
                  ),*/
                  /* const PopupMenuItem(
                    value: 3,
                    child: Text("naviguer vers"),
                  ),
                  const PopupMenuDivider(),
                  */
                  const PopupMenuItem(
                    value: 4,
                    child: Text("supprimer"),
                  ),
                  if (mapLastSendDate.keys.contains(
                          mapBeneficiaire["gestes"][0]["geste_uuid"]) &&
                      mapLastSendDate[mapBeneficiaire["gestes"][0]
                              ["geste_uuid"]] !=
                          null)
                    const PopupMenuDivider(),
                  if (mapLastSendDate.keys.contains(
                          mapBeneficiaire["gestes"][0]["geste_uuid"]) &&
                      mapLastSendDate[mapBeneficiaire["gestes"][0]
                              ["geste_uuid"]] !=
                          null)
                    const PopupMenuItem(
                      value: 5,
                      child: Text("Ré-intervention"),
                    ),
                ],
              )
            ]),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,

              separatorBuilder: (context, index) => const Divider(
                color: Colors.black,
              ),
              //
              //
              //
              // POUR CHAQUE GESTE
              //
              //
              //
              itemCount: mapBeneficiaire["gestes"].length,
              // Provide a builder function. This is where the magic happens.

              itemBuilder: (context, indexGeste) {
                final Map<String, dynamic> geste =
                    mapBeneficiaire["gestes"][indexGeste];

                if (!listGestesUuidForBackOfficeFeedback
                    .contains(geste["geste_uuid"])) {
                  listGestesUuidForBackOfficeFeedback.add(geste["geste_uuid"]);
                }
                bool canBeSend = true;
                for (var i = 0; i < geste["formulaires"].length; i++) {
                  Map<String, dynamic> mapFormulaire = geste["formulaires"][i];
                  if (mapFormulaire["nbGivenData"] !=
                      mapFormulaire["nbRequiredData"]) {
                    canBeSend = false;
                  }
                }
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(geste["geste_name"],
                          style: Theme.of(context).textTheme.bodyMedium),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          //
                          //
                          // POUR CHAQUE FORMULAIRE
                          //
                          //
                          //
                          itemCount: geste["formulaires"].length,
                          // Provide a builder function. This is where the magic happens.

                          itemBuilder: (context, indexFormulaire) {
                            final Map<String, dynamic> mapFormulaire =
                                getFormulaireOfGesteByOrder(
                                    geste, indexFormulaire);

                            return SizedBox(
                                height: 80,
                                child: Card(
                                    elevation: 8,
                                    shadowColor: Colors.red,
                                    child: ListTile(
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
                                                  formulaires: [],
                                                  geste_uuid:
                                                      jsonContent["geste"]
                                                          ["geste_uuid"],
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

                                              if (!mounted) return;

                                              setState(() {
                                                _dummy++;
                                              });
                                            },
                                            icon:
                                                (mapFormulaire["nbGivenData"] ==
                                                        mapFormulaire[
                                                            "nbRequiredData"])
                                                    ? const Icon(Icons.check)
                                                    : const Icon(
                                                        Icons.add_a_photo)),
                                        subtitle: Text(
                                            "${mapFormulaire["nbGivenData"]} / ${mapFormulaire["nbRequiredData"]} données"),
                                        title: Text(mapFormulaire[
                                            "formulaire_name"]))));
                          }),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (canBeSend)
                              FutureBuilder(
                                  future: getLastSendDate(
                                      geste), // il suffit de changer la valeur _dummy pour rafraichir cette liste :)
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data != null) {
                                        final f = new DateFormat(
                                            'dd/MM/yyyy à HH:mm', "fr");
                                        return Text(
                                            "envoyé le ${f.format(snapshot.data)}");
                                      } else {
                                        return EnvoyerButtonWidget(
                                            mapBeneficiaire, geste, context);
                                      }
                                    } else if (snapshot.hasError) {
                                      return const Text("error");
                                    } else {
                                      return EnvoyerButtonWidget(
                                          mapBeneficiaire, geste, context);
                                    }
                                  })
                            else
                              const Text("")
                          ])
                      /*,mapGestesUuidControleStatus.keys
                              .contains(geste["geste_uuid"])
                          ? Text(
                              "status : ${mapGestesUuidControleStatus[geste["geste_uuid"]]!} - ${mapGestesUuidControleCommentaire[geste["geste_uuid"]]!}")
                          : const Text('')*/
                    ]);
              },
            )
          ],
        ));
  }

  Future<DateTime?> getLastSendDate(Map<String, dynamic> geste) async {
    var x = await _storage.read(key: "send_${geste["geste_uuid"]}");
    mapLastSendDate[geste["geste_uuid"]] = x;
    if (x != null) {
      DateTime created_date_utc = DateTime.parse(x);
      return created_date_utc.toLocal();
    }
    return null;
  }

  Widget EnvoyerButtonWidget(Map<String, dynamic> mapBeneficiaire,
      Map<String, dynamic> geste, BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          print(mapBeneficiaire.toString());
          print(geste.toString());

          GesteApi gesteAPI = GesteApi(dioClient: dioClient);

          var response = await gesteAPI.sendGeste(
              beneficiaire_id: mapBeneficiaire["beneficiaire_id"],
              beneficiaire_name: mapBeneficiaire["beneficiaire_name"],
              geste_uuid: geste["geste_uuid"],
              geste_name: geste["geste_name"],
              gestes: mapBeneficiaire["gestes"]);
          if (response != null) {
            print(response.statusCode);
            if (response.statusCode == 201) {
              await _storage.write(
                  key: "send_${geste["geste_uuid"]}",
                  value: DateTime.now().toUtc().toString());
              const snackBar = SnackBar(
                content: Text('Formulaires envoyés !'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              setState(() {
                _dummy++;
              });
            }
          }
        },
        child: const Text("envoyer"));
  }

  Formulaire fromJSON(Map<String, dynamic> jsonContent) {
    List<Field> lf = [];
    for (var i = 0; i < jsonContent["fields"].length; i++) {
      List<Photo> lp = [];
      for (var j = 0; j < jsonContent["fields"][i]["photos"].length; j++) {
        Map<String, dynamic> ip = jsonContent["fields"][i]["photos"][j];

        String created_date_utc = DateTime.now().toUtc().toString();
        if (ip.keys.contains("created_date_utc")) {
          created_date_utc = ip["created_date_utc"];
        } else {
          // TODO : virer ce hack qui date du renommage de created_date en created_date_utc
          if (ip.keys.contains("created_date")) {
            created_date_utc = ip["created_date"];
          }
        }
        Photo p = Photo(
            photo_uuid: ip["photo_uuid"],
            path: ip["path"],
            status: ip["status"],
            location: Location(
                longitude: ip["location"]["longitude"],
                latitude: ip["location"]["latitude"]),
            created_date_utc: DateTime.parse(created_date_utc));
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

  Map<String, dynamic> getFormulaireOfGesteByOrder(
      Map<String, dynamic> geste, int indexFormulaire) {
    Map<int, String> ordersForms = Formulaire.getFormsOrder();
    String s = (ordersForms[indexFormulaire].toString());
    print(s);
    List l = geste["formulaires"];

    for (var i = 0; i < l.length; i++) {
      Map<String, dynamic> f = l[i];
      if (f["formulaire_name"] == s) {
        return f;
      }
    }

    return {};
  }
}
