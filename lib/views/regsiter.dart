import 'package:cleanenza/controllers/auth_controller/auth_controller.dart';
import 'package:cleanenza/views/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FocusNode email = FocusNode();
  FocusNode pass = FocusNode();
  FocusNode first_name = FocusNode();
  FocusNode last_name = FocusNode();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController fName = TextEditingController();
  TextEditingController lName = TextEditingController();
  AuthController controller = Get.find();

  @override
  void initState() {
    emailC = TextEditingController();
    passC = TextEditingController();
    fName = TextEditingController();
    lName = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    fName.dispose();
    lName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: false,
        body: Scaffold(
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
                      focusNode: first_name,
                      controller: fName,
                      decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: GoogleFonts.montserrat(),
                          prefixIcon: Icon(Icons.person)),
                      onSubmitted: (tesXt) {
                        FocusScope.of(context).requestFocus(last_name);
                      },
                    ),
                    TextField(
                      focusNode: last_name,
                      controller: lName,
                      decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: GoogleFonts.montserrat(),
                          prefixIcon: Icon(Icons.person)),
                      onSubmitted: (tesYt) {
                        FocusScope.of(context).requestFocus(email);
                      },
                    ),
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
                      onSubmitted: (passTemp) async {
                        await controller.register(
                            email: emailC.text,
                            password: passC.text,
                            first_name: fName.text,
                            last_name: lName.text);
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
                                  await controller.register(
                                      email: emailC.text,
                                      password: passC.text,
                                      first_name: fName.text,
                                      last_name: lName.text);
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
                                          "Register",
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
                            "Already have a account?",
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                              onTap: () {
                                Get.off(Login(),
                                    transition: Transition.cupertino);
                              },
                              child: Text(
                                "Sign-in",
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
        ));
  }
}
