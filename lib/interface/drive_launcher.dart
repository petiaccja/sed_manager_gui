import 'package:flutter/material.dart';
import 'package:sed_manager_gui/interface/activity_launcher.dart';
import '../bindings/storage_device.dart';

class DriveLauncherPage extends StatefulWidget {
  const DriveLauncherPage(this.onFinished, {super.key});

  final void Function() onFinished;

  @override
  State<DriveLauncherPage> createState() => _DriveLauncherPageState();
}

class _DriveLauncherPageState extends State<DriveLauncherPage> {
  List<StorageDevice> storageDevices = [];

  @override
  void dispose() {
    for (var storageDevice in storageDevices) {
      storageDevice.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    storageDevices = enumerateStorageDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final buttons = storageDevices.map((device) {
      final text = "${device.getName()}\n${device.getSerial()}";
      return FilledButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ActivityLauncherPage(device),
            ),
          );
        },
        child: Text(text, textAlign: TextAlign.center),
      );
    });

    final appBar = AppBar(
      backgroundColor: colorScheme.primary,
      title: Text(
        "Storage devices",
        style: TextStyle(color: colorScheme.onPrimary),
      ),
    );

    final body = Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 16,
        children: buttons.toList(),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}
