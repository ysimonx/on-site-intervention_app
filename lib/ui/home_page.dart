import 'dart:async';

import 'package:flutter/material.dart';
import '../models/model_intervention.dart';
import '../models/model_site.dart';
import '../models/model_user.dart';
import '../network/api/image.api.dart';
import '../network/api/intervention_api.dart';
import '../network/api/user_api.dart';
import 'widget/_home_page_authentified_content.dart';
import 'widget/_home_page_unauthentified_content.dart';
import 'widget/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _title = 'sites';
  late User user;

  Timer? timer;

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

  void functionTimer() {
    ImageApi.processUploadPendingImages();

    var interventionAPI = InterventionApi();

    List<Site> list = user.sites;
    try {
      list.forEach((site) async {
        print("sync site : ${site.name}");
        await interventionAPI.syncLocalUpdatedFiles();
        await interventionAPI.getList(site: site);
        interventionAPI.downloadPhotos(site: site);
      });
    } catch (e) {
      print(e.toString());
    }
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
            return widgetWaiting();
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

  Scaffold widgetWaiting() {
    return Scaffold(
        appBar: widgetAppBar(null),
        body: const Center(
            child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        )));
  }

  Scaffold widgetError() {
    return Scaffold(appBar: widgetAppBar(null), body: const Text("error"));
  }
}
