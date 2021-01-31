import 'dart:io';
import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/controllers/notification_controller/notification_contoller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin {
  NotificationController notificationController = Get.find();
  AuthController authController = Get.find();
  TabController controller;
  File _image;
  final picker = ImagePicker();

  // For parsing the datetime object
  getTime(Timestamp time) {
    var date = DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
    String parsedObject = date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString();
    return parsedObject;
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        return _image;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    controller = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 107, 255, 1),
        title: Text(
          'Notifications',
          style: GoogleFonts.manrope(),
        ),
        bottom: TabBar(
          indicatorWeight: 3,
          indicatorColor: Colors.amber,
          controller: controller,
          tabs: [
            Tab(
              icon: Icon(Icons.done),
              text: 'All Tasks',
            ),
            Tab(
              icon: Icon(Icons.done_all),
              text: 'Completed Tasks',
            ),
            Tab(
              icon: Icon(Icons.not_interested),
              text: 'Rejected',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          Stack(
            children: [
              StreamBuilder(
                stream: notificationController.notificationStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 5, top: 20, bottom: 20),
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 8),
                          color: Colors.grey[100],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      snapshot.data.docs[index]
                                                  .data()['title'] !=
                                              null
                                          ? snapshot.data.docs[index]
                                              .data()['title']
                                          : 'Not Found!',
                                      style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    snapshot.data.docs[index]
                                                .data()['message'] !=
                                            null
                                        ? snapshot.data.docs[index]
                                            .data()['message']
                                        : 'Not Found!',
                                    style: GoogleFonts.roboto(fontSize: 15),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await getImage();
                                      await notificationController.saveWork(
                                          taskRef: snapshot.data.docs[index].id,
                                          image: _image);
                                    },
                                    icon: Icon(Icons.done),
                                    color: Colors.green,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('notifications')
                                          .doc(snapshot.data.docs[index].id)
                                          .update({
                                        'status': 'R',
                                        'rejected_by': FirebaseAuth
                                            .instance.currentUser.uid
                                      });
                                    },
                                    icon: Icon(Icons.not_interested_outlined),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Obx(() => authController.isLoading.value
                    ? LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : Container()),
              ),
            ],
          ),
          StreamBuilder(
            stream: notificationController.notificationStreamDone,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 20, bottom: 20),
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data.docs[index].data()['title'] !=
                                          null
                                      ? snapshot.data.docs[index]
                                          .data()['title']
                                      : 'Not Found!',
                                  style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  snapshot.data.docs[index].data()['message'] !=
                                          null
                                      ? snapshot.data.docs[index]
                                          .data()['message']
                                      : 'Not Found!',
                                  style: GoogleFonts.ubuntu(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Completed on",
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  Text(
                                      getTime(snapshot.data.docs[index]
                                          .data()['accepted_on']),
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          StreamBuilder(
            stream: notificationController.notificationStreamRejected,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 20, bottom: 20),
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data.docs[index].data()['title'] !=
                                          null
                                      ? snapshot.data.docs[index]
                                          .data()['title']
                                      : 'Not Found!',
                                  style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  snapshot.data.docs[index].data()['message'] !=
                                          null
                                      ? snapshot.data.docs[index]
                                          .data()['message']
                                      : 'Not Found!',
                                  style: GoogleFonts.roboto(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rejected on",
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                  Text(
                                      getTime(snapshot.data.docs[index]
                                          .data()['time']),
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
