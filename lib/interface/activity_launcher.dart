import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/table_editor.dart';
import 'package:sed_manager_gui/interface/error_popup.dart';
import 'unlocker.dart';

class ActivityLauncherPage extends StatelessWidget {
  const ActivityLauncherPage(this.device, {super.key});

  final StorageDevice device;

  void launchActivity(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: builder,
      ),
    );
  }

  void launchEditTables(BuildContext context) {
    launchActivity(context, (BuildContext context) => TableEditorPage(device));
  }

  void launchUnlock(BuildContext context) {
    launchActivity(context, (BuildContext context) => UnlockerPage(device));
  }

  Widget launcherButton(BuildContext context, void Function()? callback, String caption, IconData? icon) {
    var colorScheme = Theme.of(context).colorScheme;
    var text = Text(caption, style: const TextStyle(fontSize: 18));
    var face = icon != null
        ? Wrap(
            direction: Axis.horizontal,
            children: [Icon(icon, color: colorScheme.onPrimary), const SizedBox(width: 4), text])
        : text;
    return FilledButton(onPressed: callback, child: face);
  }

  Widget launcherGroup(BuildContext context, List<(void Function()?, String, IconData?)> launchers) {
    var buttons = launchers.map((launcher) {
      return launcherButton(context, launcher.$1, launcher.$2, launcher.$3);
    });
    return Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        width: double.infinity,
        child:
            Wrap(alignment: WrapAlignment.start, direction: Axis.horizontal, spacing: 16, children: buttons.toList()));
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    late final String title = "${device.getName()} (${device.getSerial()})";

    final groupExpert = launcherGroup(context, [
      (
        () {
          launchEditTables(context);
        },
        "Edit tables",
        Icons.table_chart
      ),
    ]);

    final groupGuided = launcherGroup(context, [
      (null, "Configure locking", Icons.lock),
      (null, "Change password", Icons.password),
      (null, "Factory reset", Icons.undo)
    ]);

    final groupPba = launcherGroup(context, [
      (
        () {
          launchUnlock(context);
        },
        "Unlock",
        Icons.lock_open
      )
    ]);

    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(children: [
          groupExpert,
          groupGuided,
          groupPba,
        ]));
  }
}
