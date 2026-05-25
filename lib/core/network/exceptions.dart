import 'package:street_team/core/utils/talker_helper.dart';

class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    talker.error("$prefix $message");
    return "$prefix$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message)
    : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message, "Unauthorised: ");
}
