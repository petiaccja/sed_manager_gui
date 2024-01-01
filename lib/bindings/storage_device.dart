import 'dart:core';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'sedmanager_capi.dart';

class StorageDevice {
  StorageDevice(this.path) {
    final api = SEDManagerCAPI();
    final pathNative = path.toNativeUtf8();
    handle = api.storageDeviceCreate(pathNative.cast<Char>());
    malloc.free(pathNative);
    if (handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
  }

  final _capi = SEDManagerCAPI();
  late final Handle handle;
  final String path;

  void dispose() {
    final api = SEDManagerCAPI();
    api.storageDeviceRelease(handle);
  }

  String getName() {
    final chars = _capi.storageDeviceGetName(handle);
    if (chars == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    return _capi.convertCString(chars);
  }

  String getSerial() {
    final capi = SEDManagerCAPI();
    final chars = capi.storageDeviceGetSerial(handle);
    if (chars == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    return _capi.convertCString(chars);
  }
}

List<StorageDevice> enumerateStorageDevices() {
  final capi = SEDManagerCAPI();
  final chars = capi.enumerateStorageDevices();

  if (chars == nullptr) {
    throw SEDException(getLastErrorMessage());
  }
  try {
    final str = chars.cast<Utf8>().toDartString();
    final paths = str.split(';');
    paths.retainWhere((element) => element.isNotEmpty);

    var devices = <StorageDevice>[];
    for (var path in paths) {
      try {
        devices.add(StorageDevice(path));
      } catch (ex) {
        // Ignore devices that failed to open.
      }
    }
    return devices;
  } finally {
    capi.stringRelease(chars.cast());
  }
}
