import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';

class ExceptionView extends StatefulWidget {
  const ExceptionView({Key? key}) : super(key: key);

  @override
  _ExceptionViewState createState() => _ExceptionViewState();
}

class _ExceptionViewState extends State<ExceptionView> {
  late String details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/error.png",
                height: 120,
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                "An error occurred while reading your passport",
                style: GoogleFonts.ubuntu(color: Colors.black87, fontSize: 16),
              )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.info,
                      color: Colors.black87,
                      size: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Details",
                      style: GoogleFonts.ubuntu(
                          color: Colors.black87, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Flexible(
                        child: Text(
                      details,
                      style: GoogleFonts.ubuntu(
                          color: Colors.black87, fontSize: 13),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  SystemNavigator.pop();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Retry",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  void initState() {
    Map<String, String?> parameters = Get.parameters;
    details = parameters['exception']!;
    super.initState();
  }
}
