import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:securepass/Home.dart';
import 'package:securepass/exceptionView.dart';
import 'package:securepass/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

late List<CameraDescription> cameras;
late SharedPreferences sharedPreference;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  cameras = await availableCameras();
  sharedPreference = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Securepass',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        getPages: [
          GetPage(name: '/', page: () => Home()),
          GetPage(name: '/result', page: () => Result()),
          GetPage(name: '/exceptionView', page: () => ExceptionView()),
        ]);
  }
}
