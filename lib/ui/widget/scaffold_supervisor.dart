import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CardSettingsSectionSupervisor {
  late int phone;
  late String title;
  late String email;

  CardSettingsSection render() {
    return CardSettingsSection(
      header: CardSettingsHeader(
        label: 'Supervisor',
      ),
      children: <CardSettingsWidget>[
        CardSettingsText(
          label: 'Name',
          initialValue: "Roberto Mignonne",
          validator: (value) {
            if (value == null || value.isEmpty) return 'Name is required.';
            return null;
          },
          onSaved: (value) => title = value!,
        ),
        CardSettingsPhone(
          label: 'Phone',
          initialValue: 0651556170,
          validator: (value) {
            if (value == null) return 'Phone is required.';
            return null;
          },
          onSaved: (value) => phone = value!,
        ),
        CardSettingsEmail(
          label: 'E-mail',
          initialValue: "roberto@iter.org",
          validator: (value) {
            // if (!value!.startsWith('http:'))
            //  return 'Must be a valid website.';
            return null;
          },
          onSaved: (value) => email = value!,
        ),
      ],
    );
  }
}
