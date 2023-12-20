// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print, unnecessary_import, unused_import

import 'dart:async';

import '../network/api/login_api.dart';
import '../network/dio_client.dart';
import 'widget/_login_identified_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';

import 'widget/app_bar.dart';
import './utils/context.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  @override
  State<LoginPage> createState() => _LoginPageState();

  final String title;
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool alreadyStartBeneficiairePage = false;
  LoginApi loginApi = LoginApi();

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: BaseAppBar(widget.title)),
        body: FutureBuilder(
            future: loginApi.hasAnAccessToken(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return const LoginIdentifiedContent(title: "test");
                }

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

  void navigateToBeneficiairesPage() async {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginIdentifiedContent(
              title: 'Mes chantiers',
            ),
          ),
        );
      },
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
