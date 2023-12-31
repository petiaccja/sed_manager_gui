import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sed_manager_gui/bindings/errors.dart';

const libraryPath =
    "/home/petiaccja/Programming/SEDManager/build/Debug/lib/libSEDManagerCAPI.so";

typedef PChar = Pointer<Char>;
typedef Handle = Pointer<Void>;

class SEDManagerCAPI {
  SEDManagerCAPI._privateConstructor();

  static final SEDManagerCAPI _instance = _create();
  static final dylib = DynamicLibrary.open(libraryPath);

  factory SEDManagerCAPI() {
    return _instance;
  }

  static SEDManagerCAPI _create() {
    return SEDManagerCAPI._privateConstructor();
  }

  String convertCString(PChar chars) {
    try {
      return chars.cast<Utf8>().toDartString();
    } finally {
      releaseString(chars.cast());
    }
  }

  final getLastErrorMessage =
      dylib.lookupFunction<PChar Function(), PChar Function()>(
    "GetLastErrorMessage",
    isLeaf: true,
  );

  final enumerateStorageDevices =
      dylib.lookupFunction<PChar Function(), PChar Function()>(
    "EnumerateStorageDevices",
    isLeaf: true,
  );

  final releaseString =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseString",
    isLeaf: true,
  );

  final createStorageDevice =
      dylib.lookupFunction<Handle Function(PChar), Handle Function(PChar)>(
    "CreateStorageDevice",
    isLeaf: true,
  );

  final storageDeviceGetName =
      dylib.lookupFunction<PChar Function(Handle), PChar Function(Handle)>(
    "StorageDevice_GetName",
    isLeaf: true,
  );

  final storageDeviceGetSerial =
      dylib.lookupFunction<PChar Function(Handle), PChar Function(Handle)>(
    "StorageDevice_GetSerial",
    isLeaf: true,
  );

  final releaseStorageDevice =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseStorageDevice",
    isLeaf: true,
  );

  final createSEDManager =
      dylib.lookupFunction<Handle Function(Handle), Handle Function(Handle)>(
    "CreateSEDManager",
    isLeaf: true,
  );

  final releaseSEDManager =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseSEDManager",
    isLeaf: true,
  );

  final sedManagerStart = dylib.lookupFunction<Bool Function(Handle, Uint64),
      bool Function(Handle, int)>(
    "SEDManager_Start",
    isLeaf: true,
  );

  final sedManagerEnd =
      dylib.lookupFunction<Bool Function(Handle), bool Function(Handle)>(
    "SEDManager_End",
    isLeaf: true,
  );

  final sedManagerFindUid = dylib.lookupFunction<
      Uint64 Function(Handle, PChar, Uint64), int Function(Handle, PChar, int)>(
    "SEDManager_FindUID",
    isLeaf: true,
  );

  final sedManagerFindName = dylib.lookupFunction<
      PChar Function(Handle, Uint64, Uint64), PChar Function(Handle, int, int)>(
    "SEDManager_FindName",
    isLeaf: true,
  );

  final createTable = dylib.lookupFunction<Handle Function(Handle, Uint64),
      Handle Function(Handle, int)>(
    "CreateTable",
    isLeaf: true,
  );

  final releaseTable =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseTable",
    isLeaf: true,
  );

  final createTableIterator =
      dylib.lookupFunction<Handle Function(Handle), Handle Function(Handle)>(
    "CreateTableIterator",
    isLeaf: true,
  );

  final releaseTableIterator =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseTableIterator",
    isLeaf: true,
  );

  final tableIteratorNext =
      dylib.lookupFunction<Bool Function(Handle), bool Function(Handle)>(
    "TableIterator_Next",
    isLeaf: true,
  );

  final createObject =
      dylib.lookupFunction<Handle Function(Handle), Handle Function(Handle)>(
    "CreateObject",
    isLeaf: true,
  );

  final releaseObject =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "ReleaseObject",
    isLeaf: true,
  );

  final objectGetUid =
      dylib.lookupFunction<Uint64 Function(Handle), int Function(Handle)>(
    "Object_GetUID",
    isLeaf: true,
  );

  final objectGetColumnNames = dylib.lookupFunction<
      PChar Function(Handle, Size, Size), PChar Function(Handle, int, int)>(
    "Object_GetColumnNames",
    isLeaf: true,
  );

  final objectGetColumnValues = dylib.lookupFunction<
      PChar Function(Handle, Size, Size), PChar Function(Handle, int, int)>(
    "Object_GetColumnValues",
    isLeaf: true,
  );
}
