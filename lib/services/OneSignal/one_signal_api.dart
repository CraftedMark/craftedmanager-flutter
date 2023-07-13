import 'package:crafted_manager/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'notification_type.dart';

class OneSignalAPI {
  static const _url = "https://onesignal.com/api/v1/notifications";

  static const String _companyName = "CraftedManager";

  static Future<void> sendNotification({required String message, required NotificationEventType type}) async {
    var uri = Uri.parse(_url);

    final event = type.name;

    var payload = {
      "included_segments": "Subscribed Users",
      "app_id": AppConfig.ONESIGNAL_APP_KEY,
      "contents": {
        "en": message,
      },
      "name": _companyName,
      "data":{"event":event},
    };
    var headers = {
      "accept": "application/json",
      "Authorization": "Basic ${AppConfig.ONESIGNAL_REST_API_KEY}",
      "content-type": "application/json"
    };
    try {
      var result = await http.post(uri, headers: headers, body: jsonEncode(payload));

      print( result.body.toString());
    }catch(e){
      print(e);
    }

  }
}

enum NotificationType{
  orders,
  customers,
  products,
  employees
}