class Formatter {
  formatBirthDate(String date) {
    DateTime dateToday = DateTime.now();
    String currentYearLast2Digits = dateToday.year.toString().substring(2, 4);
    String givenYearFirs2tDigits = date.substring(0, 2);
    String givenYear = date.substring(0, 2);
    String givenMonth = date.substring(2, 4);
    String givenDay = date.substring(4, 6);
    late String birthDate;

    if (int.parse(currentYearLast2Digits) > int.parse(givenYearFirs2tDigits)) {
      // birth year should be 2000 and above
      birthDate = "20$givenYear-$givenMonth-$givenDay";
    } else {
      // birth year should be 1999 and below
      birthDate = "19$givenYear-$givenMonth-$givenDay";
    }

    return birthDate;
  }

  formatExpiryDate(String date) {
    String givenYear = date.substring(0, 2);
    String givenMonth = date.substring(2, 4);
    String givenDay = date.substring(4, 6);
    late String expiryYear;

    expiryYear = "20$givenYear-$givenMonth-$givenDay";

    return expiryYear;
  }
}
