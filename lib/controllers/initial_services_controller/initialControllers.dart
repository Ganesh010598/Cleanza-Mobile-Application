import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class InitialController extends GetxController {
  // This function is just here for getting the info the current logged in user weather he is admin (manager / supervisor or not)
  var isAdmin = false.obs;

  var isManager = false.obs;
  var isSupervisor = false.obs;

  var fName = "Please".obs;
  var lName = "Wait".obs;

  //Function for getting userData
  getUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      if (value.docs[0].data()['is_admin']) {
        isAdmin.value = true;
        if (value.docs[0].data()['is_supervisor']) {
          isSupervisor.value = true;
        } else if (value.docs[0].data()['is_manager']) {
          isManager.value = true;
        }
      } else {}
    }).catchError((e) => print(e));
  }

  getUsername() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      fName.value = value.docs[0].data()['first_name'] == null
          ? 'Not'
          : value.docs[0].data()['first_name'];
      lName.value = value.docs[0].data()['last_name'] == null
          ? 'Provided'
          : value.docs[0].data()['last_name'];
    }).catchError((e) => print(e));
  }

  @override
  void onInit() {
    getUserData();
    getUsername();
    super.onInit();
  }
}
