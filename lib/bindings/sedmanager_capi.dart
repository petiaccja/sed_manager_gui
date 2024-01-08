// TODO:
// Use native finalizers.
// This would help with this dispose hell...
// Then I could define multiple wrapper classes properly:
//  - StorageDevice
//  - EncryptedDevice -> must still be dispose()-ed
//  - Value
//  - Type
//  - Future_Void / Future_String / Future_UID / Future_Value
// https://api.dart.dev/stable/3.2.4/dart-ffi/NativeFinalizer-class.html

import 'dart:ffi';
import 'dart:html';
import 'package:ffi/ffi.dart';

const libraryPath =
    r"D:\Programming\SEDManager\build\Debug\bin\SEDManagerCAPI.dll";

typedef CUID = Uint64;

final class CString extends Opaque {}

final class CValue extends Opaque {}

final class CStorageDevice extends Opaque {}

final class CEncryptedDevice extends Opaque {}

final class CFuture<T> extends Opaque {}

final class CStream<T> extends Opaque {}

typedef CFutureVoid = CFuture<Void>;

typedef CFutureEncryptedDevice = CFuture<CEncryptedDevice>;

typedef CFutureValue = CFuture<CValue>;

typedef CStreamUid = CStream<CUID>;

typedef CStreamString = CStream<CUID>;

