import "dart:async";
import "encrypted_device.dart";
import "string.dart";
import "errors.dart";
import "value.dart";
import "sedmanager_capi.dart";
import "dart:ffi";

class FutureWrapperVoid implements Finalizable {
  FutureWrapperVoid(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "Void";
  static final _destroyAddress = _capi.lookupFutureDestroy<Void>(_suffix);
  static final _startFunc = _capi.lookupFutureStart<Void, Pointer<Void>>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CFuture<Void>> _handle;

  Future<void> toDartFuture() {
    assert(_handle != nullptr);
    final completer = Completer<void>();

    late final NativeCallable<Void Function(Bool, Pointer<Void>)> callable;
    void callback(bool success, Pointer<Void> result) {
      if (!success) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete();
      }
      callable.close();
    }

    callable = NativeCallable<Void Function(Bool, Pointer<Void>)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return completer.future;
  }
}

class FutureWrapperString implements Finalizable {
  FutureWrapperString(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "String";
  static final _destroyAddress = _capi.lookupFutureDestroy<CString>(_suffix);
  static final _startFunc = _capi.lookupFutureStart<CString, Pointer<CString>>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CFuture<CString>> _handle;

  Future<String> toDartFuture() {
    assert(_handle != nullptr);
    final completer = Completer<String>();

    late final NativeCallable<Void Function(Bool, Pointer<CString>)> callable;
    void callback(bool success, Pointer<CString> result) {
      if (!success) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete(StringWrapper(result).toDartString());
      }
      callable.close();
    }

    callable = NativeCallable<Void Function(Bool, Pointer<CString>)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return completer.future;
  }
}

class FutureWrapperEncryptedDevice implements Finalizable {
  FutureWrapperEncryptedDevice(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "EncryptedDevice";
  static final _destroyAddress = _capi.lookupFutureDestroy<CEncryptedDevice>(_suffix);
  static final _startFunc = _capi.lookupFutureStart<CEncryptedDevice, Pointer<CEncryptedDevice>>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CFuture<CEncryptedDevice>> _handle;

  Future<EncryptedDevice> toDartFuture() {
    assert(_handle != nullptr);
    final completer = Completer<EncryptedDevice>();

    late final NativeCallable<Void Function(Bool, Pointer<CEncryptedDevice>)> callable;
    void callback(bool success, Pointer<CEncryptedDevice> result) {
      if (!success) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete(EncryptedDevice(result));
      }
      callable.close();
    }

    callable = NativeCallable<Void Function(Bool, Pointer<CEncryptedDevice>)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return completer.future;
  }
}

class FutureWrapperUID implements Finalizable {
  FutureWrapperUID(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "UID";
  static final _destroyAddress = _capi.lookupFutureDestroy<CUID>(_suffix);
  static final _startFunc = _capi.lookupFutureStart<CUID, CUID>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CFuture<CUID>> _handle;

  Future<UID> toDartFuture() {
    assert(_handle != nullptr);
    final completer = Completer<UID>();

    late final NativeCallable<Void Function(Bool, CUID)> callable;
    void callback(bool success, UID result) {
      if (!success) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete(result);
      }
      callable.close();
    }

    callable = NativeCallable<Void Function(Bool, CUID)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return completer.future;
  }
}

class FutureWrapperValue implements Finalizable {
  FutureWrapperValue(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "Value";
  static final _destroyAddress = _capi.lookupFutureDestroy<CValue>(_suffix);
  static final _startFunc = _capi.lookupFutureStart<CValue, Pointer<CValue>>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CFuture<CValue>> _handle;

  Future<Value> toDartFuture() {
    assert(_handle != nullptr);
    final completer = Completer<Value>();

    late final NativeCallable<Void Function(Bool, Pointer<CValue>)> callable;
    void callback(bool success, Pointer<CValue> result) {
      if (!success) {
        completer.completeError(SEDException(getLastErrorMessage()));
      } else {
        completer.complete(Value(result));
      }
      callable.close();
    }

    callable = NativeCallable<Void Function(Bool, Pointer<CValue>)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return completer.future;
  }
}

class StreamWrapperUID implements Finalizable {
  StreamWrapperUID(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "UID";
  static final _destroyAddress = _capi.lookupStreamDestroy<CUID>(_suffix);
  static final _startFunc = _capi.lookupStreamStart<CUID, CUID>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CStream<CUID>> _handle;

  Stream<UID> toDartStream() {
    assert(_handle != nullptr);
    final controller = StreamController<UID>();

    late final NativeCallable<Void Function(Bool, Bool, CUID)> callable;
    void callback(bool valid, bool success, UID result) {
      if (valid) {
        if (success) {
          controller.add(result);
        } else {
          controller.addError(SEDException(getLastErrorMessage()));
        }
      } else {
        controller.close();
        callable.close();
      }
    }

    callable = NativeCallable<Void Function(Bool, Bool, CUID)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return controller.stream;
  }
}

class StreamWrapperString implements Finalizable {
  StreamWrapperString(this._handle) {
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  static final _capi = SEDManagerCAPI();
  static const _suffix = "String";
  static final _destroyAddress = _capi.lookupStreamDestroy<Pointer<CString>>(_suffix);
  static final _startFunc = _capi.lookupStreamStart<CString, Pointer<CString>>(_suffix);
  static final _finalizer = NativeFinalizer(_destroyAddress.cast());
  Pointer<CStream<CString>> _handle;

  Stream<String> toDartStream() {
    assert(_handle != nullptr);
    final controller = StreamController<String>();

    late final NativeCallable<Void Function(Bool, Bool, Pointer<CString>)> callable;
    void callback(bool valid, bool success, Pointer<CString> result) {
      if (valid) {
        if (success) {
          controller.add(StringWrapper(result).toDartString());
        } else {
          controller.addError(SEDException(getLastErrorMessage()));
        }
      } else {
        controller.close();
        callable.close();
      }
    }

    callable = NativeCallable<Void Function(Bool, Bool, Pointer<CString>)>.listener(callback);

    _startFunc(_handle, callable.nativeFunction);
    _handle = nullptr;
    return controller.stream;
  }
}
