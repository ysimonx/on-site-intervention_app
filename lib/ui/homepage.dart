// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print, unnecessary_import, unused_import

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/model_user.dart';
import '../network/api/login_api.dart';
import '../network/api/user_api.dart';
import '../network/dio_client.dart';
import 'utils/logger.dart';
import 'widget/_homepage_authentifier_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import './utils/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widget/app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool alreadyStartBeneficiairePage = false;
  LoginApi loginApi = LoginApi();
  UserApi userAPI = UserApi();

  final String _title = 'Accueil';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<User> getMe() async {
    bool ok = await loginApi.hasAnAccessToken();
    logger.d("hasAnAccessToken ${ok.toString()}");
    if (ok) {
      User userMe = await userAPI.me(tryRealTime: true);
      logger.d("user identified : ${userMe.email}");
      return userMe;
    }
    User userNobody = User.nobody();
    logger.d("user nobody");
    return userNobody;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child:
                BaseAppBar(_title, onDeconnexion: (value) => setState(() {}))),
        body: FutureBuilder(
            future: getMe(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                User me = snapshot.data;
                if (me.isAuthorized()) {
                  return HomepageAuthentifiedContent(user: me);
                }
                return LoginForm(context);
              } else if (snapshot.hasError) {
                return const Text("error");
              } else {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Widget LoginForm(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emailForm(),
            const SizedBox(
              height: 10,
            ),
            passwordForm(),
            const SizedBox(
              height: 10,
            ),
            submit(),
            const SizedBox(
              height: 80,
            )
          ],
        ),
      ),
    );
  }

  Widget submit() {
    return MaterialButton(
        onPressed: () async {
          String email = "";

          email = emailController.text.trim();
          email = email.replaceAll("\n", " ");
          email = email.replaceAll("\r", " ");

          String password = "";

          password = passwordController.text.trim();
          password = password.replaceAll("\n", " ");
          password = password.replaceAll("\r", " ");

          try {
            Response result =
                await loginApi.login(email: email, password: password);

            if (result.statusCode == 401) {
              if (!context.mounted) {
                return;
              }
              context.showErrorSnackBar("Echec d'authentification");
              return;
            }

            setState(() {});
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            context.showErrorSnackBar("Echec d'authentification $e");
            return;
          }
        },
        color: Theme.of(context).colorScheme.inversePrimary,
        textColor: Colors.white,
        child: const Text("Submit"));
  }

  Widget emailForm() {
    return TextFormField(
        controller: emailController,
        decoration: const InputDecoration(hintText: "email"),
        validator: validateEmail);
  }

  Widget passwordForm() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(hintText: "Password"),
    );
  }

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
}