typedef CCallback<T> = Void Function(T);

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

  //----------------------------------------------------------------------------
  // Error handling
  //----------------------------------------------------------------------------

  final getLastExceptionMessage = dylib
      .lookupFunction<Pointer<CString> Function(), Pointer<CString> Function()>(
    "CGetLastException_Message",
    isLeaf: true,
  );

  //----------------------------------------------------------------------------
  // CString
  //----------------------------------------------------------------------------

  final stringCreate = dylib
      .lookupFunction<Pointer<CString> Function(), Pointer<CString> Function()>(
    "CString_Create",
    isLeaf: true,
  );

  final stringDestroy = dylib.lookupFunction<Void Function(Pointer<CString>),
      void Function(Pointer<CString>)>(
    "CString_Destroy",
    isLeaf: true,
  );

  final stringSet = dylib.lookupFunction<
      Void Function(Pointer<CString>, Pointer<Utf8>),
      void Function(Pointer<CString>, Pointer<Utf8>)>(
    "CString_Set",
    isLeaf: true,
  );

  final stringGet = dylib.lookupFunction<
      Pointer<Utf8> Function(Pointer<CString>),
      Pointer<Utf8> Function(Pointer<CString>)>(
    "CString_Get",
    isLeaf: true,
  );

  //----------------------------------------------------------------------------
  // CValue
  //----------------------------------------------------------------------------

  final valueCreate = dylib
      .lookupFunction<Pointer<CValue> Function(), Pointer<CValue> Function()>(
    "CValue_Create",
    isLeaf: true,
  );

  final valueDestroy = dylib.lookupFunction<Void Function(Pointer<CValue>),
      void Function(Pointer<CValue>)>(
    "CValue_Destroy",
    isLeaf: true,
  );

  final valueIsBytes = dylib.lookupFunction<Bool Function(Pointer<CValue>),
      bool Function(Pointer<CValue>)>(
    "CValue_IsBytes",
    isLeaf: true,
  );

  final valueIsCommand = dylib.lookupFunction<Bool Function(Pointer<CValue>),
      bool Function(Pointer<CValue>)>(
    "CValue_IsCommand",
    isLeaf: true,
  );

  final valueIsInteger = dylib.lookupFunction<Bool Function(Pointer<CValue>),
      bool Function(Pointer<CValue>)>(
    "CValue_IsInteger",
    isLeaf: true,
  );

  final valueIsList = dylib.lookupFunction<Bool Function(Pointer<CValue>),
      bool Function(Pointer<CValue>)>(
    "CValue_IsList",
    isLeaf: true,
  );

  final valueIsNamed = dylib.lookupFunction<Bool Function(Pointer<CValue>),
      bool Function(Pointer<CValue>)>(
    "CValue_IsNamed",
    isLeaf: true,
  );

  final valueGetBytes = dylib.lookupFunction<
      Pointer<Int8> Function(Pointer<CValue>),
      Pointer<Int8> Function(Pointer<CValue>)>(
    "CValue_GetBytes",
    isLeaf: true,
  );

  final valueGetCommand = dylib.lookupFunction<Uint8 Function(Pointer<CValue>),
      int Function(Pointer<CValue>)>(
    "CValue_GetCommand",
    isLeaf: true,
  );

  final valueGetInteger = dylib.lookupFunction<Int64 Function(Pointer<CValue>),
      int Function(Pointer<CValue>)>(
    "CValue_GetInteger",
    isLeaf: true,
  );

  final valueGetListElement = dylib.lookupFunction<
      Pointer<CValue> Function(Pointer<CValue>, Size),
      Pointer<CValue> Function(Pointer<CValue>, int)>(
    "CValue_GetList_Element",
    isLeaf: true,
  );

  final valueGetNamedName = dylib.lookupFunction<
      Pointer<CValue> Function(Pointer<CValue>),
      Pointer<CValue> Function(Pointer<CValue>)>(
    "CValue_GetNamed_Name",
    isLeaf: true,
  );

  final valueGetNamedValue = dylib.lookupFunction<
      Pointer<CValue> Function(Pointer<CValue>),
      Pointer<CValue> Function(Pointer<CValue>)>(
    "CValue_GetNamed_Value",
    isLeaf: true,
  );

  final valueGetLength = dylib.lookupFunction<Size Function(Pointer<CValue>),
      int Function(Pointer<CValue>)>(
    "CValue_GetLength",
    isLeaf: true,
  );

  final valueSetBytes = dylib.lookupFunction<
      Void Function(Pointer<CValue>, Pointer<Int8>, Size),
      void Function(Pointer<CValue>, Pointer<Int8>, int)>(
    "CValue_SetBytes",
    isLeaf: true,
  );

  final valueSetCommand = dylib.lookupFunction<
      Void Function(Pointer<CValue>, Uint8),
      void Function(Pointer<CValue>, int)>(
    "CValue_SetCommand",
    isLeaf: true,
  );

  final valueSetInteger = dylib.lookupFunction<
      Void Function(Pointer<CValue>, Int64, Bool, Uint8),
      void Function(Pointer<CValue>, int, bool, int)>(
    "CValue_SetInteger",
    isLeaf: true,
  );

  final valueSetList = dylib.lookupFunction<
      Void Function(Pointer<CValue>, Pointer<Pointer<CValue>>, Size),
      void Function(Pointer<CValue>, Pointer<Pointer<CValue>>, int)>(
    "CValue_SetList",
    isLeaf: true,
  );

  final valueSetNamed = dylib.lookupFunction<
      Void Function(Pointer<CValue>, Pointer<CValue>, Pointer<CValue>),
      void Function(Pointer<CValue>, Pointer<CValue>, Pointer<CValue>)>(
    "CValue_SetNamed",
    isLeaf: true,
  );

  //----------------------------------------------------------------------------
  // CStorageDevice
  //----------------------------------------------------------------------------

  final enumerateStorageDevices = dylib
      .lookupFunction<Pointer<CString> Function(), Pointer<CString> Function()>(
    "CEnumerateStorageDevices",
    isLeaf: true,
  );

  final storageDeviceCreate = dylib.lookupFunction<
      Pointer<CStorageDevice> Function(Pointer<CString>),
      Pointer<CStorageDevice> Function(Pointer<CString>)>(
    "CStorageDevice_Create",
    isLeaf: true,
  );

  final storageDeviceDestroy = dylib.lookupFunction<
      Void Function(Pointer<CStorageDevice>),
      void Function(Pointer<CStorageDevice>)>(
    "CStorageDevice_Destroy",
    isLeaf: true,
  );

  final storageDeviceGetName = dylib.lookupFunction<
      Pointer<CString> Function(Pointer<CStorageDevice>),
      Pointer<CString> Function(Pointer<CStorageDevice>)>(
    "CStorageDevice_GetName",
    isLeaf: true,
  );

  final storageDeviceGetSerial = dylib.lookupFunction<
      Pointer<CString> Function(Pointer<CStorageDevice>),
      Pointer<CString> Function(Pointer<CStorageDevice>)>(
    "CStorageDevice_GetSerial",
    isLeaf: true,
  );

  //----------------------------------------------------------------------------
  // CEncryptedDevice
  //----------------------------------------------------------------------------

  final encryptedDeviceCreate = dylib.lookupFunction<
      Pointer<CFutureEncryptedDevice> Function(Pointer<CStorageDevice>),
      Pointer<CFutureEncryptedDevice> Function(Pointer<CStorageDevice>)>(
    "CEncryptedDevice_Create",
    isLeaf: true,
  );

  final encryptedDeviceDestroy = dylib.lookupFunction<
      Void Function(Pointer<CFutureEncryptedDevice>),
      void Function(Pointer<CFutureEncryptedDevice>)>(
    "CEncryptedDevice_Destroy",
    isLeaf: true,
  );

  final encryptedDeviceLogin = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_Login",
    isLeaf: true,
  );

  final encryptedDeviceAuthenticate = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(
          Pointer<CFutureEncryptedDevice>, CUID, Pointer<CString>),
      Pointer<CFutureVoid> Function(
          Pointer<CFutureEncryptedDevice>, int, Pointer<CString>)>(
    "CEncryptedDevice_Authenticate",
    isLeaf: true,
  );

  final encryptedDeviceStackReset = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>)>(
    "CEncryptedDevice_StackReset",
    isLeaf: true,
  );

  final encryptedDeviceReset = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>)>(
    "CEncryptedDevice_Reset",
    isLeaf: true,
  );

  final encryptedDeviceEnd = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>)>(
    "CEncryptedDevice_End",
    isLeaf: true,
  );

  final encryptedDeviceFindName = dylib.lookupFunction<
      Pointer<CString> Function(Pointer<CFutureEncryptedDevice>, CUID, CUID),
      Pointer<CString> Function(Pointer<CFutureEncryptedDevice>, int, int)>(
    "CEncryptedDevice_FindName",
    isLeaf: true,
  );

  final encryptedDeviceFindUid = dylib.lookupFunction<
      CUID Function(Pointer<CFutureEncryptedDevice>, Pointer<CString>, CUID),
      int Function(Pointer<CFutureEncryptedDevice>, Pointer<CString>, int)>(
    "CEncryptedDevice_FindUid",
    isLeaf: true,
  );

  final encryptedDeviceGetTableRows = dylib.lookupFunction<
      Pointer<CStreamUid> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CStreamUid> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_GetTableRows",
    isLeaf: true,
  );

  final encryptedDeviceGetTableColumns = dylib.lookupFunction<
      Pointer<CStreamString> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CStreamString> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_GetTableColumns",
    isLeaf: true,
  );

  final encryptedDeviceGetObjectColumn = dylib.lookupFunction<
      Pointer<CFutureValue> Function(
          Pointer<CFutureEncryptedDevice>, CUID, Int32),
      Pointer<CFutureValue> Function(
          Pointer<CFutureEncryptedDevice>, int, int)>(
    "CEncryptedDevice_GetObjectColumn",
    isLeaf: true,
  );

  final encryptedDeviceSetObjectColumn = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(
          Pointer<CFutureEncryptedDevice>, CUID, Int32, Pointer<CValue>),
      Pointer<CFutureVoid> Function(
          Pointer<CFutureEncryptedDevice>, int, int, Pointer<CValue>)>(
    "CEncryptedDevice_SetObjectColumn",
    isLeaf: true,
  );

  final encryptedDeviceGenMEK = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_GenMEK",
    isLeaf: true,
  );

  final encryptedDeviceRevert = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_Revert",
    isLeaf: true,
  );

  final encryptedDeviceActivate = dylib.lookupFunction<
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, CUID),
      Pointer<CFutureVoid> Function(Pointer<CFutureEncryptedDevice>, int)>(
    "CEncryptedDevice_Activate",
    isLeaf: true,
  );

  //----------------------------------------------------------------------------
  // Futures
  //----------------------------------------------------------------------------

  final futureVoidDestroyAddress =
      dylib.lookup<NativeFunction<Void Function(Pointer<CFutureVoid>)>>(
          "CFutureVoid_Destroy");
  late final futureVoidDestroy = futureVoidDestroyAddress
      .asFunction<void Function(Pointer<CFutureVoid>)>(isLeaf: false);
}
