import 'package:cleanenza/controllers/bindings/initialBindings.dart';
import 'package:cleanenza/views/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:cleanenza/views/connectionStatusSingleton.dart';
// import 'package:cleanenza/views/testWidget.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitBindings(),
      title: 'CleanZa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Root(),
      debugShowCheckedModeBanner: false,
    );
  }
}
