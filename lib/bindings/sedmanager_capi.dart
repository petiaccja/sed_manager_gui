import 'dart:ffi';
import 'package:ffi/ffi.dart';

const libraryPath =
    r"D:\Programming\SEDManager\build\Debug\bin\SEDManagerCAPI.dll";

typedef PChar = Pointer<Char>;
typedef Handle = Pointer<Void>;
typedef CallbackVoid = Void Function(Uint32);
typedef CallbackString = Void Function(Uint32, Pointer<Utf8>);
typedef CallbackUid = Void Function(Uint32, Uint64);
typedef CallbackHandle = Void Function(Uint32, Handle);

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
      stringRelease(chars.cast());
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

  final stringRelease =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "String_Release",
    isLeaf: true,
  );

  final storageDeviceCreate =
      dylib.lookupFunction<Handle Function(PChar), Handle Function(PChar)>(
    "StorageDevice_Create",
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

  final storageDeviceRelease =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "StorageDevice_Release",
    isLeaf: true,
  );

  final encryptedDeviceCreate =
      dylib.lookupFunction<Handle Function(Handle), Handle Function(Handle)>(
    "EncryptedDevice_Create",
    isLeaf: true,
  );

  final encryptedDeviceStart = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackHandle>>),
      void Function(Handle, Pointer<NativeFunction<CallbackHandle>>)>(
    "EncryptedDevice_Start",
    isLeaf: false,
  );

  final encryptedDeviceRelease =
      dylib.lookupFunction<Void Function(Handle), void Function(Handle)>(
    "EncryptedDevice_Release",
    isLeaf: true,
  );

  final encryptedDeviceLogin = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackVoid>>, Uint64),
      void Function(Handle, Pointer<NativeFunction<CallbackVoid>>, int)>(
    "EncryptedDevice_Login",
    isLeaf: false,
  );

  final encryptedDeviceEnd = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackVoid>>),
      void Function(Handle, Pointer<NativeFunction<CallbackVoid>>)>(
    "EncryptedDevice_End",
    isLeaf: false,
  );

  final encryptedDeviceFindName = dylib.lookupFunction<
      Void Function(
          Handle, Pointer<NativeFunction<CallbackString>>, Uint64, Uint64),
      void Function(Handle, Pointer<NativeFunction<CallbackString>>, int, int)>(
    "EncryptedDevice_FindName",
    isLeaf: false,
  );

  final encryptedDeviceFindUid = dylib.lookupFunction<
      Void Function(
          Handle, Pointer<NativeFunction<CallbackUid>>, Pointer<Utf8>, Uint64),
      void Function(
          Handle, Pointer<NativeFunction<CallbackUid>>, Pointer<Utf8>, int)>(
    "EncryptedDevice_FindUid",
    isLeaf: false,
  );

  final encryptedDeviceGetTableRows = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackUid>>, Uint64),
      void Function(Handle, Pointer<NativeFunction<CallbackUid>>, int)>(
    "EncryptedDevice_GetTableRows",
    isLeaf: false,
  );

  final encryptedDeviceGetTableColumns = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackString>>, Uint64),
      void Function(Handle, Pointer<NativeFunction<CallbackString>>, int)>(
    "EncryptedDevice_GetTableColumns",
    isLeaf: false,
  );

  final encryptedDeviceGetObjectColumn = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackString>>, Uint64,
          Uint64, Uint64, Uint32),
      void Function(
          Handle, Pointer<NativeFunction<CallbackString>>, int, int, int, int)>(
    "EncryptedDevice_GetObjectColumn",
    isLeaf: false,
  );

  final encryptedDeviceSetObjectColumn = dylib.lookupFunction<
      Void Function(Handle, Pointer<NativeFunction<CallbackVoid>>, Uint64,
          Uint64, Uint64, Uint32, Pointer<Utf8>),
      void Function(Handle, Pointer<NativeFunction<CallbackVoid>>, int, int,
          int, int, Pointer<Utf8>)>(
    "EncryptedDevice_SetObjectColumn",
    isLeaf: false,
  );
}
