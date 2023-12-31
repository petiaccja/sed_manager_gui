import 'dart:core';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'sedmanager_capi.dart';

String getLastErrorMessage() {
  final capi = SEDManagerCAPI();
  final chars = capi.getLastErrorMessage();
  return capi.convertCString(chars);
}

class SEDException implements Exception {
  SEDException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
