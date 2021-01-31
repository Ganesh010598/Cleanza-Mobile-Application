import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/controllers/notification_controller/notification_contoller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  AuthController controller = Get.find();
  NotificationController notificationController =
      Get.put(NotificationController());

  init() {
    _firebaseMessaging
        .getToken()
        .then((value) => controller.setFCM(token: value))
        .catchError((e) => print(e));
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        notificationController.saveNotification(
            title: message['notification']['title'],
            message: message['notification']['body'],
            time: DateTime.now());
      },
      onResume: (Map<String, dynamic> message) async {
        print(message['data']['title']);
        print(message['data']['body']);
        notificationController.saveNotification(
            title: message['data']['title'],
            message: message['data']['body'],
            time: DateTime.now());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        notificationController.saveNotification(
            title: message['data']['title'],
            message: message['data']['body'],
            time: DateTime.now());
      },
    );
  }

  // sendNotifications() async {
  //   http.Response response = await http.post(
  //     'https://fcm.googleapis.com/fcm/send',
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverToken',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{
  //           'body': 'Please, Go clean the toilet.',
  //           'title': 'Clean Alert'
  //         },
  //         'priority': 'high',
  //         'data': <String, dynamic>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'title': 'Clean Alert',
  //           'body': 'Please, Go clean the toilet.'
  //         },
  //         'to': await _firebaseMessaging.getToken(),
  //       },
  //     ),
  //   );
  //   final Completer<Map<String, dynamic>> completer =
  //       Completer<Map<String, dynamic>>();
  //
  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       completer.complete(message);
  //       print(message);
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       completer.complete(message);
  //       print(message);
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       completer.complete(message);
  //       print(message);
  //     },
  //   );
  //
  //   return completer.future;
  // }
}
