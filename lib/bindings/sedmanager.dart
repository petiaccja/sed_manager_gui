import 'dart:collection';
import 'dart:core';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/storage.dart';
import 'sedmanager_capi.dart';

class Object {
  Object(this.handle);

  static final _capi = SEDManagerCAPI();
  final Handle handle;

  void dispose() {
    _capi.releaseObject(handle);
  }

  int uid() {
    final value = _capi.objectGetUid(handle);
    if (value == 0) {
      throw SEDException(getLastErrorMessage());
    }
    return value;
  }
}

class Table with IterableMixin<Object> {
  Table(this.handle);

  static final _capi = SEDManagerCAPI();
  final Handle handle;

  void dispose() {
    _capi.releaseTable(handle);
  }

  @override
  Iterator<Object> get iterator {
    final iteratorHandle = _capi.createTableIterator(handle);
    if (iteratorHandle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    return TableIterator(iteratorHandle);
  }
}

class TableIterator implements Iterator<Object> {
  TableIterator(this.handle);

  static final _capi = SEDManagerCAPI();
  Handle handle;

  void dispose() {
    _capi.releaseTableIterator(handle);
  }

  @override
  Object get current {
    final objectHandle = _capi.createObject(handle);
    if (objectHandle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    return Object(objectHandle);
  }

  @override
  bool moveNext() {
    if (handle != nullptr) {
      final valid = _capi.tableIteratorNext(handle);
      if (!valid) {
        dispose();
        handle = nullptr;
      }
      return valid;
    }
    return false;
  }
}

class SEDManager {
  static final _capi = SEDManagerCAPI();

  SEDManager(StorageDevice storageDevice) {
    handle = _capi.createSEDManager(storageDevice.handle);
    if (handle == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
  }

  late final Handle handle;

  void dispose() {
    final capi = SEDManagerCAPI();
    capi.releaseSEDManager(handle);
  }

  String? findName(int uid, int? sp) {
    final chars = _capi.sedManagerFindName(handle, uid, sp ?? 0);
    if (chars == nullptr) {
      return null;
    }
    return _capi.convertCString(chars);
  }

  int? findUid(String name, int? sp) {
    final chars = name.toNativeUtf8();
    final uid = _capi.sedManagerFindUid(handle, chars.cast<Char>(), sp ?? 0);
    malloc.free(chars);
    if (uid == 0) {
      return null;
    }
    return uid;
  }

  void start(int sp) {
    if (!_capi.sedManagerStart(handle, sp)) {
      throw SEDException(getLastErrorMessage());
    }
  }

  void end() {
    _capi.sedManagerEnd(handle);
  }

  Table getTable(int uid) {
    final table = _capi.createTable(handle, uid);
    if (table == nullptr) {
      throw SEDException(getLastErrorMessage());
    }
    return Table(table);
  }
}
