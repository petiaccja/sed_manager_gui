import "dart:ffi";
import "errors.dart";
import "sedmanager_capi.dart";

class Value implements Finalizable {
  Value(this._handle) {
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    _finalizer.attach(this, _handle.cast(), detach: this);
  }

  Value.empty() {
    _handle = _capi.valueCreate();
    if (_handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
  }

  static final _capi = SEDManagerCAPI();
  static final _finalizer = NativeFinalizer(_capi.valueDestroyAddress.cast());
  late Pointer<CValue> _handle;

  Pointer<CValue> handle() {
    return _handle;
  }

  bool get hasValue {
    return _capi.valueHasValue(_handle);
  }
}
