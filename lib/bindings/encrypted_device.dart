import 'dart:core';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'future.dart';
import 'storage_device.dart';
import 'string.dart';
import 'value.dart';
import 'type.dart';
import 'sedmanager_capi.dart';

typedef UID = int;

class EncryptedDevice {
  EncryptedDevice(this._handle);

  static Future<EncryptedDevice> create(StorageDevice storageDevice) {
    final futurePtr = _capi.encryptedDeviceCreate(storageDevice.handle());
    final futureWrapper = FutureWrapperEncryptedDevice(futurePtr);
    return futureWrapper.toDartFuture();
  }

  static final _capi = SEDManagerCAPI();
  final Pointer<CEncryptedDevice> _handle;

  void dispose() {
    _capi.encryptedDeviceDestroy(_handle);
  }

  Future<void> login(UID securityProvider) {
    final futurePtr = _capi.encryptedDeviceLogin(_handle, securityProvider);
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> end() {
    final futurePtr = _capi.encryptedDeviceEnd(_handle);
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<String> findName(UID uid, {UID securityProvider = 0}) {
    final futurePtr = _capi.encryptedDeviceFindName(_handle, uid, securityProvider);
    final futureWrapper = FutureWrapperString(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<UID> findUid(String name, {UID securityProvider = 0}) {
    final nameWrapper = StringWrapper.fromString(name);
    final futurePtr = _capi.encryptedDeviceFindUID(_handle, nameWrapper.handle(), securityProvider);
    final futureWrapper = FutureWrapperUID(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Stream<UID> getTableRows(UID tableUid) {
    final streamPtr = _capi.encryptedDeviceGetTableRows(_handle, tableUid);
    final streamWrapper = StreamWrapperUID(streamPtr);
    return streamWrapper.toDartStream();
  }

  int getColumnCount(UID table) {
    return _capi.encryptedDeviceGetColumnCount(_handle, table);
  }

  String getColumnName(UID table, int column) {
    return StringWrapper(_capi.encryptedDeviceGetColumnName(_handle, table, column)).toDartString();
  }

  Type getColumnType(UID table, int column) {
    return Type(_capi.encryptedDeviceGetColumnType(_handle, table, column));
  }

  Future<Value> getValue(UID objectUid, int column) {
    final futurePtr = _capi.encryptedDeviceGetValue(_handle, objectUid, column);
    final futureWrapper = FutureWrapperValue(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> setValue(UID objectUid, int column, Value value) {
    final futurePtr = _capi.encryptedDeviceSetValue(_handle, objectUid, column, value.handle());
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> authenticate(UID authority, String? password) {
    final bytes = password?.toNativeUtf8();
    final futurePtr = _capi.encryptedDeviceAuthenticate(
      _handle,
      authority,
      bytes?.cast<Uint8>() ?? nullptr,
      bytes?.length ?? 0,
    );
    if (bytes != null) {
      malloc.free(bytes);
    }
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> genMEK(UID lockingRange) {
    final futurePtr = _capi.encryptedDeviceGenMEK(_handle, lockingRange);
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  String renderValue(Value value, Type type, UID securityProvider) {
    final wrapper = StringWrapper(_capi.encryptedDeviceRenderValue(
      _handle,
      value.handle(),
      type.handle(),
      securityProvider,
    ));
    return wrapper.toDartString();
  }

  Value parseValue(String str, Type type, UID securityProvider) {
    final wrapper = StringWrapper.fromString(str);
    return Value(_capi.encryptedDeviceParseValue(
      _handle,
      wrapper.handle(),
      type.handle(),
      securityProvider,
    ));
  }

  Future<void> stackReset() {
    final futurePtr = _capi.encryptedDeviceStackReset(_handle);
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> revert(UID securityProvider) {
    final futurePtr = _capi.encryptedDeviceRevert(_handle, securityProvider);
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }
}
