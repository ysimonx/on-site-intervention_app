import '../ui/utils/uuid.dart';
import 'model_section.dart';

class Formulaire {
  String form_on_site_uuid;
  String form_name;
  Map<String, Section> sections = {};

  Formulaire({required this.form_on_site_uuid, required this.form_name});

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['form_on_site_uuid'] = form_on_site_uuid;
    data['form_name'] = form_name;

    return data;
  }

  Formulaire.fromJson(Map<String, dynamic> json)
      : form_on_site_uuid = json.containsKey('form_on_site_uuid')
            ? json['form_on_site_uuid']
            : generateUUID(),
        form_name = json['form_name'] as String;
}
