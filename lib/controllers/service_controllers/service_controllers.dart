import 'package:cleanenza/helpers/constants.dart';
import 'package:cleanenza/pushNotificationServices/PNH.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  // For storing reviews
  var reviewsStore = [].obs;

  // People In Counter
  var peopleIn = 0.obs;

  // People In Counter
  var peopleOut = 0.obs;

  // People In Counter
  var airData = 0.obs;

  //Total people Count
  var totalPeople = 0.obs;

  // TempPeople acts as helper in the total people counter management
  var tempPeopleCounter = 0.obs;

  // Refrence of Cloud Firestore for Getting reviews
  CollectionReference reviewsReference =
      FirebaseFirestore.instance.collection('WorkerComments');

  // Fetch Reviews
  fetchReviews() async {
    await reviewsReference.get().then((value) {
      reviewsStore.clear();
      value.docs.map((e) {
        reviewsStore.add(e.data());
      }).toList();
    });
    print(reviewsStore.length);
  }

  // Instance of realtime database
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  // For reading realtime Data
  getToiletData({GlobalKey chartKey}) async {
    await databaseReference.once().then((DataSnapshot snapshot) {
      //print(snapshot.value);
      peopleIn.value = snapshot.value['PeopleIn'];
      peopleOut.value = snapshot.value['PeopleOut'];
      airData.value = snapshot.value['airData'];
      totalPeople.value = snapshot.value['total_people'];
      tempPeopleCounter.value = snapshot.value['total_people'];
    }).catchError((e) => print(e));
  }

  checkPost(GlobalKey chartKey) async {
    await databaseReference.once().then((DataSnapshot snapshot) {
      if (snapshot.value['PeopleIn'] >= 30) {
        sendNotifications();
        getToiletData();
      } else if (snapshot.value['airData'] >= 70) {
        sendNotifications();
        getToiletData();
      } else {
        getToiletData();
      }
    }).catchError((e) => print(e));
  }

  // For adding a review
  addReview({double rating, String comment}) async {
    await reviewsReference.add({
      'workerName': FirebaseAuth.instance.currentUser.displayName == null
          ? 'Test User'
          : FirebaseAuth.instance.currentUser.displayName,
      'rating': rating,
      'comment': comment,
      'commented_by': FirebaseAuth.instance.currentUser.uid
    }).then((value) async {
      await fetchReviews();
      Get.rawSnackbar(
          title: 'Commented',
          message: 'Yay! comment posted',
          duration: Duration(seconds: 1));
    }).catchError((e) => Get.rawSnackbar(
        title: 'Oops!',
        message: 'Some error occured',
        duration: Duration(seconds: 1)));
  }

  // Helper logic for total people counuter
  // checkData(int currTotalPeople) async {
  //   if (currTotalPeople > tempPeopleCounter.value) {
  //     int diffPeople = currTotalPeople - totalPeople.value;
  //     await addTotalPeople(count: diffPeople);
  //   } else {
  //     print("People Decresed!");
  //   }
  // }

  // Logic for updating totalpeopleCount
  // addTotalPeople({int count}) async {
  //   totalPeople.value += count;
  //   await FirebaseDatabase.instance.reference().update(
  //       {'total_people': totalPeople.value}).catchError((e) => print(e));
  // }

  @override
  void onInit() {
    fetchReviews();
    getToiletData();
    super.onInit();
  }
}
