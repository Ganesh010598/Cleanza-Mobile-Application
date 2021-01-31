import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AttendenceController extends GetxController {
  var totalWorkers = 0.obs;

  // Get total workers
  getTotalWorkers() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('is_admin', isEqualTo: false)
        .get()
        .then((value) {
      totalWorkers.value = value.docs.length;
    }).catchError((e) => print(e));
  }

  @override
  void onInit() {
    getTotalWorkers();
    super.onInit();
  }
}
