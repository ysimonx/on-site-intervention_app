// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/model_field.dart';
import '../../models/model_photo.dart';
import '../../network/api/image.api.dart';
import '../camera_page.dart';
import '../signature_page.dart';
import '../utils/logger.dart';

class widgetSignature extends StatefulWidget {
  final String initialValue;
  final FormFieldValidator<String>? validator;
  final Field field;
  final BuildContext context;

  const widgetSignature(
      {super.key,
      required this.initialValue,
      required this.context,
      required this.validator,
      required this.field});

  @override
  State<widgetSignature> createState() => _widgetSignatureState();
}

class _widgetSignatureState extends State<widgetSignature> {
  late String stringSVG;

  @override
  void initState() {
    super.initState();
    stringSVG = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    SvgPicture? svpP = null;
    try {
      svpP = SvgPicture.string(stringSVG);
    } catch (e) {
      print("error");
    }
    return Column(children: [
      IconButton(
        padding: EdgeInsets.zero,
        iconSize: 50,
        icon: const Icon(Icons.question_answer),
        onPressed: () async {
          if (context.mounted) {
            var stringReturnSVG = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return SignaturePage();
            }));

            if (stringReturnSVG == null) {
              return;
            }
            stringSVG = stringReturnSVG;
            widget.validator!(stringReturnSVG);
            setState(() {});
          }
        },
      ),
      (svpP != null) ? svpP : Text("no picture")
    ]);
  }
}


/*
Widget widgetSignature(
    {required String initialValue,
    required BuildContext context,
    FormFieldValidator<String>? validator,
    required Field field}) {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    SvgPicture? svpP = null;
    try {
      svpP = SvgPicture.string(initialValue);
    } catch (e) {
      print("error");
    }
    return Column(children: [
      IconButton(
        padding: EdgeInsets.zero,
        iconSize: 50,
        icon: const Icon(Icons.question_answer),
        onPressed: () async {
          if (context.mounted) {
            var stringSVG = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return SignaturePage();
            }));

            if (stringSVG == null) {
              return;
            }
            initialValue = stringSVG;

            validator!(stringSVG);

            setState(() {});
          }
        },
      ),
      (svpP != null) ? svpP : Text("no picture")
    ]);
  });
}
*/
