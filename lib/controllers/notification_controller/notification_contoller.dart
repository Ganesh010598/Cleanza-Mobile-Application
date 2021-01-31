import 'dart:io';
import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class NotificationController extends GetxController {
  var notifications = [].obs;
  AuthController controller = Get.find();

  // For blinking notification effect
  blinkNotification() {
    controller.switchOnLoader();
    Future.delayed(Duration(seconds: 5), () {
      controller.switchOffLoader();
    });
  }

  // For saving notifications to cloud
  saveNotification({String title, String message, DateTime time}) async {
    blinkNotification();
    notifications.add({'title': title, 'message': message, 'time': time});
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'time': time,
      'status': 'NC',
      'rejected_by': 'none',
      'accepted_by': 'none'
    }).catchError(
        (e) => print(e)); // NC -> Not Cleaned  C=> Cleaned  R=> Rejected
  }

  // For retreiving all notifications from cloud
  Stream notificationStream = FirebaseFirestore.instance
      .collection('notifications')
      .where('status', isEqualTo: 'NC')
      .snapshots();

  // For retreiving done notifications from cloud
  Stream notificationStreamDone = FirebaseFirestore.instance
      .collection('notifications')
      .where('accepted_by', isEqualTo: FirebaseAuth.instance.currentUser.uid)
      .snapshots();

  // For retreiving rejected notifications from cloud
  Stream notificationStreamRejected = FirebaseFirestore.instance
      .collection('notifications')
      .where('rejected_by', isEqualTo: FirebaseAuth.instance.currentUser.uid)
      .snapshots();

  // For uploading image
  Future uploadImageToFirebase(imagePath, imageFile) async {
    try {
      String fileName = basename(imagePath);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('toiletImages/$fileName');
      TaskSnapshot event = await firebaseStorageRef.putFile(imageFile);
      String downloadURL = await firebaseStorageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print(e);
      controller.switchOffLoader();
      Get.rawSnackbar(title: 'Oops!', message: 'Some error occured');
    }
  }

  // For saving a work done
  saveWork({String taskRef, File image}) async {
    controller.switchOnLoader();
    String dURL = await uploadImageToFirebase(image.path, image);
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(taskRef)
        .update({
      'status': 'C',
      'accepted_by': FirebaseAuth.instance.currentUser.uid,
      'image_url': dURL,
      'rating': 0,
      'comments': 'none',
      'isReported': false,
      'accepted_on': DateTime.now()
    });
    await FirebaseFirestore.instance.collection('workReference').add(
        {'accepted_on': DateTime.now(), 'imgURL': dURL, 'taskRef': taskRef});
    controller.switchOffLoader();
    Get.rawSnackbar(
        title: 'Saved',
        message: 'Your work was saved Successfully',
        duration: Duration(seconds: 1));
    await FirebaseDatabase.instance
        .reference()
        .update({'PeopleIn': 0, 'airData': 0});
    // await FirebaseFirestore.instance
    //     .collection('notifications')
    //     .where('accepted_by', isEqualTo: 'none')
    //     .get()
    //     .then((value) {
    //   value.docs.map((e) {
    //     FirebaseFirestore.instance.doc(e.id).delete();
    //   }).toList();
    // }).catchError((error) => print(error));
  }
}
