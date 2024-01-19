import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/encrypted_device_builder.dart';
import 'package:sed_manager_gui/interface/error_strip.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';

class StackResetPage extends StatelessWidget {
  StackResetPage(this.storageDevice, {super.key});
  final StorageDevice storageDevice;

  static Future<void> _stackReset(EncryptedDevice encryptedDevice) async {
    await encryptedDevice.stackReset();
  }

  Widget _buildBody(EncryptedDevice encryptedDevice) {
    final result = request(() => _stackReset(encryptedDevice));
    return RequestBuilder(
      request: result,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 48, height: 48, child: CircularProgressIndicator()),
                Text("Resetting stack..."),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ErrorStrip.error("Stack reset failed"),
                  const SizedBox(height: 6),
                  Text(snapshot.error!.toString()),
                ],
              ),
            ),
          );
        }
        return const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [ErrorStrip.success(), Text("Stack reset succesful")],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stack reset")),
      body: EncryptedDeviceBuilder(
        storageDevice,
        builder: (BuildContext context, EncryptedDevice encryptedDevice) {
          return _buildBody(encryptedDevice);
        },
      ),
    );
  }
}
