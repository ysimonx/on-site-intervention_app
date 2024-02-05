import 'dart:async';
import 'package:flutter/material.dart';
import '../models/model_user.dart';
import '../network/api/login_api.dart';
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
  UserApi userAPI = UserApi();
  LoginApi loginApi = LoginApi();

  final String _title = 'sites';

  Future<User> getMyInformations() async {
    bool ok = await loginApi.hasAnAccessToken();
    if (ok) {
      User userMe = await userAPI.myConfig(tryRealTime: true);
      return userMe;
    }
    return User.nobody();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMyInformations(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            User me = snapshot.data;
            return widgetBody(me);
          } else if (snapshot.hasError) {
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

  Widget widgetBody(User me) {
    return me.isAuthorized()
        ? Scaffold(
            appBar: widgetAppBar(me),
            body: HomepageAuthentifiedContent(
                user: me,
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
