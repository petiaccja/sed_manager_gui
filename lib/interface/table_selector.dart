import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/table_editor.dart';

class TableSelectorPage extends StatefulWidget {
  const TableSelectorPage(this.device, {super.key});
  final EncryptedDevice device;

  @override
  State<TableSelectorPage> createState() => _TableSelectorPageState();
}

class _TableSelectorPageState extends State<TableSelectorPage> {
  late final EncryptedDevice device = widget.device;
  int? selectedSecurityProvider;
  int? selectedTable;
  List<(int, String)>? securityProviders;
  List<(int, String)>? tables;

  @override
  void dispose() {
    device.dispose();
    super.dispose();
  }

  Future<void> refreshSecurityProviders() async {
    List<(int, String)> newSecurityProviders = [];
    final adminSpUid = await device.findUid("SP::Admin", securityProvider: 0);
    final spTableUid = await device.findUid("SP", securityProvider: 0);
    if (adminSpUid != null && spTableUid != null) {
      await device.login(adminSpUid);
      await for (final spUid in device.getTableRows(spTableUid)) {
        final maybeName = await device.findName(spUid);
        final name = maybeName ?? spUid.toRadixString(16).padLeft(16, "0");
        newSecurityProviders.add((spUid, name));
      }
      await device.end();
    }
    setState(() {
      securityProviders = newSecurityProviders;
    });
  }

  Future<void> refreshTables() async {
    setState(() {
      tables = null;
    });

    final tableTableUid = await device.findUid("Table",
        securityProvider: selectedSecurityProvider!);
    if (tableTableUid != null) {
      await for (final descriptorUid in device.getTableRows(tableTableUid)) {
        final tableUid = descriptorUid << 32;
        final maybeName = await device.findName(tableUid);
        final name = maybeName ?? tableUid.toRadixString(16).padLeft(16, "0");
        setState(() {
          tables = (tables ?? []) + [(tableUid, name)];
        });
      }
    }
  }

  Future<void> onSecurityProviderChanged(int? securityProvider) async {
    if (selectedSecurityProvider != null) {
      await device.end();
    }
    setState(() {
      selectedSecurityProvider = securityProvider;
      selectedTable = null;
    });
    if (securityProvider != null) {
      await device.login(securityProvider);
      try {
        await refreshTables();
      } catch (ex) {}
    }
  }

  Widget buildSecurityProviderDropdown() {
    if (securityProviders == null) {
      refreshSecurityProviders().ignore();
      return const Icon(Icons.hourglass_top);
    }
    if (securityProviders!.isEmpty) {
      return const Text("No security providers available.");
    }
    final options = securityProviders!.map((sp) {
      return DropdownMenuEntry<int>(value: sp.$1, label: sp.$2);
    }).toList();
    return DropdownMenu(
      onSelected: (int? value) {
        setState(() {
          onSecurityProviderChanged(value).ignore();
        });
      },
      dropdownMenuEntries: options,
      label: const Text("Security provider"),
      controller: SearchController(),
    );
  }

  Widget buildTableDrawer() {
    if (tables != null) {
      final destinations = tables!.map((table) {
        return NavigationDrawerDestination(
          icon: const Icon(Icons.circle),
          label: Text(table.$2),
        );
      });
      return NavigationDrawer(
        selectedIndex: selectedTable,
        children: destinations.toList(),
        onDestinationSelected: (value) {
          setState(() {
            selectedTable = value;
          });
        },
      );
    }
    return const Icon(Icons.hourglass_top);
  }

  Widget buildTableEditor() {
    if (selectedSecurityProvider != null && selectedTable != null) {
      final tableUid = tables![selectedTable!].$1;
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: TableEditor(
                device,
                selectedSecurityProvider!,
                tableUid,
                key: Key(
                    "${selectedSecurityProvider!.toRadixString(16)}_${tableUid.toRadixString(16)}"),
              ),
            ),
          );
        },
      );
    } else {
      return const Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Icon(Icons.arrow_back),
            Text(
              "Select a table",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Table editor",
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 6, 0, 6),
            child: Align(
              alignment: Alignment.center,
              child: buildSecurityProviderDropdown(),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Column(children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: const Text("Tables", style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(child: buildTableDrawer()),
                ]),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    child: buildTableEditor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
