import 'dart:async';
import 'package:flutter/material.dart';
import "package:sed_manager_gui/bindings/encrypted_device.dart";
import "package:sed_manager_gui/bindings/storage_device.dart";
import 'request_queue.dart';
import 'result_indicator.dart';

class EncryptedDeviceBuilder extends StatefulWidget {
  const EncryptedDeviceBuilder(
    this.storageDevice, {
    required this.builder,
    super.key,
  });
  final StorageDevice storageDevice;
  final Widget Function(BuildContext context, EncryptedDevice encryptedDevice) builder;

  @override
  State<EncryptedDeviceBuilder> createState() => _EncryptedDeviceBuilderState();
}

class _EncryptedDeviceBuilderState extends State<EncryptedDeviceBuilder> {
  late final Request<EncryptedDevice> encryptedDevice = request(_getEncryptedDevice);

  @override
  void dispose() {
    request(() async {
      try {
        final result = await encryptedDevice.future;
        await result.end();
        result.dispose();
      } catch (ex) {}
    });
    super.dispose();
  }

  Future<EncryptedDevice> _getEncryptedDevice() async {
    return await EncryptedDevice.create(widget.storageDevice);
  }

  Widget _buildWithData(BuildContext context, EncryptedDevice encryptedDevice) {
    return widget.builder(context, encryptedDevice);
  }

  Widget _buildWithError(Object error) {
    return Material(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.75,
          child: Center(
            child: ErrorStrip.error(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildWaiting() {
    return const Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
            Text("Opening device..."),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: encryptedDevice,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
      },
    );
  }
}
