import 'dart:async';
import 'dart:convert';
import 'package:cleanenza/controllers/notification_controller/notification_contoller.dart';
import 'package:cleanenza/helpers/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

FirebaseMessaging firebaseMessaging = FirebaseMessaging();
NotificationController controller = Get.find();

sendNotifications() async {
  http.Response response = await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': 'Please, Go clean the toilet.',
          'title': 'Clean Alert'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'title': 'Clean Alert',
          'body': 'Please, Go clean the toilet.'
        },
        'to': await firebaseMessaging.getToken(),
      },
    ),
  );
  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
      print(message);
      controller.saveNotification(
          title: message['notification']['title'],
          message: message['notification']['body'],
          time: DateTime.now());
    },
    onLaunch: (Map<String, dynamic> message) async {
      completer.complete(message);
      print(message);
      controller.saveNotification(
          title: message['notification']['title'],
          message: message['notification']['body'],
          time: DateTime.now());
    },
    onResume: (Map<String, dynamic> message) async {
      completer.complete(message);
      print(message);
      controller.saveNotification(
          title: message['notification']['title'],
          message: message['notification']['body'],
          time: DateTime.now());
    },
  );

  return completer.future;
}
