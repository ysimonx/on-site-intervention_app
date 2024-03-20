// ignore_for_file: unused_import

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

  late String _title = 'champs personnalisés';

  @override
  void initState() {
    super.initState();

    dictCustomFields = {};

    _title = "champs personnalisés";
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
                          title: Text(
                              '${customField.code} - ${customField.label}'),
                          trailing: FittedBox(
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                          onNewValue: (
                                              {required CustomField
                                                  customField}) {
                                            setState(() {
                                              dictCustomFields[index] =
                                                  customField;
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
    required Null Function({required CustomField customField}) onNewValue,
  }) {
    late TextEditingController controllerCustomFieldCodeName =
        TextEditingController();
    late TextEditingController controllerCustomFieldName =
        TextEditingController();

    if (customfieldname != null) {
      controllerCustomFieldName.text = customfieldname;
    }
    if (customfieldcodename != null) {
      controllerCustomFieldCodeName.text = customfieldcodename;
    }

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
                controllerCustomFieldName.text = v.toLowerCase();
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
                controllerCustomFieldCodeName.text = v.toLowerCase();
              },
              controller: controllerCustomFieldCodeName,
              autofocus: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  hintText: "Entrez le code 'csv' du champ personnalisé"
                      .toCapitalized()),
            )
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
                    label: controllerCustomFieldName.text.toLowerCase());

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
    /*
    try {
      Response response = await siteApi.updateSiteLists(
          idSite: widget.site!.id, dictOfLists: dictOfLists);

      if (response.statusCode == 200) {
        Navigator.pop(context);

        callback(message: "Processing Data", dictOfLists: dictOfLists);
        return;
      }
      if (response.statusCode == 400) {
        callback(
            message: "Processing Data Error ${response.data["error"]}",
            dictOfLists: dictOfLists);
        return;
      }
    } catch (e) {
      callback(message: e.toString(), dictOfLists: dictOfLists);
    }*/
  }
}