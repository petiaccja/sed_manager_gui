import "dart:ffi";
import "dart:typed_data";
import "package:ffi/ffi.dart";

import "errors.dart";
import "sedmanager_capi.dart";

class Value implements Finalizable {
  Value(this._handle) {
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  Value.empty() : _handle = _capi.valueCreate() {
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
  }

  Value.bytes(ByteData data) : _handle = _capi.valueCreate() {
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    final length = data.lengthInBytes;
    final ptr = malloc.allocate<Uint8>(length);
    final bytes = ptr.asTypedList(length);
    for (int i = 0; i < length; ++i) {
      bytes[i] = data.buffer.asUint8List()[i];
    }
    _capi.valueSetBytes(_handle, ptr, length);
    malloc.free(ptr);
  }

  Value.integer(int value, int width, bool signed) : _handle = _capi.valueCreate() {
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    _capi.valueSetInteger(_handle, value, width, signed);
  }

  static final _capi = SEDManagerCAPI();
  static final _finalizer = NativeFinalizer(_capi.valueDestroyAddress.cast());
  final Pointer<CValue> _handle;

  bool get hasValue {
    return _capi.valueHasValue(_handle);
  }

  bool get isBytes {
    return _capi.valueIsBytes(_handle);
  }

  bool get isInteger {
    return _capi.valueIsInteger(_handle);
  }

  ByteData getBytes() {
    if (isBytes) {
      final data = _capi.valueGetBytes(_handle);
      final length = _capi.valueGetLength(_handle);
      return data.asTypedList(length).buffer.asByteData();
    }
    throw SEDException("value is not a byte array");
  }

  int getInteger() {
    if (isInteger) {
      return _capi.valueGetInteger(_handle);
    }
    throw SEDException("value is not an integer");
  }

  Pointer<CValue> handle() {
    return _handle;
  }
}
