import 'dart:async';
import 'dart:core';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'sedmanager_capi.dart';

typedef UID = int;

class EncryptedDevice {
  static final _capi = SEDManagerCAPI();

  EncryptedDevice(StorageDevice storageDevice) {
    handle = _capi.encryptedDeviceCreate(storageDevice.handle);
    if (handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
  }

  EncryptedDevice.fromHandle(this.handle);

  late final Handle handle;

  void dispose() {
    _capi.encryptedDeviceRelease(handle);
  }

  static Future<EncryptedDevice> start(StorageDevice storageDevice) {
    final completer = Completer<EncryptedDevice>();

    late final NativeCallable<CallbackHandle> callable;
    void callback(int statusCode, Handle result) {
      if (statusCode != 0) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete(EncryptedDevice.fromHandle(result));
      }
      callable.close();
    }

    callable = NativeCallable<CallbackHandle>.listener(callback);
    _capi.encryptedDeviceStart(storageDevice.handle, callable.nativeFunction);

    return completer.future;
  }

  Future<void> login(UID securityProvider) {
    final completer = Completer<void>();

    late final NativeCallable<CallbackVoid> callable;
    void callback(int statusCode) {
      if (statusCode != 0) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete();
      }
      callable.close();
    }

    callable = NativeCallable<CallbackVoid>.listener(callback);
    _capi.encryptedDeviceLogin(
        handle, callable.nativeFunction, securityProvider);

    return completer.future;
  }

  Future<void> end() {
    final completer = Completer<void>();

    late final NativeCallable<CallbackVoid> callable;
    void callback(int statusCode) {
      if (statusCode != 0) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete();
      }
      callable.close();
    }

    callable = NativeCallable<CallbackVoid>.listener(callback);
    _capi.encryptedDeviceEnd(handle, callable.nativeFunction);

    return completer.future;
  }

  Future<String?> findName(UID uid, {UID securityProvider = 0}) {
    final completer = Completer<String?>();

    late final NativeCallable<CallbackString> callable;
    void callback(int statusCode, Pointer<Utf8> result) {
      if (statusCode != 0) {
        completer.complete(null);
      } else {
        final converted = result.toDartString();
        completer.complete(converted);
        if (result != nullptr) {
          _capi.stringRelease(result.cast());
        }
      }
      callable.close();
    }

    callable = NativeCallable<CallbackString>.listener(callback);
    _capi.encryptedDeviceFindName(
        handle, callable.nativeFunction, uid, securityProvider);

    return completer.future;
  }

  Future<UID?> findUid(String name, {UID securityProvider = 0}) {
    final completer = Completer<UID?>();

    late final NativeCallable<CallbackUid> callable;
    void callback(int statusCode, int result) {
      if (statusCode != 0) {
        completer.complete(null);
      } else {
        completer.complete(result);
      }
      callable.close();
    }

    callable = NativeCallable<CallbackUid>.listener(callback);
    final namePtr = name.toNativeUtf8();
    _capi.encryptedDeviceFindUid(
        handle, callable.nativeFunction, namePtr, securityProvider);
    malloc.free(namePtr);

    return completer.future;
  }

  Stream<UID> getTableRows(UID tableUid) {
    final controller = StreamController<UID>();

    late final NativeCallable<CallbackUid> callable;
    void callback(int statusCode, int result) {
      if (statusCode != 0) {
        controller.addError(SEDException(getLastErrorMessage()));
      }
      if (result != 0) {
        controller.add(result);
      } else {
        controller.close();
        callable.close();
      }
    }

    callable = NativeCallable<CallbackUid>.listener(callback);
    _capi.encryptedDeviceGetTableRows(
        handle, callable.nativeFunction, tableUid);

    return controller.stream;
  }

  Stream<String> getTableColumns(UID tableUid) {
    final controller = StreamController<String>();

    late final NativeCallable<CallbackString> callable;
    void callback(int statusCode, Pointer<Utf8> result) {
      if (statusCode != 0) {
        controller.addError(SEDException(getLastErrorMessage()));
      }
      if (result != nullptr) {
        controller.add(result.toDartString());
        _capi.stringRelease(result.cast());
      } else {
        controller.close();
        callable.close();
      }
    }

    callable = NativeCallable<CallbackString>.listener(callback);
    _capi.encryptedDeviceGetTableColumns(
        handle, callable.nativeFunction, tableUid);

    return controller.stream;
  }

  Future<String> getObjectColumn(
    UID tableUid,
    UID objectUid,
    int column, {
    UID securityProvider = 0,
  }) {
    final completer = Completer<String>();

    late final NativeCallable<CallbackString> callable;
    void callback(int statusCode, Pointer<Utf8> result) {
      if (statusCode != 0) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        final converted = result.toDartString();
        completer.complete(converted);
        if (result != nullptr) {
          _capi.stringRelease(result.cast());
        }
      }
      callable.close();
    }

    callable = NativeCallable<CallbackString>.listener(callback);
    _capi.encryptedDeviceGetObjectColumn(handle, callable.nativeFunction,
        securityProvider, tableUid, objectUid, column);

    return completer.future;
  }

  Future<void> setObjectColumn(
    UID tableUid,
    UID objectUid,
    int column,
    String value, {
    UID securityProvider = 0,
  }) {
    final completer = Completer<void>();

    late final NativeCallable<CallbackVoid> callable;
    void callback(int statusCode) {
      if (statusCode != 0) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete();
      }
      callable.close();
    }

    callable = NativeCallable<CallbackVoid>.listener(callback);
    final valuePtr = value.toNativeUtf8();
    _capi.encryptedDeviceSetObjectColumn(handle, callable.nativeFunction,
        securityProvider, tableUid, objectUid, column, valuePtr);
    malloc.free(valuePtr);

    return completer.future;
  }
}
