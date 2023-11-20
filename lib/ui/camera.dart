// ignore_for_file: unused_import

import 'package:app_renovadmin/models/models.dart';
import 'package:app_renovadmin/network/api/image_api.dart';
import 'package:app_renovadmin/ui/login.dart';
import 'package:app_renovadmin/ui/widget/app_bar.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String title;
  final Field field;

  const CameraPage(
      {super.key,
      required this.title,
      required this.cameras,
      required this.field});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late CameraController _cameraController;

  double _minAvailableZoom = 1.0;

  double _maxAvailableZoom = 1.0;

  double _currentZoomLevel = 1.0;

  late FlashMode? _currentFlashMode;
  late bool light = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      // await _cameraController.setFlashMode(FlashMode.always);

      if (light) {
        await _cameraController.setFlashMode(FlashMode.always);
      } else {
        await _cameraController.setFlashMode(FlashMode.off);
      }

      XFile picture = await _cameraController.takePicture();
      // TODO
      // je devrais faire un copyCrop ici pour ne garder que la partie haute de l'image
      // cf : https://github.com/brendan-duncan/image/blob/main/doc/transform.md
      // print(picture.path);
      // ignore: use_build_context_synchronously

      Navigator.of(context).pop(picture.path);

      /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
                  */
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.high,
        enableAudio: false);
    try {
      await _cameraController.initialize().then((_) {
        _cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value);

        _cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value);

        _currentFlashMode = _cameraController.value.flashMode;
        light = false;
        if (_currentFlashMode == FlashMode.always) {
          light = true;
        }
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  // #docregion AppLifecycle
  // TO DO : à tester !!!! (doit permettre de reprendre la caméra, en cas de veille ou de verrou du telephone ...)
  // cf https://pub.dev/packages/camera/example
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    final sizeh = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        (_cameraController.value.isInitialized)
            ? CameraPreview(_cameraController, child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => onViewFinderTap(details, constraints),
                );
              }))
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
        Positioned(child: sliderZoom(), top: sizeh * 0.75 - 150, left: 0),
        // Align(alignment: Alignment.topCenter, child: sliderZoom()),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              height: sizeh *
                  0.25, // 1/4 de la hauteur pour le bas de l'écran = 3/4 de la hauteur de l'écran pour la photo
              decoration: const BoxDecoration(
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child: Column(children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 0.0),
                    child: Text(widget.field.getInstruction(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white))),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(
                      child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 30,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                  )),
                  Expanded(
                      child: IconButton(
                    onPressed: takePicture,
                    iconSize: 50,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.circle, color: Colors.white),
                  )),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Switch(
                          // This bool value toggles the switch.
                          value: light,
                          activeColor: Colors.yellow,
                          onChanged: (bool value) async {
                            setState(() {
                              light = value;
                            });
                          },
                        ),
                        Icon(Icons.flash_on, color: Colors.white)
                      ])),
                ]),
                Expanded(
                    child: Column(children: [
                  const SizedBox(height: 0),
                  Expanded(
                      child: /* Image.network(
                          "https://static-or00.inbenta.com/2285b3e873772835772543d5c2df2aed0394a0cfb9a47a4ec1416c77a7363c2a/comment-savoir-si-ma-pompe-a-chaleur-atlantic-est-reversible-2.png")*/
                          Image.asset(widget.field.getExemple())),
                ])),
                widget.field.getRequirements().isNotEmpty
                    ? Column(children: [
                        const Text("Eléments devant être visibles :",
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                        (widget.field.getRequirements().length > 1)
                            ? CarouselSlider.builder(
                                itemCount:
                                    widget.field.getRequirements().length,
                                options: CarouselOptions(
                                    height: 30,
                                    autoPlay: true,
                                    aspectRatio: 16 / 9,
                                    enlargeCenterPage: false,
                                    autoPlayInterval:
                                        const Duration(seconds: 2),
                                    enableInfiniteScroll: true),
                                itemBuilder: (ctx, photoIndex, realIdx) {
                                  return Text(
                                      widget.field
                                          .getRequirements()[photoIndex],
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white));
                                })
                            : Text(widget.field.getRequirements()[0],
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                      ])
                    : const Text("")
              ]),
            ))
      ]),
    ));
  }

  Widget sliderZoom() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width * 0.95,
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _currentZoomLevel,
                min: _minAvailableZoom,
                max: _maxAvailableZoom,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentZoomLevel = value;
                  });
                  await _cameraController.setZoomLevel(value);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _currentZoomLevel.toStringAsFixed(1) + 'x',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController.setExposurePoint(offset);
    _cameraController.setFocusPoint(offset);
  }
}
