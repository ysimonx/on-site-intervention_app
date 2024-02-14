// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_field.dart';
import '../../models/model_photo.dart';
import '../../network/api/image.api.dart';
import '../camera_page.dart';
import '../utils/logger.dart';

Widget widgetGallery(
    {required String initialValue,
    required BuildContext context,
    FormFieldValidator<String>? validator,
    required Directory directory,
    required Field field}) {
  /*
  List<String> listPictures = [
    "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20230306165933.jpg",
    "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20221204154542.jpg"
  ];
  */

  List<dynamic> listPictures = jsonDecode(initialValue);

  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Column(children: [
      IconButton(
        padding: EdgeInsets.zero,
        iconSize: 50,
        icon: const Icon(Icons.photo_camera),
        onPressed: () async {
          List<CameraDescription> camerasDescriptions =
              await availableCameras();

          if (!context.mounted) {
            return;
          }
          var pathImage = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return CameraPage(
                title: 'Prise de Photo', cameras: camerasDescriptions);
          }));

          if (pathImage == null) {
            return;
          }

          String photoOnSiteUUID = Photo.generateUUID();

          Directory d = await ImageApi.getPendingUploadImageAbsoluteDirectory();

          File imageFileSource = File(pathImage);

          String fileExtension = pathImage.split('.').last;
          String filename = "${photoOnSiteUUID}.${fileExtension}";
          String newAbsolutePathImage = "${d.path}/${filename}";
          await imageFileSource.copy(newAbsolutePathImage);

          listPictures.add(filename);

          logger.d(filename);
          // stocke un fichier json dédié
          // qui sera utilisé pour envoi d'image sur le serveur
          //

          ImageApi.addUploadPendingImage(
              filename: filename,
              photo_on_site_uuid: photoOnSiteUUID,
              field_on_site_uuid: field.field_on_site_uuid
              // field: Field(),
              // position: myLocation!,
              );

          validator!(jsonEncode(listPictures));

          setState(() {});
        },
      ),
      CarouselSlider.builder(
          itemCount: listPictures.length,
          options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              // height: 100,
              autoPlay: false,
              aspectRatio: 0.85,
              enlargeCenterPage: true,
              enableInfiniteScroll: false),
          itemBuilder: (ctx, photoIndex, realIdx) {
            return widgetGalleryItem(
                uriPicture: listPictures[photoIndex] as String,
                directory: directory);
          })
    ]);
  });
}

Widget widgetGalleryItem(
    {required String uriPicture, required Directory directory}) {
  if (!uriPicture.startsWith("/")) {
    uriPicture = "${directory.path}/${uriPicture}";
  }

  return Container(
    margin: const EdgeInsets.all(5.0),
    child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            GestureDetector(
                child: uriPicture.startsWith("http")
                    ? CachedNetworkImage(
                        imageUrl: uriPicture,
                        fit: BoxFit.cover,
                        width: 1000.0,
                        height: 1000.0)
                    : Image.file(File(uriPicture),
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fitWidth,
                        width: 1000.0,
                        height: 1000.0)),
            Positioned(
                top: 0.0,
                right: 0.0,
                child: GestureDetector(
                  onTap: () async {
                    //
                    // setState(() {});
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.black,
                          ))),
                )),
          ],
        )),
  );
}
