class ListForPlaces {
  String list_name;
  List<String> values;
  ListForPlaces({required this.list_name, required this.values});

  /*ListForPlaces.fromJson(Map<String, dynamic> json)
      : list_name = "nom",
        values = ["a", "b"];
        */

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list_name'] = this.list_name;
    data['values'] = this.values;
    return data;
  }
}

class ListsForPlaces {
  Map<int, ListForPlaces> mapLists;

  ListsForPlaces({required this.mapLists});

  static ListsForPlaces fromJSON(Map<String, dynamic> json) {
    Map<int, ListForPlaces> result = {};

    json.forEach((key, item) {
      List<dynamic> item_values = item["values"];

      List<String> values =
          (item_values as List).map((item) => item as String).toList();

      result[int.parse(key)] =
          ListForPlaces(list_name: item["list_name"], values: values);
    });
    ListsForPlaces lfp = ListsForPlaces(mapLists: result);
    return lfp;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = <String, dynamic>{};
    this.mapLists.forEach((order, lfp) {
      data[order.toString()] = lfp.toJSON();
    });
    return data;
  }
}
