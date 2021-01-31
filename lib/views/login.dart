import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/views/regsiter.dart';
import 'package:cleanenza/views/tempLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FocusNode email = FocusNode();
  FocusNode pass = FocusNode();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  AuthController controller = Get.find();

  @override
  void initState() {
    emailC = TextEditingController();
    passC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                "Cleanza",
                style: GoogleFonts.montserrat(
                    fontSize: 35, fontWeight: FontWeight.w600, height: 3),
              ),
            ),
            Column(
              children: [
                TextField(
                  focusNode: email,
                  controller: emailC,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.montserrat(),
                      prefixIcon: Icon(Icons.email)),
                  onSubmitted: (test) {
                    FocusScope.of(context).requestFocus(pass);
                  },
                ),
                TextField(
                  focusNode: pass,
                  controller: passC,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.montserrat(),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye)),
                  onSubmitted: (passText) async {
                    await controller.login(
                        email: emailC.text, password: passC.text);
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 107, 255, 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: MaterialButton(
                            onPressed: () async {
                              await controller.login(
                                  email: emailC.text, password: passC.text);
                            },
                            child: Obx(
                              () => controller.isLoading.value
                                  ? SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      "Log in",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                            )),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot password?",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          height: 2.7,
                          color: Colors.black),
                    )
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not registered yet?",
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                          onTap: () {
                            Get.off(Register(),
                                transition: Transition.cupertino);
                          },
                          child: Text(
                            "Register",
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
