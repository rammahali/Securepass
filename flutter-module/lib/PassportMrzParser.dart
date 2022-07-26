import 'package:securepass/Formatter.dart';
import 'package:securepass/mrzScanner.dart';

class PassportMrzParser {
  String mrzLine2;

  PassportMrzParser(this.mrzLine2);

  Formatter formatter = Formatter();

  parseMrz() {
    String passportNumber = mrzLine2.substring(0, 9);
    String mrzBirthDate = mrzLine2.substring(13, 19);
    String mrzExpiryDate = mrzLine2.substring(21, 27);
    String birthDate = formatter.formatBirthDate(mrzBirthDate);
    String expiryDate = formatter.formatBirthDate(mrzExpiryDate);
    ChipAuthenticationData chipAuthenticationData =
        ChipAuthenticationData(passportNumber, birthDate, expiryDate);

    return chipAuthenticationData;
  }
}
