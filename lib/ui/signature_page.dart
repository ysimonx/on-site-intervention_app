// ignore_for_file: unused_import

import 'dart:developer';
import 'dart:typed_data';
import 'package:xml/xml.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  // initialize the signature controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarPNG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pop(data);

    /*
    await push(
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('PNG Image'),
        ),
        body: Center(
          child: Container(
            color: Colors.grey[300],
            child: Image.memory(data),
          ),
        ),
      ),
    );
    */
  }

  Future<void> exportSVG(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarSVG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final String stringSVG = _controller.toRawSVG()!;
    if (!mounted) return;

    final String stringSVGReduced =
        optimiseSVG(stringSVG, float2int: true, minDistanceBetweenPoints: 3);
    /* await push(
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('SVG Image'),
        ),
        body: Center(
          child: Container(
            color: Colors.grey[300],
            child: data,
          ),
        ),
      ),
    );
    */

    Navigator.of(context).pop(stringSVGReduced);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //SIGNATURE CANVAS
          Signature(
            key: const Key('signature'),
            controller: _controller,
            height: 300,
            backgroundColor: Colors.grey[300]!,
          ),
          //OK AND CLEAR BUTTONS
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE

              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.undo());
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.redo());
                },
                tooltip: 'Redo',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.clear());
                },
                tooltip: 'Clear',
              ),

              /* STOP Edit
              IconButton(
                key: const Key('stop'),
                icon: Icon(
                  _controller.disabled ? Icons.pause : Icons.play_arrow,
                ),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.disabled = !_controller.disabled);
                },
                tooltip: _controller.disabled ? 'Pause' : 'Play',
              ),*/
              IconButton(
                key: const Key('exportPNG'),
                icon: const Icon(Icons.save),
                color: Colors.blue,
                onPressed: () => exportSVG(context),
                tooltip: 'Export Image',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String optimiseSVG(String stringSVG,
      {bool float2int = false, int minDistanceBetweenPoints = 0}) {
    final document = XmlDocument.parse(stringSVG);
    var svgroot = document.root;

    for (XmlElement child in svgroot.childElements) {
      if (child.localName == "svg") {
        for (XmlElement childsvg in child.childElements) {
          if (childsvg.localName == "polyline") {
            List attrs = childsvg.attributes;
            for (XmlAttribute attr in attrs) {
              if (attr.localName == "points") {
                String value = attr.value;
                List<String> points = value.split(" ");
                List<String> filteredPoints = [];
                dynamic xPrec = -1;
                dynamic yPrec = -1;

                for (String point in points) {
                  List<String> xy = point.split(",");
                  double doublex = double.parse(xy[0]);
                  double doubley = double.parse(xy[1]);
                  dynamic x;
                  dynamic y;
                  if (float2int) {
                    x = doublex.round();
                    y = doubley.round();
                  } else {
                    x = doublex;
                    y = doubley;
                  }
                  if ((x - xPrec).abs() > minDistanceBetweenPoints ||
                      (y - yPrec).abs() > minDistanceBetweenPoints) {
                    String s = "$x,$y";
                    filteredPoints.add(s);
                    xPrec = x;
                    yPrec = y;
                  }
                }
                childsvg.setAttribute("points", filteredPoints.join(" "));
              }
            }
          }
        }
      }
    }
    return document.toString();
  }
}
