// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

import '../utils/i18n.dart';

class CardSettingsSectionHeader {
  late int phone;
  late String title;
  late String email;

  List<String> listStatuses = [
    "initiated",
    "assigned",
    "chrono",
    "commissionned",
    "canceled"
  ];

  CardSettingsSection render(
      {required GlobalKey<FormState> key, required List<User> coordinators}) {
    List<String> listCoordinatorString = [];
    // et pour l'site
    for (var i = 0; i < coordinators.length; i++) {
      User u = coordinators[i];

      listCoordinatorString.add("${u.lastname.toUpperCase()}, ${u.firstname}");
    }
    return CardSettingsSection(
      /* header: CardSettingsHeader(
        child: Container(
          height: 80,
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.white10, thickness: 5)),
              Text('Global', style: TextStyle(fontSize: 20)),
              Expanded(child: Divider(color: Colors.white10, thickness: 5)),
            ],
          ),
        ),
      ),*/
      children: <CardSettingsWidget>[
        CardSettingsListPicker(
          label: translateI18N("status").toCapitalized(),
          items: listStatuses,
          initialItem: listStatuses[1],
        ),
        CardSettingsListPicker(
          label: translateI18N("assigné à").toCapitalized(),
          items: listCoordinatorString,
          initialItem:
              listCoordinatorString.isNotEmpty ? listCoordinatorString[0] : "",
        ),
      ],
    );
  }
}
