import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CardSettingsSectionScaffold {
  late DateTime date1stutil;
  late int duration_days;

  CardSettingsSection render({required GlobalKey<FormState> key}) {
    return CardSettingsSection(
        header: CardSettingsHeader(
          label: 'Scaffold',
        ),
        children: <CardSettingsWidget>[
          CardSettingsDatePicker(
            dateFormat: DateFormat('dd/MM/yyyy'),
            label: '1st Util',
            initialValue: DateTime.now().add(const Duration(days: 15)),
            validator: (value) {
              if (value == null) return 'Date 1st Util is required.';
              return null;
            },
            onSaved: (value) => date1stutil = value!,
          ),
          CardSettingsInt(
            initialValue: 10,
            label: 'Duration (days)',
            validator: (value) {
              if (value == null) return 'Duration is required.';
              return null;
            },
            onSaved: (value) => duration_days = value!,
          ),
          CardSettingsListPicker(label: 'Action', items: const [
            "Montage échafaudage",
            "Modification échafaudage",
            "Montage échafaudage roulant",
            "Modification échafaudage roulant",
            "Montage protection collective",
            "Modification protection collective",
            "Autres structures",
            "Erecting Scaffolding for",
            "Modification Scaffolding for",
            "Erecting Mobile Scaffolding",
            "Modification Mobile scaffolding",
            "Erecting personal protection",
            "Modification personal protection",
            "Other Structure"
          ]),
          CardSettingsListPicker(label: 'Usage', items: const [
            "Acces sécurisé",
            "Travaux de peinture",
            "Travaux de métallurgie",
            "Travaux de montage tuyauterie",
            "Travaux d'isolation",
            "Travaux électrique",
            "Travaux de génie civil",
            "Travaux d'inspection",
            "Travaux d'instrumentation",
            "Access",
            "Blasting and Painting",
            "Busbar",
            "Cleaning",
            "Commissioning Test",
            "Installation Cables Tray or Cables ",
            "Insulation Pipe or Valve",
            "Lifting Point",
            "Mechanical Assembly",
            "Metrology",
            "Not concerned",
            "Opening back/in filling",
            "Passerelle",
            "Piping Installation",
            "Piping or Support",
            "Protection floor",
            "Safety",
            "Tarpaulin installation",
            "TSM Pipeline",
            "Valve Installation",
            "Visual Inspection",
            "Welding",
            "X-Ray"
          ]),
          CardSettingsListPicker(
              label: 'P mat',
              items: const ["< 100kg", "> 100kg", "not concerned"]),
          CardSettingsListPicker(
              label: '# workers on scaffold',
              initialItem: "1",
              items: const [
                "0",
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "8",
                "9",
                "10",
                "11",
                "12",
                "13",
                "14",
                "15",
                "16",
                "17",
                "18",
                "19",
                "20",
                "not concerned"
              ])
        ]);
  }
}
