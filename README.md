# Securepass

Flutter app to read passport data using NFC

## Steps

Both flutter module and android module need to be at the same folder in order for the application to compile and run

1- in flutter module run
```
flutter pub get
```

2- from android module compile and run the app

## About
This app is a flutter integration to native android module  . using platform method channels and [GetX library](https://pub.dev/packages/get) to pass the data from a native android module which uses JMRTD library to authenticate with the passport chip and send it to flutter module

## Feautrers

- Real time MRZ scanning and parsing
- authenticating with the passport chip using NFC and reading DG1 and DG2
- parsing DG2 file to JPEG base64 format which is accepted by flutter

## Implementation
this app follows [e-Passport NFC Reader](https://github.com/tananaev/passport-reader) JMRTD implementation
## Dependencies

Note that the app includes following third party dependencies:
- Google Ml kit
- JMRTD - LGPL 3.0 License
- SCUBA (Smart Card Utils) - LGPL 3.0 License
- Spongy Castle - MIT-based Bouncy Castle Licence
- JP2 for Android - BSD 2-Clause License
- JNBIS - Apache 2.0 License


