// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:tc_serverside_plugin/events/TCCustomEvent.dart';
import 'package:tc_serverside_plugin/events/TCLoginEvent.dart';
import 'package:tc_serverside_plugin/tc_serverside.dart';

class TC {
  TCServerside serverside = TCServerside();

  static int TC_SITE_ID = 7244; // defines this site account ID
  static int TC_PRIVACY_ID = 6; // defines this privacy ID
  static String sourceKey = "fe203bc4-7027-410d-9d23-310c5b91e34b";

  TC() {
    try {
      serverside.initServerSide(TC.TC_SITE_ID, TC.sourceKey);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendEventLogin({required String email}) async {
    //  await serverside.enableRunningInBackground();
    // await serverside.enableServerSide();
    try {
      await serverside.execute(makeTCLoginEvent(email: email));
    } catch (e) {
      print(e.toString());
    }
    return;
  }

  Future<void> sendCustomEvent(
      {required String key, required dynamic value}) async {
    //  await serverside.enableRunningInBackground();
    // await serverside.enableServerSide();
    try {
      Future<void>.delayed(
        const Duration(milliseconds: 100),
        () async {
          serverside.execute(makeTCCustomEvent(key: key, value: value));
        },
      );
    } catch (e) {
      print(e.toString());
    }
    return;
  }

  static TCLoginEvent makeTCLoginEvent({required String email}) {
    var event = TCLoginEvent();
    event.name = "login";

    event.pageName = "home";
    event.pageType = "event_page_type";
    event.addAdditionalPropertyWithMapValue("user", {"email": email});
    event.method = "legacy";
    return event;
  }

  static TCCustomEvent makeTCCustomEvent(
      {required String key, required dynamic value}) {
    var event = TCCustomEvent("custom_event");
    event.name = "custom event";
    event.pageName = "event_page_name";
    event.pageType = "event_page_type";
    if (value is int) {
      event.addAdditionalPropertyWithIntValue(key, value);
    }
    if (value is List) {
      event.addAdditionalPropertyWithListValue(key, value);
    }
    if (value is Map) {
      event.addAdditionalPropertyWithMapValue(key, value);
    }
    if (value is double) {
      event.addAdditionalPropertyWithDoubleValue(key, value);
    }
    if (value is bool) {
      event.addAdditionalPropertyWithBooleanValue(key, value);
    }
    if (value is String) {
      event.addAdditionalProperty(key, value);
    }

    return event;
  }
}
