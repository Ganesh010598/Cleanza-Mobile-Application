import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  var completedCounter = 0.obs;
  AuthController controller = Get.find();

  // Rating value holder used in Generate Report part
  var ratingValue = (0.0).obs;

  // Helper function for changing rating dynamically
  changeRating(double rating) {
    ratingValue.value = rating;
  }

  Stream<QuerySnapshot> reference = FirebaseFirestore.instance
      .collection('notifications')
      .orderBy('time')
      .where('time', isLessThanOrEqualTo: DateTime.now())
      .snapshots();

  Stream<QuerySnapshot> monthlyRef = FirebaseFirestore.instance
      .collection('notifications')
      .orderBy('time')
      .where('time', isLessThanOrEqualTo: DateTime.now())
      .snapshots();
  // A Helper Datetime Object
  DateTime currTime = DateTime.now();

  //Increment Counter
  incrementCounter() {
    completedCounter.value += 1;
  }

  // For liking the Work
  likeWork({String docID, rating}) async {
    controller.switchOnLoader();
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docID)
        .update({'rating': rating}).then((value) {
      controller.switchOffLoader();
      Get.back();
    });
    print("Liked!");
  }

  // For Commenting
  commentWork({String docID, String comment}) async {
    controller.switchOnLoader();
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docID)
        .update({'comments': comment}).then((value) {
      controller.switchOffLoader();
      Get.back();
    });
  }

  // For Commenting
  reportWork({String docID}) async {
    controller.switchOnLoader();
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docID)
        .update({'isReported': true}).then(
            (value) => controller.switchOffLoader());
  }
}
