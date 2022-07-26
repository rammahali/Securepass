// ignore_for_file: non_constant_identifier_names

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:securepass/PassportMrzParser.dart';
import 'package:securepass/nfcInfo.dart';
import 'main.dart';

class MrzScan extends StatefulWidget {
  const MrzScan({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MrzScanState createState() => _MrzScanState();
}

class _MrzScanState extends State<MrzScan> {
  MrzLine mrzLine2 = MrzLine("Mrz line 2", false);

  bool _isBusy = false;
  bool initialized = false;
  late CameraController controller;
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: !initialized
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(
                    controller,
                  ),
                ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7), BlendMode.srcOut),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.2),
                          height: size.height * 0.30,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void initState() {
    initController();
    super.initState();
  }

  Future<void> initController() async {
    controller = CameraController(cameras[0], ResolutionPreset.max);
    await controller.initialize().then((_) {
      setState(() {
        initialized = true;
        _startImageStream();
      });
      if (!mounted) {
        return;
      }
    });
  }

  Future<void> _startImageStream() async {
    if (!controller.value.isInitialized) {
      if (kDebugMode) {
        print('controller not initialized');
      }
      return;
    }
    await controller.startImageStream((image) async {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(cameras[0].sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
      _processImage(inputImage);
    });
  }

  void _processImage(InputImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    final recognizedText = await _textRecognizer.processImage(image);

    if (mounted) {
      for (var element in recognizedText.blocks) {
        for (var line in element.lines) {
          if (kDebugMode) {
            print(line.text);
          }

          await _detectMrz(line.text);
          if (mrzLine2.isDetected) {
            ChipAuthenticationData chipAuthenticationData = _parseMrz(mrzLine2);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => NfcInfo(chipAuthenticationData)));

            return;
          }
        }
      }
    }
    _isBusy = false;
  }

  //TODO improve mrz detecting
  _detectMrz(String text) async {
    RegExp passportTD3Line2RegExp = RegExp(
        r"([A-Z0-9<]{9})([0-9]{1})([A-Z]{3})([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z0-9<]{14})([0-9]{1})([0-9]{1})");
    RegExp passportTD3Line2CustomRegExp = RegExp(
        r"([A-Z0-9<]{9})([0-9]{1})([A-Z]{3})([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z0-9<]{15})([0-9]{1})"); // some international passports uses this format
    if (passportTD3Line2RegExp.hasMatch(text.replaceAll(" ", "")) ||
        passportTD3Line2CustomRegExp.hasMatch(text.replaceAll(" ", ""))) {
      mrzLine2.text = text.replaceAll(" ", "");
      mrzLine2.isDetected = true;
    }
  }

  _parseMrz(MrzLine mrzLine2) {
    PassportMrzParser passportMrzParser = PassportMrzParser(mrzLine2.text);
    return passportMrzParser.parseMrz();
  }

  @override
  void dispose() async {
    controller.dispose();
    super.dispose();
  }
}

class MrzLine {
  String text;
  bool isDetected;

  MrzLine(this.text, this.isDetected);
}

class ChipAuthenticationData {
  String passportNumber;
  String birthDate;
  String ExpiryDate;

  ChipAuthenticationData(this.passportNumber, this.birthDate, this.ExpiryDate);
}
