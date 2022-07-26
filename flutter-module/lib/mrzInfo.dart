import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:securepass/mrzScanner.dart';



class MrzInfo extends StatelessWidget {
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
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: Colors.black,
                  )),
              Text(
                "MRZ",
                style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/mrz.png",
                height: 250,
                fit: BoxFit.fitHeight,
              )
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                "Scan MRZ ",
                style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18),
              )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                "You will need to scan the machine readable zone found on the bottom of the details page of your passport",
                style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 13),
              )),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MrzScan()));
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  height: 42,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Scan Mrz",
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
}
