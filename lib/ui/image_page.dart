import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePage extends StatefulWidget {
  final String filepath;
  const ImagePage({super.key, required this.filepath});

  @override
  State<StatefulWidget> createState() {
    return ImagePageState();
  }
}

// Create a corresponding State class.
class ImagePageState extends State<ImagePage> {
  late File f;
  @override
  void initState() {
    super.initState();
  }

  Future<List> getMyInformations() async {
    try {
      f = File(widget.filepath);

      final image = img.decodeImage(File(widget.filepath).readAsBytesSync())!;
      print(image.toString());
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return widgetBody();
          } else if (snapshot.hasError) {
            return widgetError();
          } else {
            return widgetWaiting();
          }
        });
  }

  Scaffold widgetWaiting() {
    return Scaffold(
        body: const Center(
            child: SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(),
    )));
  }

  Scaffold widgetError() {
    return Scaffold(body: const Text("error"));
  }

  Widget widgetBody() {
    return Scaffold(
      body: Expanded(child: Image.file(f)),
    );
  }
}
