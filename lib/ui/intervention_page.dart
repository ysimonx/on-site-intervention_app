// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:card_settings/card_settings.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:on_site_intervention_app/models/model_site.dart';
import 'package:on_site_intervention_app/ui/utils/i18n.dart';
import 'package:on_site_intervention_app/ui/utils/mobilefirst.dart';
import 'package:on_site_intervention_app/ui/utils/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flex_list/flex_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/model_custom_field.dart';
import '../models/model_field.dart';
import '../models/model_formulaire.dart';
import '../models/model_intervention.dart';
import '../models/model_lists_for_places.dart';
import '../models/model_section.dart';
import '../models/model_user.dart';
import '../network/api/constants.dart';
import '../network/api/image.api.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'utils/tools.dart';
import 'widget/card_settings_autocompletetext.dart';
import 'widget/card_settings_listfromrole.dart';
import 'widget/card_settings_schema.dart';
import 'widget/card_settings_gallery.dart';
import 'widget/card_settings_float.dart';
import 'widget/card_settings_signature.dart';
import 'widget/choose_place.dart';
import 'widget/filter_list.dart';
import 'widget/widgetListInterventionSamePlace.dart';

// Create a Form widget.
class InterventionPage extends StatefulWidget {
  const InterventionPage(
      {super.key,
      required this.intervention,
      required this.site,
      required this.user});

  final Intervention intervention;
  final Site site;
  final User user;

  @override
  InterventionPageState createState() {
    return InterventionPageState();
  }
}

// Create a corresponding State class.
class InterventionPageState extends State<InterventionPage> {
  late List<GlobalKey<FormState>> _formsKey = [];
  late Map<String, Formulaire> mapFormulaires = {};
  late Map<String, dynamic> mapMandatoryLists = {};

  bool _needSave = false;

  late Formulaire currentFormulaire;
  int _indexFormulaires = 0;

  Map<String, TextEditingController> fieldsController = {};
  List<String> listFieldsUUIDUpdated = [];

  Map<String, dynamic> mapCustomFieldsValues = {};

  late Directory? deviceApplicationDocumentsDirectory;
  late Directory? directoryImageGallery;
  late Directory? directoryPendingUploadImageGallery;

  late String intervention_status;
  late User userCoordinator;
  late List<User> usersCoordinators;

  late Future<String> myFuture;

  // late Directory directory;

  @override
  void initState() {
    super.initState();

    intervention_status = widget.intervention.status;

    _initCoordinators();

    myFuture = Future<String>.delayed(
      const Duration(milliseconds: 100),
      () => getMyFuture(),
    );
  }

  void refreshUI() {
    setState(() {
      myFuture = Future<String>.delayed(
        const Duration(milliseconds: 100),
        () => doNothing(),
      );
    });
  }

  Future<String> doNothing() async {
    return "";
  }

