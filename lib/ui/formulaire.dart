// ignore_for_file: unnecessary_string_interpolations, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:io';

import '../models/models.dart';
import '../network/api/image_api.dart';
import 'camera.dart';
import 'widget/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FormulairePage extends StatefulWidget {
  final Formulaire formulaire;

  const FormulairePage({
    super.key,
    required this.title,
    required this.beneficiaire,
    required this.formulaire,
    required this.geste,
  });

  final String title;
  final Beneficiaire beneficiaire;
  final Geste geste;

  @override
  State<FormulairePage> createState() => _FormulairePage();
}

class _FormulairePage extends State<FormulairePage> {
  double pourcentageCompleted = 0.0;

  late Position? myLocation;
  late Timer timerVerifs;

  @override
  // ignore: must_call_super
  initState() {
    print("initState Called");
    print(widget.formulaire.formulaire_name);

    Future.delayed(const Duration(seconds: 1), () async {
      myLocation = (await Geolocator.getLastKnownPosition());
    });

    timerVerifs = Timer.periodic(const Duration(seconds: 30), (timer) async {
      print("timerVerifs start");

      myLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("timerVerifs end");
    });
  }

  @override
  void dispose() {
    timerVerifs.cancel();

    widget.formulaire.save(widget.geste, widget.beneficiaire);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int nbGivenData = 0;
    for (var i = 0; i < widget.formulaire.fields.length; i++) {
      Field field = widget.formulaire.fields[i];
      if (field.noPhoto || field.photos.isNotEmpty) {
        nbGivenData++;
      }
    }

    pourcentageCompleted = nbGivenData / widget.formulaire.fields.length;

    return Scaffold(
        floatingActionButton: (pourcentageCompleted < 0.0)
            ? FloatingActionButton(
                tooltip: 'en attente',
                onPressed: () {},
                child: const Icon(Icons.pending),
              )
            : FloatingActionButton(
                tooltip: 'Sauvegarder',
                onPressed: () async {
                  await widget.formulaire
                      .save(widget.geste, widget.beneficiaire);
                  const snackBar = SnackBar(
                    content: Text('données de formulaire sauvegardées'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  setState(() {});
                },
                child: const Icon(Icons.save),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          height: 60,
          color: Colors.blue,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: <Widget>[
                /*IconButton(
                  tooltip: 'Enregistrer',
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    await widget.formulaire
                        .save(widget.geste, widget.beneficiaire);
                  },
                ),*/
                /*IconButton(
                  tooltip: 'Partager',
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),*/

                LinearPercentIndicator(
                    width: 100,
                    lineHeight: 20.0,
                    percent: pourcentageCompleted,
                    center: Text("${(pourcentageCompleted * 100).round()} %"),
                    progressColor: Colors.green,
                    backgroundColor: Colors.white),

                /* IconButton(
              tooltip: 'Favorite',
              icon: const Icon(Icons.favorite),
              onPressed: () {},
            ),*/
              ],
            ),
          ),
        ),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: BaseAppBar(widget.formulaire.formulaire_name)),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Bénéficiaire : ${widget.beneficiaire.beneficiaire_name}",
                            style: Theme.of(context).textTheme.bodyLarge),
                        Text("${widget.geste.geste_name}",
                            style: Theme.of(context).textTheme.bodyMedium),
                      ])),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.formulaire.fields.length,
                          itemBuilder: (context, fieldIndex) {
                            final controller = TextEditingController();
                            controller.text = widget
                                .formulaire.fields[fieldIndex].commentaire;

                            return Column(children: [
                              Container(
                                  padding: const EdgeInsets.all(10.0),
                                  color:
                                      const Color.fromARGB(255, 124, 209, 248),
                                  child: Row(children: [
                                    Flexible(
                                        child: Text(
                                            softWrap: true,
                                            "${fieldIndex + 1}/${widget.formulaire.fields.length} : ${widget.formulaire.fields[fieldIndex].getLabel()} ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge))
                                  ])),
                              (widget.formulaire.fields[fieldIndex].noPhoto ||
                                      widget.formulaire.fields[fieldIndex]
                                          .photos.isNotEmpty)
                                  ? const Text("")
                                  : IconButton(
                                      icon: const Icon(Icons.add_a_photo),
                                      iconSize: 40,
                                      onPressed: () async {
                                        await processIconCam(fieldIndex);
                                      }),
                              widget.formulaire.fields[fieldIndex].photos
                                      .isEmpty
                                  ? WidgetPhotosIsEmpty(fieldIndex)
                                  : Column(children: [
                                      CarouselSlider.builder(
                                          itemCount: widget.formulaire
                                              .fields[fieldIndex].photos.length,
                                          options: CarouselOptions(
                                              // height: 100,
                                              autoPlay: false,
                                              aspectRatio: 0.85,
                                              enlargeCenterPage: true,
                                              enableInfiniteScroll: false),
                                          itemBuilder:
                                              (ctx, photoIndex, realIdx) {
                                            return CarouselSliderItem(
                                                fieldIndex, photoIndex);
                                          }),
                                      Row(
                                        children: [
                                          IconButton(
                                              icon:
                                                  const Icon(Icons.add_a_photo),
                                              iconSize: 40,
                                              onPressed: () async {
                                                await processIconCam(
                                                    fieldIndex);
                                              }),
                                          const Text(
                                              "ajouter une photo\nsupplémentaire")
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      )
                                    ]),
                              widget.formulaire.fields[fieldIndex].photos
                                      .isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: Row(children: [
                                        Checkbox(
                                          checkColor: Colors.white,
                                          value: widget.formulaire
                                              .fields[fieldIndex].noPhoto,
                                          onChanged: (bool? value) async {
                                            widget.formulaire.fields[fieldIndex]
                                                .noPhoto = value!;
                                            await widget.formulaire.save(
                                                widget.geste,
                                                widget.beneficiaire);
                                            setState(() {});
                                          },
                                        ),
                                        const Text("photo non applicable")
                                      ]))
                                  : const Text(""),
                              (widget.formulaire.fields[fieldIndex].photos
                                          .isNotEmpty ||
                                      widget.formulaire.fields[fieldIndex]
                                          .noPhoto)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      child: TextField(
                                        controller: controller,
                                        onChanged: (value) {
                                          widget.formulaire.fields[fieldIndex]
                                              .commentaire = controller.text;
                                        },
                                        // controller: editingController,
                                        decoration: const InputDecoration(
                                            labelText: "Commentaire",
                                            hintText: "Commentaire"),
                                      ))
                                  : const Text(''),
                              const SizedBox(height: 40)
                            ]);
                          })))
            ]));
  }

  Widget WidgetPhotosIsEmpty(int fieldIndex) {
    Field field = widget.formulaire.fields[fieldIndex];
    List<String> requirements = field.getRequirements();
    String string_requirements = "";
    if (requirements.length > 0) {
      string_requirements =
          "Eléments devant être visibles:\n- ${requirements.join("\n- ")}";

      return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(20.0),
          child:
              //    return Column(children: [
              //  if (field.getInstruction() != field.getLabel())
              //    Text(field.getInstruction()),
              Text(string_requirements)
          //  Column(children: [Text(string_requirements)])
          // ]);
          );
    } else {
      return Text("");
    }
  }

  Future<void> processIconCam(fieldIndex) async {
    List<CameraDescription> camerasDescriptions = await availableCameras();

    if (myLocation == null) {
      const snackBar = SnackBar(
        content: Text('Geolocalisation impossible - pas de photo !'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }

    // ignore: use_build_context_synchronously
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraPage(
              title: 'Prise de Photo',
              field: widget.formulaire.fields[fieldIndex],
              cameras: camerasDescriptions)),
    );

    if (!mounted) return;

    if (result == null) return;

    // stocke un fichier json dédié
    // qui sera utilisé pour envoi d'image sur le serveur
    //
    String photo_id = Photo.generateUUID();

    ImageApi.addUploadPendingImage(result,
        photo_uuid: photo_id,
        field: widget.formulaire.fields[fieldIndex],
        geste: widget.geste,
        beneficiaire: widget.beneficiaire,
        position: myLocation!);

    // print(result);
    widget.formulaire.fields[fieldIndex].photos.insert(
        0,
        Photo(
            photo_uuid: photo_id,
            path: result,
            location: Location(
                longitude: myLocation!.longitude,
                latitude: myLocation!.latitude),
            created_date_utc: DateTime.now().toUtc()));
    await widget.formulaire.save(widget.geste, widget.beneficiaire);
    setState(() {});
  }

  Widget CarouselSliderItem(int fieldIndex, int photoIndex) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              GestureDetector(
                  onTap: () async {}, // Image tapped

                  child: widget
                          .formulaire.fields[fieldIndex].photos[photoIndex].path
                          .startsWith("http")
                      ? CachedNetworkImage(
                          imageUrl: widget.formulaire.fields[fieldIndex]
                              .photos[photoIndex].path,
                          fit: BoxFit.cover,
                          width: 1000.0,
                          height: 1000.0)
                      : Image.file(
                          File(widget.formulaire.fields[fieldIndex]
                              .photos[photoIndex].path),
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fitWidth,
                          width: 1000.0,
                          height: 1000.0)),
              /* Positioned(
                bottom: 0.0,
                right: 0.0,
                // right: 0.0,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 20.0),
                    child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(photoIndex < 2
                            ? Icons.check_circle_outline
                            : Icons.warning_outlined))),
              ),*/
              Positioned(
                  top: 0.0,
                  right: 0.0,
                  // right: 0.0,
                  child: GestureDetector(
                    onTap: () async {
                      widget.formulaire.fields[fieldIndex].photos
                          .removeAt(photoIndex);
                      await widget.formulaire
                          .save(widget.geste, widget.beneficiaire);
                      setState(() {});
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.delete))),
                  )),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                // right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Text(
                    '#${photoIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
