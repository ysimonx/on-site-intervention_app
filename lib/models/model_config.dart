// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Config {
  late Map<String, dynamic> organizations_types_interventions;

  Config();

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['config_organization_type_intervention'] =
        jsonEncode(organizations_types_interventions);
    return data;
  }

  Config.fromJson(Map<String, dynamic> json)
      : organizations_types_interventions =
            json['config_organization_type_intervention'];
}
