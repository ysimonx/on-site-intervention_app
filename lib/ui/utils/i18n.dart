String I18N(value) {
  String lang = "fr";

  Map<String, dynamic> trads = {
    "gestion des listes": {"en": "lists management"},
    "déconnexion": {"fr": "déconnexion", "en": "logout"},
    "annuler": {"en": "cancel"},
    "nouvelle intervention": {"en": "new request"},
    "veuillez choisir le type de chantier": {
      "en": "please choose the kind of request"
    }
  };

  if (trads.containsKey(value)) {
    Map<String, String> trad = trads[value];
    if (trad.containsKey(lang)) {
      return trad[lang] as String;
    }
  }

  return value;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
