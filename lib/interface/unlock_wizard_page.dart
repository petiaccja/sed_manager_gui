import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'components/encrypted_device_builder.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';

class UnlockerPage extends StatelessWidget {
  const UnlockerPage(this.storageDevice, {super.key});

  final StorageDevice storageDevice;

  Widget _buildBody(BuildContext context) {
    return EncryptedDeviceBuilder(storageDevice, builder: (context, encryptedDevice) {
      return const Placeholder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unlock drive"),
      ),
      body: _buildBody(context),
    );
  }
}
