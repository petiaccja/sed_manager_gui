import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/sedmanager.dart';
import 'package:sed_manager_gui/bindings/storage.dart';
import 'package:sed_manager_gui/interface/edit_tables.dart';
import 'package:sed_manager_gui/interface/error_popup.dart';
import 'unlock.dart';

class SelectActivityPage extends StatelessWidget {
  const SelectActivityPage(this.device, {super.key});

  final StorageDevice device;

  void launchActivity(
      BuildContext context, Widget Function(BuildContext) builder) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: builder,
      ),
    );
  }

  void launchEditTables(BuildContext context) {
    try {
      var manager = SEDManager(device);
      launchActivity(
          context, (BuildContext context) => EditTablesPage(manager));
    } on Exception catch (ex) {
      showDialog(
          context: context,
          builder: (context) => ErrorPopupPage(ex.toString()));
    }
  }

  void launchUnlock(BuildContext context) {
    try {
      var manager = SEDManager(device);
      launchActivity(context, (BuildContext context) => UnlockPage(manager));
    } on SEDException catch (ex) {
      showDialog(
          context: context, builder: (context) => ErrorPopupPage(ex.message));
    }
  }

  Widget launcherButton(BuildContext context, void Function()? callback,
      String caption, IconData? icon) {
    var colorScheme = Theme.of(context).colorScheme;
    var text = Text(caption, style: const TextStyle(fontSize: 18));
    var face = icon != null
        ? Wrap(direction: Axis.horizontal, children: [
            Icon(icon, color: colorScheme.inversePrimary),
            const SizedBox(width: 4),
            text
          ])
        : text;
    return FilledButton(onPressed: callback, child: face);
  }

  Widget launcherGroup(BuildContext context,
      List<(void Function()?, String, IconData?)> launchers) {
    var buttons = launchers.map((launcher) {
      return launcherButton(context, launcher.$1, launcher.$2, launcher.$3);
    });
    return Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        width: double.infinity,
        child: Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            spacing: 16,
            children: buttons.toList()));
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
        appBar: AppBar(
            title: Text(title, style: TextStyle(color: colorScheme.onPrimary)),
            backgroundColor: colorScheme.primary),
        body: Column(children: [
          groupExpert,
          groupGuided,
          groupPba,
        ]));
  }
}
