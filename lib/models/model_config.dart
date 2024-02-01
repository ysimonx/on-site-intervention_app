// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Config {
  late Map<String, dynamic> config_types_intervention;

  Config();

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['config_types_intervention'] = jsonEncode(config_types_intervention);
    return data;
  }

  Config.fromJson(Map<String, dynamic> json)
      : config_types_intervention = json['config_types_intervention'];
}
