import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:securepass/Formatter.dart';
import 'package:securepass/main.dart';

class Result extends StatefulWidget {
  const Result({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late String photoBase64;
  late Map<String, String?> data;
  late Uint8List bytes;
  Formatter formatter = Formatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () => SystemNavigator.pop(),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: Colors.black,
                  )),
              Text(
                "Result",
                style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Image.memory(
                base64.decode(photoBase64.replaceAll(RegExp(r'\s'), '')),
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                width: 20,
              ),
              Flexible(
                child: Text(
                  "${data['firstName']!} ${data['lastName']!}",
                  style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          infoHolder("First name", data['firstName']!),
          infoHolder("Last name", data['lastName']!),
          infoHolder("Gender", data['gender']!),
          infoHolder("Nationality", data['nationality']!),
          infoHolder(
              "Date of birth", formatter.formatBirthDate(data['birthDate']!)),
          infoHolder("Document type", "Passport"),
          infoHolder("Document number", data['passportNumber']!),
          infoHolder(
              "Expiry date", formatter.formatExpiryDate(data['expiryDate']!)),
          infoHolder("Issuing country", data['issuingState']!),
        ],
      ),
    );
  }

  Widget infoHolder(String title, String primaryText) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.ubuntu(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 7,
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                primaryText,
                style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 14,
        ),
        Container(
          height: 0.5,
          width: double.infinity,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  void initState() {
    _getPhotoBase64();
    Map<String, String?> parameters = Get.parameters;
    data = parameters;
    super.initState();
  }

  _getPhotoBase64() async {
    String photo = sharedPreference.getString("photoBase64")!;
    photoBase64 = photo;
  }
}