  Future<String> getMyFuture() async {
    mapFormulaires = await UserApi.getInterventionFormsFromTemplate(
        user: widget.user,
        site_name: widget.site.name,
        type_intervention_name: widget.intervention.type_intervention_name);

    mapMandatoryLists = await UserApi.getMandatoryListFromTemplate(
        user: widget.user,
        type_intervention_name: widget.intervention.type_intervention_name);

    // Chargement des données initiales de chaque "Field"
    // dans des TextEditingController
    _formsKey = [];
    mapFormulaires.forEach((key, formulaire) {
      _formsKey.add(GlobalKey<FormState>());
      formulaire.sections.forEach((key, section) {
        section.fields.forEach((key, f) {
          if (fieldsController.containsKey(f.field_on_site_uuid)) {
          } else {
            fieldsController[f.field_on_site_uuid] = TextEditingController();
          }
          if (widget.intervention.field_on_site_uuid_values
              .containsKey(f.field_on_site_uuid)) {
            fieldsController[f.field_on_site_uuid]!.text = widget
                .intervention.field_on_site_uuid_values[f.field_on_site_uuid];
          } else {
            if (f.field_type == "integer") {
              fieldsController[f.field_on_site_uuid]!.text = "10";
            }
            if (f.field_type == "date") {
              fieldsController[f.field_on_site_uuid]!.text = "";
            }
          }
        });
      });
    });

    String s = (_indexFormulaires + 1).toString();
    currentFormulaire = mapFormulaires[s] as Formulaire;

    if (isOfflineFirst()) {
      deviceApplicationDocumentsDirectory =
          await getApplicationDocumentsDirectory();

      directoryImageGallery = Directory(
          "${deviceApplicationDocumentsDirectory!.path}/${ImageApi.getDownloadedImageRelativeDirectoryPath()}");

      directoryPendingUploadImageGallery = Directory(
          "${deviceApplicationDocumentsDirectory!.path}/${ImageApi.getPendingUploadImageRelativeDirectoryPath()}");
    } else {
      deviceApplicationDocumentsDirectory = null;
      directoryImageGallery = null;
      directoryPendingUploadImageGallery = null;
    }

    String interventionName = widget.intervention.BuildNumRegistre();
    widget.intervention.intervention_name = interventionName;

    mapCustomFieldsValues = widget.intervention.custom_fields_values;
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(widget.intervention.intervention_name),
                ),
                body: widgetMainBody(context),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: widgetFAB(context));
          }
          return const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          );
        });
  }

  Padding widgetFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FloatingActionButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            // if (_formKey.currentState!.validate()) {
            await _downloadFEB(context, onMessage: (String message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 1)),
              );
            });
            // }
          },
          tooltip: 'print FEB',
          child: const Icon(Icons.print),
        ),
        FloatingActionButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            // if (_formKey.currentState!.validate()) {
            await saveIntervention(context, onMessage: (String message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 1)),
              );
            });
            // }
          },
          tooltip: 'Save',
          child: const Icon(Icons.save),
        )
      ]),
    );
  }

  Widget widgetMainBody(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          // await saveIntervention(context);

          if (_needSave) {
            _showBackDialog();
          } else {
            Navigator.pop(context, widget.intervention);
          }
        },
        child: SingleChildScrollView(child: widgetBodyForm(context)));
  }

  void onChangedPlace(place) {
    widget.intervention.place = place;
    String newName = widget.intervention.BuildNumRegistre();
    widget.intervention.intervention_name = newName;
    _needSave = true;
    refreshUI();
  }

  Widget widgetBodyForm(BuildContext context) {
    Widget w = widgetBodyFormulaireNG(_indexFormulaires);
    // GestureRecognizerDetector gestureRecognizerDetector =
    //     GestureRecognizerDetector();
    // gestureRecognizerDetector.addGestureRecognizer(swipeGestureRecognizer);
    return Wrap(children: [
      Form(
          key: _formsKey[_indexFormulaires],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(children: [
                  ChoosePlaceWidget(
                      site: widget.site,
                      onChanged: onChangedPlace,
                      place: widget.intervention.place),
                  widgetNumChrono(),
                  widgetHeaderFormulaire(),
                ])),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 2), child: Text(' ')),
            widgetBodyTabsFormulaires(),
            w,
            const SizedBox(
              height: 600,
            ),
          ])),
    ]);
  }

  Widget widgetHeaderFormulaire() {
    List<dynamic> listStatuses = UserApi.getListStatusFromTemplate(
        user: widget.user,
        site: widget.site,
        type_intervention_name: widget.intervention.type_intervention_name);

    List<DropdownMenuItem<String>> listStatusDropdownMenuItems = [];
    List<DropdownMenuItem<User>> listDropdownMenuItemsUsers = [];

    for (var i = 0; i < listStatuses.length; i++) {
      String status = listStatuses[i];
      listStatusDropdownMenuItems
          .add(DropdownMenuItem(value: status, child: Text(status)));
    }

    for (var i = 0; i < usersCoordinators.length; i++) {
      User user = usersCoordinators[i];
      listDropdownMenuItemsUsers.add(
          DropdownMenuItem(value: user, child: genDrowdownUserContent(user)));
    }
    if (listStatuses.contains(intervention_status) == false) {
      intervention_status = listStatuses[0];
    }

    return FlexList(horizontalSpacing: 5, verticalSpacing: 10, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(Config.roleAssignee),
        DropdownButton<User>(
          value: userCoordinator,
          items: listDropdownMenuItemsUsers,
          onChanged: (value) {
            if (value is User) {
              setState(() {
                _needSave = true;
                widget.intervention.assignee_user_id = value.id;
                widget.intervention.assignee_user = value;
                userCoordinator = value;
              });
            }
          },
        )
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Status"),
          DropdownButton<String>(
              value: intervention_status,
              items: listStatusDropdownMenuItems,
              onChanged: dropdownStatusCallback)
        ])
      ]),
    ]);
  }

  Widget widgetBodyTabsFormulaires() {
    List<Tab> tabs = [];
    mapFormulaires.forEach((k, f) => tabs.add(Tab(child: Text(f.form_name))));
    return DefaultTabController(
        initialIndex: _indexFormulaires,
        length: mapFormulaires.length,
        child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            onTap: (selectedTabIndex) async {
              setState(() {
                _indexFormulaires = selectedTabIndex;
                String s = (_indexFormulaires + 1).toString();
                currentFormulaire = mapFormulaires[s] as Formulaire;
              });
            },
            tabs: tabs));
  }

  Future<void> saveIntervention(BuildContext context,
      {required Null Function(String message) onMessage}) async {
    // TODO : ici, on n'a QUE la liste des champs qui ont été modifiés en local

    // sauvegarde des valeurs textes des formulaires
    // widget.intervention.field_on_site_uuid_values = {};
    fieldsController.forEach((key, value) {
      widget.intervention.field_on_site_uuid_values[key] = value.text;
    });

    widget.intervention.custom_fields_values = mapCustomFieldsValues;

    try {
      onMessage('Processing Data');
    } catch (e) {}

    InterventionApi interventionApi = InterventionApi();

    if (isOfflineFirst()) {
      await interventionApi.localUpdatedFileSave(
          intervention: widget.intervention);
    }

    var r = await interventionApi
        .postInterventionValuesOnServer(widget.intervention);
    logger.d("saveIntervention, statusCode ${r?.statusCode}");

    _needSave = false;
  }

  void _showBackDialog() {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Etes vous sûr ?'),
          content: const Text(
            'Souhaitez vous quitter ce formulaire sans avoir sauvegardé vos modifications ?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Sauvegarder et quitter'),
              onPressed: () async {
                await saveIntervention(context, onMessage: (String message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Processing Data'),
                        duration: Duration(seconds: 1)),
                  );
                });
                Navigator.pop(context);
                Navigator.pop(context, widget.intervention);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Quitter sans sauvegarder'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget widgetBodyFormulaireNG(int initialIndex) {
    Map<String, Section> sections = currentFormulaire.sections;
    List<CardSettingsSection> listCardsSettingsSection = [];

    sections.forEach(
        (k, s) => listCardsSettingsSection.add(cardSettingsSection(s)));

    Map<String, dynamic> jsonCF = getCustomFields(
        type_intervention: widget.intervention.type_intervention_name,
        form_on_site_uuid: currentFormulaire.form_on_site_uuid);

    // if custom_fields was configured for this formulaire and for this type of intervention
    if (jsonCF.isNotEmpty) {
      CardSettingsSection css = cardSettingsSectionCustomFields(
          section: Section(
              section_on_site_uuid: generateUUID(),
              section_name: 'site',
              section_type: 'custom'),
          json_custom_fields: jsonCF);
      if (listCardsSettingsSection.isEmpty) {
        listCardsSettingsSection.add(css);
      } else {
        listCardsSettingsSection.insert(1, css);
      }
    }

    // todo ajouter section des custom fields

    return GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity is double) {
            if (details.primaryVelocity! > 0) {
              if (_indexFormulaires > 0) {
                setState(() {
                  _indexFormulaires--;
                  String s = (_indexFormulaires + 1).toString();
                  currentFormulaire = mapFormulaires[s] as Formulaire;
                });
              }
            } else if (details.primaryVelocity! < 0) {
              if (_indexFormulaires < mapFormulaires.length - 1) {
                setState(() {
                  _indexFormulaires++;
                  String s = (_indexFormulaires + 1).toString();
                  currentFormulaire = mapFormulaires[s] as Formulaire;
                });
              }
            }
          }
        },
        child: Form(
            child: Column(
          children: [
            CardSettings.sectioned(
              cardElevation: 20.0,
              cardless: false,
              labelWidth: 200.0,
              showMaterialonIOS: true, // default is false

              children: listCardsSettingsSection,
            ),
          ],
        )));
  }

  Map<String, dynamic> getCustomFields(
      {required String type_intervention, required String form_on_site_uuid}) {
    Map<String, dynamic> result = {};

    try {
      if (widget.site.dictOfCustomFields.containsKey(type_intervention)) {
        Map<String, dynamic> docfTypeIntervention =
            widget.site.dictOfCustomFields[type_intervention];
        if (docfTypeIntervention.containsKey("forms")) {
          Map<String, dynamic> dictCF = docfTypeIntervention["forms"];
          if (dictCF.keys.contains(form_on_site_uuid)) {
            result = dictCF[form_on_site_uuid]["custom_fields"];
          }
        }
      }
    } catch (e) {}
    return result;
  }

  CardSettingsSection cardSettingsSection(Section s) {
    List<CardSettingsWidget> lCardSettingsWidget = [];

    s.fields
        .forEach((key, f) => lCardSettingsWidget.add(fieldCardSettings(f, s)));

    return CardSettingsSection(
        header: CardSettingsHeader(
          label: s.section_name.toCapitalized(),
          /* child: Container(
                color: Colors.grey,
                child: Column(children: [
                  SizedBox(height: 100),
                  Row(children: [
                    Text(s.section_name, style: TextStyle(fontSize: 18))
                  ])
                ])),
                */
        ),
        children: lCardSettingsWidget);
  }

  CardSettingsSection cardSettingsSectionCustomFields(
      {required Section section,
      required Map<String, dynamic> json_custom_fields}) {
    List<CardSettingsWidget> lCardSettingsWidget = [];

    if (json_custom_fields.isNotEmpty) {
      json_custom_fields.forEach((key, value) {
        String testCF = "";

        CustomField cf = CustomField.fromJson(json_custom_fields[key]);
        if (mapCustomFieldsValues.keys.contains(cf.code)) {
          testCF = mapCustomFieldsValues[cf.code] as String;
        }
        lCardSettingsWidget.add(fieldCardSettingsCustomField(
            custom_field: cf, initialValue: testCF));
      });
    }
    return CardSettingsSection(
        header: CardSettingsHeader(
          label: section.section_name.toCapitalized(),
          /* child: Container(
                color: Colors.grey,
                child: Column(children: [
                  SizedBox(height: 100),
                  Row(children: [
                    Text(s.section_name, style: TextStyle(fontSize: 18))
                  ])
                ])),
                */
        ),
        children: lCardSettingsWidget);
  }

  CardSettingsWidget fieldCardSettingsCustomField(
      {required CustomField custom_field, required String initialValue}) {
    return genCardSettingsTextCustomField(
        custom_field: custom_field, initialValue: initialValue);
  }

  CardSettingsWidget fieldCardSettings(Field f, Section s) {
    String defaultInitialValue = "10";
    late String initialValue;

    if (fieldsController.containsKey(f.field_on_site_uuid)) {
      initialValue = fieldsController[f.field_on_site_uuid]!.text;
    } else {
      initialValue = defaultInitialValue;
    }

    if (f.field_type == "integer") {
      return genCardSettingsInt(initialValue, s, f);
    }

    if (f.field_type == "float") {
      return genCardSettingsFloat(initialValue, s, f);
    }

    if (f.field_type == "list_from_mandatory_lists") {
      List<dynamic> possible_values = [];

      if (f.field_possible_values.isNotEmpty) {
        String sList = f.field_possible_values[0];
        Map<String, dynamic> mapJsonList = mapMandatoryLists[sList];
        if (mapJsonList["type"] == "fixed") {
          possible_values = mapJsonList["values"];
        }
        if (mapJsonList["type"] == "administrable_by_site") {
          if (widget.site.dictOfLists.containsKey(sList)) {
            possible_values = widget.site.dictOfLists[sList];
          }
        }
        return genCardSettingsListPicker(initialValue, f,
            possible_values: possible_values);
      }
    }

    if (f.field_type == "list") {
      return genCardSettingsListPicker(initialValue, f,
          possible_values: f.field_possible_values);
    }

    if (f.field_type == "radio_button") {
      return genCardSettingsListRadioButton(initialValue, f,
          possible_values: f.field_possible_values);
    }

    if (f.field_type == "date") {
      return genCardSettingsDatePicker(initialValue, f);
    }

    if (f.field_type == "switch") {
      return genCardSettingsSwitch(initialValue, f);
    }

    if (f.field_type == "text") {
      return genCardSettingsText(initialValue, f);
    }

    if (f.field_type == "paragraph") {
      return genCardSettingsParagraph(initialValue, f);
    }

    if (f.field_type == "email") {
      return genCardSettingsEmail(initialValue, f);
    }

    if (f.field_type == "phone") {
      return genCardSettingsPhone(initialValue, f);
    }

    if (f.field_type == "user_from_role") {
      return genCardSettingsUserFromRole(initialValue, f);
    }

    if (f.field_type == "signature") {
      return genCardSettingsSignature(initialValue, f);
    }

    if (f.field_type == "schema") {
      return genCardSettingsSchema(initialValue, f);
    }

    if (f.field_type == "gallery") {
      /* List<String> listPictures = [
        "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20230306165933.jpg",
        "https://webapp.sandbox.fidwork.fr/api/request/images/picture_4398_visit_20221204154542.jpg"
      ]; */
      List<dynamic> listPictures = [];
      try {
        if (initialValue != "") {
          listPictures = jsonDecode(initialValue);
        }
      } catch (e) {
        logger.e(e.toString());
      }

      return genCardSettingsGallery(jsonEncode(listPictures), f,
          directory: directoryImageGallery,
          directoryPendingUpload: directoryPendingUploadImageGallery,
          intervention_values_on_site_uuid:
              widget.intervention.intervention_values_on_site_uuid);
    }

    return genCardSettingsInt(initialValue, s, f);
  }

  dynamic genCardSettingsUserFromRole(String initialValueUserID, Field f) {
    String roleName = f.field_possible_values[0];
    List<User> possibleUsers = widget.site.getUsersForRoleName(roleName);
    possibleUsers.insert(0, User.nobody());
    String initialValue = "0";
    for (var i = 0; i < possibleUsers.length; i++) {
      User u = possibleUsers[i];
      if (u.id == initialValueUserID) {
        initialValue = "$i";
      }
    }
    return CardSettingsListFromRole(
        initialValue: initialValue,
        icon: const Icon(Icons.person),
        label: f.field_label,
        items: possibleUsers,
        // controller: fieldsController[f.field_on_site_uuid],
        onChanged: (user) {
          String old_user_id = fieldsController[f.field_on_site_uuid]!.text;
          if (old_user_id != user.id) {
            fieldsController[f.field_on_site_uuid]!.text = user.id;
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }
        },
        validator: (value) {
          return null;
        });
  }

  /* CardSettingsListPicker<dynamic> genCardSettingsUserFromRole_old(
      String initialValue, Field f) {
    String roleName = f.field_possible_values[0];
    List<String> possibleValues = widget.site.getUsersForRoleName(roleName);

    return CardSettingsListPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: possibleValues,
        // controller: fieldsController[f.field_on_site_uuid],
        validator: (value) {
          String newvalue = "";
          if (value is String) {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }*/

