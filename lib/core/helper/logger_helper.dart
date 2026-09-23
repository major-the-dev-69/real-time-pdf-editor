import 'dart:developer';

import 'package:flutter/foundation.dart';

void printMessage(String message) {
  if (kDebugMode) log(message);
}
