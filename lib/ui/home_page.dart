// ignore_for_file: unused_import, avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_user.dart';
import '../network/api/image.api.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'utils/logger.dart';
import 'widget/_home_page_authentified_content.dart';
import 'widget/_home_page_unauthentified_content.dart';
import 'widget/app_bar.dart';
import 'widget/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _title = 'sites';
  late User user;
  InterventionApi interventionAPI = InterventionApi();
  Timer? timer;
  bool timerIsRunning = false;

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void initTimer() {
    if (timer != null && timer!.isActive) return;
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      functionTimer();
    });
  }

  void functionTimer() async {
    if (timerIsRunning) {
      return;
    }

    timerIsRunning = true;

    await ImageApi.uploadPhotos();
    int nbInterventionsUploaded = await interventionAPI.uploadInterventions();
    logger.i("nb interventions uploaded ${nbInterventionsUploaded}");

    try {
      List<Site> list = user.sites;
      list.forEach((site) async {
        await interventionAPI.getListInterventions(site: site, realtime: true);
        interventionAPI.downloadPhotos(site: site);
      });
    } catch (e) {
      logger.e(e.toString());
    }

    timerIsRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    UserApi userAPI = UserApi();
    return FutureBuilder(
        future: userAPI.getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data;
            functionTimer();

            return widgetBody(user);
          } else if (snapshot.hasError) {
            if (timer!.isActive) {
              timer?.cancel();
            }
            return widgetError();
          } else {
            return pageWaiting();
          }
        });
  }

  PreferredSize widgetAppBar(User? me) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: (me != null && me.isAuthorized())
            ? AuthentifiedBaseAppBar(
                title: _title, user: me, onCallback: (value) => setState(() {}))
            : const BaseAppBar(title: "login"));
  }

  Widget widgetBody(User user) {
    return user.isAuthorized()
        ? Scaffold(
            appBar: widgetAppBar(user),
            body: HomepageAuthentifiedContent(
                user: user,
                onRefresh: (valueint, valueString) => setState(() {
                      if (valueString != "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              duration: const Duration(milliseconds: 100),
                              content: Text(valueString)),
                        );
                      }
                    })))
        : Scaffold(
            appBar: widgetAppBar(null),
            body: HomepageUnAuthentifiedContent(
                context: context, onConnexion: (value) => setState(() {})));
  }

  Scaffold pageWaiting() {
    return Scaffold(appBar: widgetAppBar(null), body: widgetWaiting());
  }

  Scaffold widgetError() {
    return Scaffold(appBar: widgetAppBar(null), body: widgetError());
  }
}
