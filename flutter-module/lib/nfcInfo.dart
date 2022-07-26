import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:securepass/mrzScanner.dart';


// ignore: must_be_immutable
class NfcInfo extends StatefulWidget {
  ChipAuthenticationData chipAuthenticationData;

  NfcInfo(this.chipAuthenticationData, {Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NfcInfoState createState() => _NfcInfoState();
}

class _NfcInfoState extends State<NfcInfo> {
  final GlobalKey<ScaffoldState> key =  GlobalKey<ScaffoldState>();

  List<String> authData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
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
                "NFC",
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
                "assets/images/passportscan.png",
                height: 150,
                fit: BoxFit.fitHeight,
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                "Read passport with NFC",
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
                "Read your passport data by placing the passport at the back side of your phone , keep it placed until the authentication process with the passport's chip is finished and make sure the NFC option is enabled on your phone",
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
                  _sendAuthData(authData);
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
                        "Start NFC session",
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

  Future<void> _sendAuthData(List<String> authData) async {
    const platform = MethodChannel('com.securepass.auth');
    authData.clear();
    authData.add(widget.chipAuthenticationData.passportNumber);
    authData.add(widget.chipAuthenticationData.birthDate);
    authData.add(widget.chipAuthenticationData.ExpiryDate);
    try {
      await platform.invokeMethod('getAuthData', {"authData": authData});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => key.currentState?.showSnackBar(SnackBar(
              content: Text(
                'MRZ has been successfully scanned',
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: Colors.green,
            )));
  }
}

// ignore: must_be_immutable
