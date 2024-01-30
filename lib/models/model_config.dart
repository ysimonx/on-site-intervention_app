// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Config {
  late Map<String, dynamic> sites_types_interventions;

  Config();

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['config_site_type_intervention'] =
        jsonEncode(sites_types_interventions);
    return data;
  }

  Config.fromJson(Map<String, dynamic> json)
      : sites_types_interventions = json['config_site_type_intervention'];
}
