import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_user.dart';

// ignore: must_be_immutable
class CardSettingsSectionSupervisor {
  late int phone;
  late String title;
  late String email;

  CardSettingsSection render(
      {required GlobalKey<FormState> key, required List<User> supervisors}) {
    List<String> listSupervisorString = [];
    // et pour l'site
    for (var i = 0; i < supervisors.length; i++) {
      User u = supervisors[i];

      listSupervisorString.add("${u.lastname.toUpperCase()}, ${u.firstname}");
    }
    return CardSettingsSection(
      header: CardSettingsHeader(
        label: 'Supervisor',
      ),
      children: <CardSettingsWidget>[
        CardSettingsListPicker(label: "Full Name", items: listSupervisorString),
      ],
    );
  }
}
