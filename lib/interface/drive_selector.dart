import 'package:flutter/material.dart';
import 'package:sed_manager_gui/interface/activity_launcher.dart';
import '../bindings/storage_device.dart';

class DriveSelectorPage extends StatefulWidget {
  const DriveSelectorPage(this.onFinished, {super.key});

  final void Function() onFinished;

  @override
  State<DriveSelectorPage> createState() => _DriveSelectorPageState();
}

class _DriveSelectorPageState extends State<DriveSelectorPage> {
  var devices = enumerateStorageDevices();

  @override
  void dispose() {
    for (var device in devices) {
      device.dispose();
    }
    super.dispose();
  }

  void refreshDevices() {
    devices = enumerateStorageDevices();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final buttons = devices.map((device) {
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

    final floatingButton = FloatingActionButton(
      onPressed: () {
        refreshDevices();
      },
      backgroundColor: colorScheme.primary,
      child: Icon(Icons.refresh, color: colorScheme.onPrimary),
    );

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingButton,
    );
  }
}
