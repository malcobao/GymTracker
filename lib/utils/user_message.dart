import '../data/errors/app_exception.dart';

/// The text to show the user for any error carried by a `Result`.
String userMessage(Exception error) =>
    error is AppException ? error.message : const UnknownException().message;
