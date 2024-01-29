String I18N(value) {
  String lang = "fr";

  Map<String, dynamic> trads = {
    "gestion des listes": {
      "fr": "gestion des listes",
      "en": "lists management"
    },
    "déconnexion": {"fr": "déconnexion", "en": "logout"}
  };

  if (trads.containsKey(value)) {
    return trads[value][lang];
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
