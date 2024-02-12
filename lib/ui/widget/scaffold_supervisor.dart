// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

// ignore: must_be_immutable
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
      {required GlobalKey<FormState> key, required List<User> supervisors}) {
    List<String> listSupervisorString = [];
    // et pour l'site
    for (var i = 0; i < supervisors.length; i++) {
      User u = supervisors[i];

      listSupervisorString.add("${u.lastname.toUpperCase()}, ${u.firstname}");
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
          label: "Status",
          items: listStatuses,
          initialItem: listStatuses[1],
        ),
        CardSettingsListPicker(
          label: "Supervisor",
          items: listSupervisorString,
          initialItem:
              listSupervisorString.isNotEmpty ? listSupervisorString[0] : "",
        ),
      ],
    );
  }
}
