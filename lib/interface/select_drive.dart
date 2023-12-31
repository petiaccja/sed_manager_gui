import 'package:flutter/material.dart';
import 'package:sed_manager_gui/interface/select_activity.dart';
import '../bindings/storage.dart';

class SelectDrivePage extends StatefulWidget {
  const SelectDrivePage(this.onFinished, {super.key});

  final void Function() onFinished;

  @override
  State<SelectDrivePage> createState() => _SelectDrivePageState();
}

class _SelectDrivePageState extends State<SelectDrivePage> {
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
              builder: (BuildContext context) => SelectActivityPage(device),
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
