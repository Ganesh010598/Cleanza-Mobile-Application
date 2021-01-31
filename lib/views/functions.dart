import 'package:cleanenza/controllers/initial_services_controller/initialControllers.dart';
import 'package:cleanenza/views/attendence.dart';
import 'package:cleanenza/views/generate_report.dart';
import 'package:cleanenza/views/notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Functions extends StatelessWidget {
  InitialController initialController = Get.put(InitialController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 107, 255, 1),
        title: Text(
          "Functions",
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: GridView(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          children: [
            InkWell(
              onTap: () {
                Get.to(Notifications());
              },
              child: Card(
                color: Colors.deepOrange,
                elevation: 3,
                child: Container(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notification_important,
                        color: Colors.white,
                        size: 70,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Notifications",
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white))
                    ],
                  ),
                ),
              ),
            ),
            Obx(() => initialController.isAdmin.value
                ? GestureDetector(
                    onTap: () {
                      Get.to(GenerateReport(),
                          transition: Transition.cupertino);
                    },
                    child: Card(
                      color: Colors.grey[700],
                      elevation: 3,
                      child: Container(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark,
                              color: Colors.white,
                              size: 70,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Manage Reports",
                                style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()),
            Obx(() => initialController.isAdmin.value
                ? GestureDetector(
                    onTap: () {
                      Get.to(Attendence(), transition: Transition.cupertino);
                    },
                    child: Card(
                      color: Colors.pink,
                      elevation: 3,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 70,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("See Attendence",
                                style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()),
          ],
        ),
      ),
    );
  }
}
