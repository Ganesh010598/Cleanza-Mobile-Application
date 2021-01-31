import 'package:cleanenza/views/root.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  Rx<User> _user = Rx<User>();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Rx<bool> isLoading = Rx<bool>();

  var userName = "user".obs;
  var fcmToken = "null".obs;

  // Default photoURL
  var photoURL =
      "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png"
          .obs;

  // Helper function for changing user profile pic

  changePhotoURL({String url}) {
    photoURL.value = url;
  }

  setFCM({String token}) async {
    fcmToken.value = await firebaseMessaging.getToken();
  }

  // Setup a fresh username
  setupUsername() {
    try {
      userName.value = FirebaseAuth.instance.currentUser.displayName;
    } catch (e) {
      userName.value = "User";
    }
  }

  // Helper for turning on UI switches
  switchOnLoader() {
    isLoading.value = true;
  }

  // Helper for turning off UI switches
  switchOffLoader() {
    isLoading.value = false;
  }

  // String get userCred => _user.value.email;

  User get userData => _user.value;

  // Register a new user
  register(
      {String email,
      String password,
      String first_name,
      String last_name}) async {
    switchOnLoader();
    FirebaseMessaging messaging = FirebaseMessaging();
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      _user.value = value.user;
      FirebaseFirestore.instance.collection('users').add({
        'uid': FirebaseAuth.instance.currentUser.uid,
        'first_name': first_name,
        'last_name': last_name,
        'email': FirebaseAuth.instance.currentUser.email,
        'fcm_token': fcmToken.value,
        'is_admin': false,
        'is_manager': false,
        'is_supervisor': false,
        'is_online': false
      }).catchError((e) => print(e));
      switchOffLoader();
      Get.offAll(Root());
    }).catchError((e) {
      switchOffLoader();
      print(e);
      Get.rawSnackbar(
          title: 'Oops!',
          message: 'Some error occured',
          duration: Duration(seconds: 1));
    });
  }

  // Login with email and password
  login({String email, String password}) async {
    switchOnLoader();
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      _user.value = value.user;
      switchOffLoader();
      Get.rawSnackbar(
          title: 'Success',
          message: 'Registered succssfully!',
          duration: Duration(seconds: 1));
      Get.offAll(Root());
    }).catchError((e) {
      switchOffLoader();
      Get.rawSnackbar(
          title: 'Oops!',
          message: 'Some error occured',
          duration: Duration(seconds: 1));
    });
  }

  // Change the username
  changeUsername({String username}) async {
    switchOnLoader();
    await auth.currentUser.updateProfile(displayName: username).then((value) {
      setupUsername();
      switchOffLoader();
      Get.back();
    });
  }

  // Logout
  logout() async {
    await auth.signOut().then((value) {
      Get.back();
    });
  }

  // Mark User as Online
  markOnline() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(value.docs[0].id)
          .update({'is_online': true});
      print("Marked Online");
    }).catchError((e) => print(e));
  }

  // Mark user as Offline
  markOffline() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(value.docs[0].id)
          .update({'is_online': false});
      print("Marked Offline");
    }).catchError((e) => print(e));
  }

  // Function for changing the password
  changePassword({password}) async {
    try {
      switchOnLoader();
      await FirebaseAuth.instance.currentUser
          .updatePassword(password)
          .then((value) {
        switchOffLoader();
        Get.back();
        Get.rawSnackbar(
            title: 'Success', message: 'Password changed successfully');
      }).catchError((e) => print(e));
    } catch (e) {
      switchOffLoader();
      print(e);
      Get.rawSnackbar(title: 'Oops!', message: 'Some error occured');
    }
  }

  @override
  void onInit() {
    _user.bindStream(auth.authStateChanges());
    switchOffLoader();
    setupUsername();
    super.onInit();
  }
}
