import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import "encrypted_device_builder.dart";
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Unlock drive",
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
      body: _buildBody(context),
    );
  }
}
