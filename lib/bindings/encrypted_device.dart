import 'dart:core';
import 'dart:ffi';
import 'future.dart';
import 'storage_device.dart';
import 'string.dart';
import 'value.dart';
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

  Future<String?> findName(UID uid, {UID securityProvider = 0}) {
    final futurePtr = _capi.encryptedDeviceFindName(_handle, uid, securityProvider);
    final futureWrapper = FutureWrapperString(futurePtr);
    final future = futureWrapper.toDartFuture();
    return future.then((value) async => value.isNotEmpty ? value : null);
  }

  Future<UID?> findUid(String name, {UID securityProvider = 0}) {
    final nameWrapper = StringWrapper.fromString(name);
    final futurePtr = _capi.encryptedDeviceFindUID(_handle, nameWrapper.handle(), securityProvider);
    final futureWrapper = FutureWrapperUID(futurePtr);
    final future = futureWrapper.toDartFuture();
    return future.then((value) async => value != 0 ? value : null);
  }

  Stream<UID> getTableRows(UID tableUid) {
    final streamPtr = _capi.encryptedDeviceGetTableRows(_handle, tableUid);
    final streamWrapper = StreamWrapperUID(streamPtr);
    return streamWrapper.toDartStream();
  }

  Stream<String> getTableColumns(UID tableUid) {
    final streamPtr = _capi.encryptedDeviceGetTableColumns(_handle, tableUid);
    final streamWrapper = StreamWrapperString(streamPtr);
    return streamWrapper.toDartStream();
  }

  Future<Value> getObjectColumn(UID tableUid, UID objectUid, int column) {
    final futurePtr = _capi.encryptedDeviceGetObjectColumn(_handle, objectUid, column);
    final futureWrapper = FutureWrapperValue(futurePtr);
    return futureWrapper.toDartFuture();
  }

  Future<void> setObjectColumn(UID tableUid, UID objectUid, int column, Value value) {
    final futurePtr = _capi.encryptedDeviceSetObjectColumn(_handle, objectUid, column, value.handle());
    final futureWrapper = FutureWrapperVoid(futurePtr);
    return futureWrapper.toDartFuture();
  }
}
