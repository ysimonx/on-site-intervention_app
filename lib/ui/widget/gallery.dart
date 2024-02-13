import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../camera_page.dart';
import '../utils/logger.dart';

Widget widgetGallery(
    {required String initialValue, required BuildContext context}) {
  /*
  List<String> listPictures = [
    "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20230306165933.jpg",
    "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20221204154542.jpg"
  ];
  */

  List<dynamic> listPictures = jsonDecode(initialValue);

  return Column(children: [
    IconButton(
      padding: EdgeInsets.zero,
      iconSize: 50,
      icon: const Icon(Icons.photo_camera),
      onPressed: () async {
        List<CameraDescription> camerasDescriptions = await availableCameras();

        if (!context.mounted) {
          return;
        }
        var result =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CameraPage(
              title: 'Prise de Photo', cameras: camerasDescriptions);
        }));

        logger.d(result);
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
              directory: Directory(""),
              uriPicture: listPictures[photoIndex] as String);
        })
  ]);
}

Widget widgetGalleryItem(
    {required String uriPicture, required Directory directory}) {
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
                    : Image.file(
                        File(Platform.isIOS
                            ? getImagePathiOS(directory, uriPicture)
                            : uriPicture),
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

String getImagePathiOS(Directory directory, String pathOrigin) {
  const String localSubDirectoryCameraPictures = 'camera/pictures';
  final String pathDirectory =
      "${directory.path}/$localSubDirectoryCameraPictures";

  var strParts = pathOrigin.split('pictures/');

  String path = "$pathDirectory/${strParts[1]}";
  return path;
}
