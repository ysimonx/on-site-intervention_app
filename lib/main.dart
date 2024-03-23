// ignore_for_file: unused_import

import 'ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/sites_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fidwork',
      debugShowCheckedModeBanner: false,

      // https://docs.flutter.dev/cookbook/design/themes#set-a-unique-themedata-instance
      // https://medium.flutterdevs.com/implement-dark-mode-in-flutter-using-provider-158925112bf9
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
