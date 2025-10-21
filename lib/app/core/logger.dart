import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

final log = Logger(
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none, // ⬅️ replaces deprecated printTime
  ),
);
