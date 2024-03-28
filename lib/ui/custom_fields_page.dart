// ignore_for_file: unused_import, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:diacritic/diacritic.dart';
import 'package:dio/dio.dart';
import 'package:flex_list/flex_list.dart';
import 'package:flutter/material.dart';
import 'package:on_site_intervention_app/models/model_formulaire.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/models/model_tenant.dart';

import '../models/model_custom_field.dart';
import '../models/model_user.dart';
import '../network/api/site_api.dart';
import '../network/api/user_api.dart';
import 'utils/i18n.dart';
import 'utils/logger.dart';
import 'widget/app_bar.dart';
import 'widget/common_widgets.dart';

class CustomFieldsPage extends StatefulWidget {
  final Site site;
  final User user;
  final Formulaire formulaire;
  final String type_intervention;

  const CustomFieldsPage(
      {super.key,
      required this.site,
      required this.user,
      required this.formulaire,
      required this.type_intervention});

  @override
  State<StatefulWidget> createState() {
    return CustomFieldsPageState();
  }
}

// Create a corresponding State class.
class CustomFieldsPageState extends State<CustomFieldsPage> {
  late Map<int, CustomField> dictCustomFields = {};

  late Map<String, dynamic> mapCustomFieldsSite = {};

  late String _title = 'champs personnalisés';

  @override
  void initState() {
    super.initState();

    dictCustomFields = {};

    _title = "champs personnalisés";

    mapCustomFieldsSite = widget.site.dictOfCustomFields;
    if (mapCustomFieldsSite.containsKey(widget.type_intervention)) {
      Map<String, dynamic> confCustomFields =
          mapCustomFieldsSite[widget.type_intervention];
      if (confCustomFields.containsKey("forms")) {
        Map<String, dynamic> confCustomFieldsForms = confCustomFields["forms"];
        if (confCustomFieldsForms
            .containsKey(widget.formulaire.form_on_site_uuid)) {
          Map<String, dynamic> conf =
              confCustomFieldsForms[widget.formulaire.form_on_site_uuid];
          if (conf.containsKey("custom_fields")) {
            conf["custom_fields"].forEach((key, value) {
              dictCustomFields[int.parse(key)] = CustomField.fromJson(value);
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widgetAppBar(widget.user),
        body: ListTileTheme(
            contentPadding: const EdgeInsets.all(15),
            style: ListTileStyle.list,
            dense: true,
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: dictCustomFields.length,
                itemBuilder: (BuildContext context, int index) {
                  CustomField customField = dictCustomFields[index]!;

                  return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                          leading: const Icon(Icons.list),
                          // ignore: unnecessary_string_interpolations
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 80.0, child: Text('Libellé: ')),
                                  Text(customField.label),
                                ],
                              ),
                              Row(children: [
                                const SizedBox(
                                    width: 80.0, child: Text('Code: ')),
                                Text(customField.code)
                              ])
                            ],
                          ),
                          trailing: FittedBox(
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  iconSize: 40.0,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    removeFromList(index: index);
                                    saveCustomFields();
                                    setState(() {});
                                  }),
                              const SizedBox(width: 40.0),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    iconSize: 40.0,
                                    icon: const Icon(Icons.settings),
                                    onPressed: () {
                                      _showDialog(
                                          site: widget.site,
                                          customfieldname: customField.label,
                                          customfieldcodename: customField.code,
                                          customfieldvalues:
                                              customField.autocomplete_values,
                                          onNewValue: (
                                              {required CustomField
                                                  customField}) {
                                            setState(() {
                                              dictCustomFields[index] =
                                                  customField;
                                              saveCustomFields();
                                            });
                                          });
                                    },
                                  )
                                ],
                              ),
                            ],
                          ))));
                })),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              _showDialog(
                  site: widget.site,
                  customfieldname: null,
                  customfieldcodename: null,
                  customfieldvalues: [],
                  onNewValue: ({required CustomField customField}) {
                    setState(() {
                      int size = dictCustomFields.length;
                      dictCustomFields[size] = customField;
                      saveCustomFields();
                    });
                  });
            }));
  }

  PreferredSize widgetAppBar(User? me) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: (me != null && me.isAuthorized())
            ? AuthentifiedBaseAppBar(
                title: _title, user: me, onCallback: (value) => setState(() {}))
            : const BaseAppBar(title: "login"));
  }

  void _showDialog({
    required Site site,
    required String? customfieldname,
    required String? customfieldcodename,
    required List<dynamic> customfieldvalues,
    required Null Function({required CustomField customField}) onNewValue,
  }) {
    late TextEditingController controllerCustomFieldCodeName =
        TextEditingController();
    late TextEditingController controllerCustomFieldName =
        TextEditingController();
    late TextEditingController controllerValues = TextEditingController();

    if (customfieldname != null) {
      controllerCustomFieldName.text = customfieldname;
    }
    if (customfieldcodename != null) {
      controllerCustomFieldCodeName.text = customfieldcodename;
    }

    controllerValues.text = customfieldvalues.join("\n");

    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(translateI18N("nouveau champ personnalisé").toTitleCase()),
          content: Column(children: [
            TextField(
              onChanged: (v) {
                controllerCustomFieldName.value = TextEditingValue(
                    text: v.toLowerCase(),
                    selection: controllerCustomFieldName.selection);
              },
              controller: controllerCustomFieldName,
              autofocus: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  hintText: "Entrez le libellé du champ personnalisé"
                      .toCapitalized()),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) {
                String new_value = v;
                new_value = new_value.toLowerCase();
                new_value = new_value.replaceAll(" ", "-");
                controllerCustomFieldCodeName.value = TextEditingValue(
                    text: new_value,
                    selection: controllerCustomFieldCodeName.selection);
              },
              controller: controllerCustomFieldCodeName,
              autofocus: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  hintText: "Entrez le code 'csv' du champ personnalisé"
                      .toCapitalized()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controllerValues,
              autofocus: false,
              autocorrect: false,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1),
                ),
              ),
            ),
          ]),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(translateI18N("annuler").toTitleCase()),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () async {
                CustomField customField = CustomField(
                    code: controllerCustomFieldCodeName.text.toLowerCase(),
                    label: controllerCustomFieldName.text.toLowerCase(),
                    autocomplete_values: controllerValues.text.split("\n"));

                onNewValue(customField: customField);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void saveCustomFields() async {
    SiteApi siteApi = SiteApi();

    try {
      Response response = await siteApi.updateCustomFields(
          idSite: widget.site.id,
          formulaire: widget.formulaire,
          dictOfCustomFields: dictCustomFields,
          type_intervention: widget.type_intervention);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(milliseconds: 100),
              content: Text("Processing Data")),
        );
      }
      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              duration: const Duration(milliseconds: 1000),
              content: Text("Processing Data Error ${response.data["error"]}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text("Processing Data Error ${e.toString()}")),
      );
    }
  }

  void removeFromList({required int index}) {
    logger.i("$index");
    dictCustomFields.remove(index);
    fixOrderOfList();
  }

  void fixOrderOfList() {
    List<int> keys = dictCustomFields.keys.toList();
    keys.sort();
    Map<int, CustomField> newmapLists = {};

    int j = 0;
    keys.forEach((element) {
      newmapLists[j] = dictCustomFields[element] as CustomField;
      j++;
    });
    dictCustomFields = newmapLists;
  }
}
