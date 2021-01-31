import 'dart:io';

import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/controllers/notification_controller/notification_contoller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleanenza/controllers/initial_services_controller/initialControllers.dart';
import 'package:image_picker/image_picker.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  AuthController controller = Get.find();
  File _image;
  final picker = ImagePicker();
  InitialController initialController = Get.find();
  NotificationController notificationController = Get.find();
  AuthController authController = Get.find();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 107, 255, 1),
        title: Text(
          "Account",
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      margin: EdgeInsets.only(top: 12),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              authController.switchOnLoader();
                              await getImage();
                              String profileURL = await notificationController
                                  .uploadImageToFirebase(_image.path, _image);
                              await FirebaseAuth.instance.currentUser
                                  .updateProfile(photoURL: profileURL)
                                  .then((value) {
                                controller.changePhotoURL(url: profileURL);
                                authController.switchOffLoader();
                                Get.rawSnackbar(
                                    title: 'Success',
                                    message:
                                        'Profile pic changed successfully!',
                                    duration: Duration(seconds: 1));
                              });
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: FirebaseAuth
                                          .instance.currentUser.photoURL ==
                                      null
                                  ? NetworkImage(authController.photoURL.value)
                                  : NetworkImage(FirebaseAuth
                                      .instance.currentUser.photoURL),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        initialController.fName.value +
                            " " +
                            initialController.lName.value,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 12, bottom: 12),
                    child: Divider()),
                ListTile(
                  title: Obx(() => Text(controller.userName.value != null
                      ? controller.userName.value
                      : 'Username')),
                  leading: Icon(FeatherIcons.user),
                  trailing: IconButton(
                    onPressed: () async {
                      Get.defaultDialog(
                          title: 'Change username',
                          content: Container(
                            child: Column(
                              children: [
                                TextFormField(
                                  onFieldSubmitted: (usrName) {
                                    controller.changeUsername(
                                        username: usrName);
                                  },
                                ),
                              ],
                            ),
                          ));
                    },
                    icon: Icon(FeatherIcons.edit),
                  ),
                ),
                ListTile(
                  title: Text(controller.userData.email),
                  leading: Icon(FeatherIcons.mail),
                ),
                ListTile(
                  title: Text('Change password'),
                  leading: Icon(FeatherIcons.key),
                  onTap: () async {
                    Get.defaultDialog(
                        title: 'Change password',
                        content: Container(
                          child: Column(
                            children: [
                              TextFormField(
                                onFieldSubmitted: (password) async {
                                  await authController.changePassword(
                                      password: password);
                                },
                              ),
                            ],
                          ),
                        ));
                  },
                ),
                ListTile(
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(
                    FeatherIcons.logOut,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    await controller.logout();
                  },
                  tileColor: Colors.redAccent,
                ),
              ],
            ),
            Obx(() => controller.isLoading.value
                ? LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                : Container())
          ],
        ),
      ),
    );
  }
}