//genCardSettingsListRadioButton
  CardSettingsSelectionPicker<dynamic> genCardSettingsListRadioButton(
      String initialValue, Field f,
      {required List<dynamic> possible_values}) {
    return CardSettingsSelectionPicker(
        showMaterialonIOS: true,
        initialItem: initialValue,
        label: f.field_label,
        items: possible_values,
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsSelectionPicker<dynamic> genCardSettingsListPicker(
      String initialValue, Field f,
      {required List<dynamic> possible_values}) {
    return CardSettingsSelectionPicker(
        initialItem: initialValue,
        label: f.field_label,
        items: possible_values,
        validator: (value) {
          String newvalue;
          if (value == null) {
            newvalue = "";
          } else {
            newvalue = value;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsText genCardSettingsInt(String initialValue, Section s, Field f) {
    int initialIntValue = 0;

    if (initialValue == "") {
      initialIntValue = 0;
    } else {
      try {
        initialIntValue = int.parse(initialValue);
      } catch (e) {
        initialIntValue = 0;
      }
    }

    String initialValueVerified = "$initialIntValue";

    return CardSettingsText(
        label: f.field_label,
        initialValue: initialValueVerified,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          // LengthLimitingTextInputFormatter(maxLength),
          FilteringTextInputFormatter.allow(RegExp("[0-9]+")),
        ],
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsText genCardSettingsFloat(
      String initialValue, Section s, Field f) {
    double initialDoubleValue = 0.0;

    if (initialValue == "") {
      initialDoubleValue = 0.0;
    } else {
      try {
        initialDoubleValue = double.parse(initialValue);
      } catch (e) {
        initialDoubleValue = 0.0;
      }
    }

    String initialValueVerified = "$initialDoubleValue";

    return CardSettingsText(
        label: f.field_label,
        initialValue: initialValueVerified,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          // LengthLimitingTextInputFormatter(maxLength),
          FilteringTextInputFormatter.allow(RegExp("[0-9\.]+")),
        ],
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsDatePicker genCardSettingsDatePicker(
      String initialValue, Field f) {
    DateTime initialDateTimeValue = DateTime.now();

    if (initialValue == "") {
      initialDateTimeValue = f.getDefaultDateTimeValue();
    } else {
      try {
        initialDateTimeValue = DateTime.parse(initialValue);
      } catch (e) {
        initialDateTimeValue = f.getDefaultDateTimeValue();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        String newvalue = formatter.format(initialDateTimeValue);
        fieldsController[f.field_on_site_uuid]!.text = newvalue;
      }
    }

    return CardSettingsDatePicker(
      dateFormat: DateFormat('dd/MM/yyyy'),
      firstDate: DateTime(2001, 1, 1, 0, 0),
      lastDate: DateTime(2030, 1, 1, 0, 0),
      label: f.field_label,
      initialValue: initialDateTimeValue,
      validator: (value) {
        String newvalue;
        if (value == null) {
          newvalue = "";
        } else {
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          newvalue = formatter.format(value);
        }
        fieldsController[f.field_on_site_uuid]!.text = newvalue;

        // keep track of real updates
        if (newvalue != initialValue) {
          if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
            listFieldsUUIDUpdated.add(f.field_on_site_uuid);
          }
          _needSave = true;
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  CardSettingsEmail genCardSettingsEmail(String initialValue, Field f) {
    return CardSettingsEmail(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsText genCardSettingsText(String initialValue, Field f) {
    return CardSettingsText(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsParagraph genCardSettingsParagraph(String initialValue, Field f) {
    return CardSettingsParagraph(
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }
          return null;
        });
  }

  CardSettingsPhone genCardSettingsPhone(String initialValue, Field f) {
    int initialIntValue;
    try {
      initialIntValue = int.parse(initialValue);
    } catch (e) {
      initialIntValue = 0;
    }

    return CardSettingsPhone(
        label: f.field_label,
        initialValue: initialIntValue,
        validator: (value) {
          logger.f(value);
          fieldsController[f.field_on_site_uuid]!.text = value as String;

          // keep track of real updates
          if (value as String != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsSwitch genCardSettingsSwitch(String initialValue, Field f) {
    bool init = false;
    if (initialValue == f.field_switch_on) {
      init = true;
    }

    if (initialValue == f.field_switch_off) {
      init = false;
    }

    return CardSettingsSwitch(
      label: f.field_label,
      trueLabel: f.field_switch_on,
      falseLabel: f.field_switch_off,
      initialValue: init,
      validator: (value) {
        String newvalue;
        if (value != null) {
          if (value) {
            newvalue = f.field_switch_on;
          } else {
            newvalue = f.field_switch_off;
          }
          fieldsController[f.field_on_site_uuid]!.text = newvalue;

          // keep track of real updates
          if (newvalue != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  CardSettingsWidget genCardSettingsGallery(String initialValue, Field f,
      {required Directory? directory,
      required Directory? directoryPendingUpload,
      required String intervention_values_on_site_uuid}) {
    return CardSettingsGallery(
        directory: directory,
        directoryPendingUpload: directoryPendingUpload,
        field: f,
        intervention_values_on_site_uuid: intervention_values_on_site_uuid,
        label: f.field_label,
        initialValue: initialValue,
        validator: (stringJsonListPictures) {
          logger.f(stringJsonListPictures);
          fieldsController[f.field_on_site_uuid]!.text =
              stringJsonListPictures as String;

          // keep track of real updates
          if (stringJsonListPictures != initialValue) {
            if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }
            _needSave = true;
          }

          return null;
        });
  }

  CardSettingsWidget genCardSettingsSignature(String initialValue, Field f) {
    return CardSettingsSignature(
        field: f,
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          if (value != null) {
            fieldsController[f.field_on_site_uuid]!.text = value;

            // keep track of real updates
            if (value != initialValue) {
              if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
                listFieldsUUIDUpdated.add(f.field_on_site_uuid);
              }
              _needSave = true;
            }
          }
          return null;
        });
  }

  CardSettingsWidget genCardSettingsSchema(String initialValue, Field f) {
    return CardSettingsSchema(
        field: f,
        label: f.field_label,
        initialValue: initialValue,
        validator: (value) {
          if (value != null) {
            fieldsController[f.field_on_site_uuid]!.text = value;

            // keep track of real updates
            if (value != initialValue) {
              if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
                listFieldsUUIDUpdated.add(f.field_on_site_uuid);
              }
              _needSave = true;
            }
          }
          return null;
        });
  }

  void dropdownStatusCallback(String? value) {
    setState(() {
      if (value is String) {
        intervention_status = value;
        widget.intervention.status = intervention_status;
        _needSave = true;
      }
    });
  }

  Widget widgetNumChrono() {
    if (widget.intervention.num_chrono == "[NNNNN]") {
      return const Text("numero de chrono en attente de génération...");
    }
    if (widget.intervention.num_chrono == null ||
        isNumericUsingRegularExpression(widget.intervention.num_chrono) ==
            false) {
      return Padding(
          padding: const EdgeInsets.all(40.0),
          child: FlexList(
              /* style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),*/
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextButton(
                      child: const Text('créer un numero de chrono'),
                      onPressed: () {
                        // Navigator.pop(context);
                        widget.intervention.num_chrono = "[NNNNN]";
                        _needSave = true;
                        refreshUI();
                      })
                ]),
                Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: widgetListInterventionSamePlace(
                        site: widget.site,
                        place: widget.intervention.place,
                        onChanged: (
                            {required Intervention intervention,
                            required String next_indice}) {
                          widget.intervention.num_chrono =
                              intervention.num_chrono;
                          widget.intervention.indice = next_indice;
                          String newName =
                              widget.intervention.BuildNumRegistre();
                          widget.intervention.intervention_name = newName;
                          _needSave = true;
                          refreshUI();
                        })),
              ]));
    } else {
      return Text('num_chrono ${widget.intervention.num_chrono}');
    }
  }

  _downloadFEB(BuildContext context,
      {required Null Function(String message) onMessage}) async {
    String url =
        "${Endpoints.baseUrl}${Endpoints.downloadFEB.replaceAll("<intervention_values_id>", widget.intervention.id)}";

    final Uri _url = Uri.parse(url);

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _initCoordinators() {
    usersCoordinators =
        UserApi.getCoordinatorsList(user: widget.user, site: widget.site);
    usersCoordinators.insert(0, User.nobody());
    userCoordinator = usersCoordinators[0];
    for (var i = 0; i < usersCoordinators.length; i++) {
      if (usersCoordinators[i].id == widget.intervention.assignee_user_id) {
        userCoordinator = usersCoordinators[i];
      }
    }
  }

  CardSettingsWidget genCardSettingsTextCustomField(
      {required CustomField custom_field, required String initialValue}) {
    return CardSettingsAutoCompleteText(
      label: custom_field.label,
      initialValue: initialValue,
      items: custom_field.autocomplete_values,
      onChanged: (value) {
        logger.f(value);
        // fieldsController[f.field_on_site_uuid]!.text = value as String;

        // keep track of real updates
        if (value != initialValue) {
          mapCustomFieldsValues[custom_field.code] = value;
          /* if (!listFieldsUUIDUpdated.contains(f.field_on_site_uuid)) {
              listFieldsUUIDUpdated.add(f.field_on_site_uuid);
            }*/
          _needSave = true;
        }
      },
    );
  }
}
