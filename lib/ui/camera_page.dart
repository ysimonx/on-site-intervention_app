import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

import 'utils/logger.dart';

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
  late bool visor = false;

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

      XFile picturef = await _cameraController.takePicture();

      if (visor) {
        ui.Image image = await loadUiImage(picturef.path);
        int imageWidth = image.width;
        int imageHeight = image.height;

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
            recorder,
            Rect.fromPoints(const Offset(0.0, 0.0),
                Offset(imageWidth.toDouble(), imageHeight.toDouble())));

        canvas.drawImage(image, const Offset(0.0, 0.0), Paint());
        final paint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0;

        canvas.drawCircle(
            Offset(
              imageWidth * 0.5,
              imageHeight * 0.5,
            ),
            imageWidth * 0.1,
            paint);

        final picture = recorder.endRecording();
        final ui.Image img = await picture.toImage(imageWidth, imageHeight);

        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        final bytes = data!.buffer.asUint8List();

        final appDir = await syspaths.getTemporaryDirectory();
        final filepathpng = "${appDir.path}/save.png";
        await File(filepathpng).writeAsBytes(bytes);

        // var imagepng = decodeImage(File(filepathpng).readAsBytesSync())!;
        // File(filepathjpg).writeAsBytesSync(encodeJpg(imagepng));

        // ignore: use_build_context_synchronously
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return ImagePage(filepath: filepathpng);
        // })).then((value) {});
        Navigator.of(context).pop(filepathpng);

        // on passe la balayette
        try {
          File(picturef.path).delete();
        } catch (e) {
          logger.e(e.toString());
        }

        return null;
      }

      Navigator.of(context).pop(picturef.path);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    } catch (e) {
      debugPrint('Error occured while taking picture: $e');
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: [
        (_cameraController.value.isInitialized)
            ? SizedBox(
                width: size.width,
                height: size.height,
                child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                        width: 100, // the actual width is not important here
                        child: CameraPreview(_cameraController, child:
                            LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) =>
                                onViewFinderTap(details, constraints),
                          );
                        })))))
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
        Positioned(top: sizeh * 0.85 - 150, left: 0, child: sliderZoom()),
        // Align(alignment: Alignment.topCenter, child: sliderZoom()),
        Align(
            alignment: Alignment.center,
            child: (visor == true)
                ? Icon(Icons.panorama_fish_eye_sharp, size: size.width * 0.2)
                : const Text("")),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              height: sizeh * 0.15, // 10% de la hauteur pour le bas de l'écran
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
                      child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Switch(
                        // This bool value toggles the switch.
                        value: visor,
                        activeColor: Colors.yellow,
                        onChanged: (bool value) async {
                          setState(() {
                            visor = value;
                          });
                        },
                      ),
                      const Icon(Icons.my_location, color: Colors.white)
                    ])
                  ])),
                ]),
              ]),
            ))
      ]),
    );
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

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

Future<ui.Image> loadUiImage(String filepath) async {
  final File file = File(filepath);
  Uint8List bytes = file.readAsBytesSync();
  var data = bytes.buffer;

  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.view(data), (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}
