import 'package:flutter/material.dart';

Widget widgetWaiting() {
  return const Center(
      child: SizedBox(
    width: 60,
    height: 60,
    child: CircularProgressIndicator(),
  ));
}

Widget widgetError() {
  return const Text("error");
}
