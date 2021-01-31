import 'package:cleanenza/views/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/splash.png'),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: Get.height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: Get.width * 0.1, right: Get.width * 0.1),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(18, 18, 18, 1),
                            borderRadius: BorderRadius.circular(25)),
                        child: MaterialButton(
                          onPressed: () {
                            Get.off(Login(), transition: Transition.cupertino);
                          },
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 40),
                  child: Text(
                    "CLEANZA",
                    style: GoogleFonts.poppins(
                        fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
