/*

List<CameraDescription> camerasDescriptions = await availableCameras();
CameraPage(
              title: 'Prise de Photo',
              cameras: camerasDescriptions)



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
  
*/

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String title;
  // final Field field;

  const CameraPage({
    super.key,
    required this.title,
    required this.cameras,
  });

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

      Navigator.of(context).pop(picture.path);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
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
    final CameraController cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
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
        Positioned(top: sizeh * 0.75 - 150, left: 0, child: sliderZoom()),
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
                    child: const Text("instructions",
                        style: TextStyle(fontSize: 10, color: Colors.white))),
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
                        const Icon(Icons.flash_on, color: Colors.white)
                      ])),
                ]),
                Expanded(
                    child: Column(children: [
                  const SizedBox(height: 0),
                  Expanded(
                      child: Image.network(
                          "https://static-or00.inbenta.com/2285b3e873772835772543d5c2df2aed0394a0cfb9a47a4ec1416c77a7363c2a/comment-savoir-si-ma-pompe-a-chaleur-atlantic-est-reversible-2.png")),
                ])),
              ]),
            ))
      ]),
    ));
  }

  Widget sliderZoom() {
    return SizedBox(
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
                  '${_currentZoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white),
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
