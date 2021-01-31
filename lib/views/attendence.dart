import 'package:cleanenza/controllers/attendenceController/attendence_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Attendence extends StatelessWidget {
  AttendenceController controller = Get.put(AttendenceController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 107, 255, 1),
        title: Text(
          'Attendence',
          style: GoogleFonts.manrope(),
        ),
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            Container(
              height: Get.height,
              width: Get.width,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Text(
                              trcontroller.totalWorkers.value.toString(),
                              style: GoogleFonts.poppins(
                                  fontSize: 55,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue))),
                          Text("Total Workers",
                              style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue))
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('is_online', isEqualTo: true)
                        .where('is_admin', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(snapshot.data.docs.length.toString(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 55,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                Text("Workers Online",
                                    style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green))
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                tileColor: Colors.blueAccent,
                trailing: Icon(
                  Icons.arrow_circle_up,
                  color: Colors.white,
                ),
                title: Text(
                  'Tap to see more',
                  style: GoogleFonts.manrope(color: Colors.white),
                ),
                leading: Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                onTap: () {
                  Get.bottomSheet(Container(
                    height: 700,
                    width: Get.width,
                    color: Colors.grey[200],
                    margin: EdgeInsets.only(top: 10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('is_admin', isEqualTo: false)
                          .snapshots(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            height: 600,
                            width: Get.width,
                            child: ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                QuerySnapshot data = snapshot.data;
                                return ListTile(
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[700],
                                        child: Icon(Icons.person),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    data.docs[index].data()['email'],
                                    style:
                                        GoogleFonts.roboto(color: Colors.black),
                                  ),
                                  subtitle: data.docs[index].data()['is_online']
                                      ? Text(
                                          'Online',
                                          style: GoogleFonts.roboto(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500),
                                        )
                                      : Text(
                                          'Offline',
                                          style: GoogleFonts.roboto(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500),
                                        ),
                                );
                              },
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Some error occured!"),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
