// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

const String localSubDirectoryFormulaires = 'formulaires';
const String localSubDirectoryBeneficiaires = 'beneficiaires';
const String localFilename = 'formulaire.json';
const String localListFilename = 'formulaires.json';

class FormulaireJSONFile {
  final String filename;

  FormulaireJSONFile({required this.filename});

  /// Initially check if there is already a local file.
  /// If not, create one with the contents of the initial json in assets
  Future<File> _initializeFile() async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    final String path =
        "${localDirectory.path}/${localSubDirectoryFormulaires}/${filename}";

    final file = File(path);

    // si le fichier existe, ok
    if (await file.exists()) {
      return file;
    }

    // est-ce que le repertoire existe ?
    final String pathDirectory =
        "${localDirectory.path}/${localSubDirectoryFormulaires}";
    final fileDirectory = Directory(pathDirectory);
    if (!await fileDirectory.exists()) {
      fileDirectory.createSync();
    }

    // allez, on créé ce fichier
    final file2 = File(path);
    await file2.create();

    return file2;
  }

  Future<String> readFile() async {
    final file = await _initializeFile();
    return await file.readAsString();
  }

  Future<void> writeToFile(String data) async {
    final file = await _initializeFile();
    await file.writeAsString(data);
  }

  void deleteAll() async {
    final Directory localDirectory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files =
        Directory("${localDirectory.path}/${localSubDirectoryFormulaires}")
            .listSync();

    for (var i = 0; i < files.length; i++) {
      var f = File(files[i].path);
      f.deleteSync();
      // pas de photo par defaut
    }

    return;
  }
}
