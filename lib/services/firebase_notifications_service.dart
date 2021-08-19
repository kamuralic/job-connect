import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseNotificationsService {
  static Future<void> sendNotification(
      {required String subject,
      required String title,
      required String topic}) async {
    final postUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    String toParams = "/topics/" + topic;

    final data = {
      "notification": {"body": subject, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": topic,
      },
      "to": "$toParams"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=key'
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
// on success do
      print("true");
    } else {
// on failure do
      print("false");
    }
  }

  //subscribing to topic
  static Future<void> subscribeToTopic({required String topic}) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.subscribeToTopic(topic);
  }

  //Unsubscribing from topic
  static Future<void> unSubscribeFromTopic({required String topic}) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
