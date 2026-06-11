import 'package:flutter/foundation.dart';

void dPrint(Object? message) {
  if (kDebugMode) {
    debugPrint('[StreamWorld] $message');
  }
}
