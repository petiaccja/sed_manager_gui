import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/sedmanager.dart';

class EditTablesPage extends StatefulWidget {
  const EditTablesPage(this.manager, {super.key});
  final SEDManager manager;

  @override
  State<EditTablesPage> createState() => _EditTablesPageState();
}

class _EditTablesPageState extends State<EditTablesPage> {
  late final SEDManager manager = widget.manager;
  int? currentSecurityProvider;
  List<(int, String)>? securityProviders;
  List<int>? tables;

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  static List<int> loadSecurityProviders(SEDManager manager) {
    final adminSpUid = manager.findUid("SP::Admin", null);
    final spTableUid = manager.findUid("SP", null);

    if (adminSpUid == null) {
      throw SEDException("could not find Admin SP");
    }
    if (spTableUid == null) {
      throw SEDException("could not find SP table");
    }

    manager.start(adminSpUid);
    try {
      final spTable = manager.getTable(spTableUid);
      List<int> securityProviders = [];
      for (final sp in spTable) {
        final uid = sp.uid();
        securityProviders.add(uid);
        sp.dispose();
      }
      spTable.dispose();
      return securityProviders;
    } catch (ex) {
      manager.end();
      rethrow;
    }
  }

  void loadTables() {
    return;
  }

  Widget buildSecurityProviderSelector() {
    if (securityProviders == null) {
      return const Icon(Icons.hourglass_top);
    }
    if (securityProviders!.isEmpty) {
      return const Text("No security providers available.");
    }
    final options = securityProviders!.map((sp) {
      return DropdownMenuItem<int>(
        value: sp.$1,
        child: Text(sp.$2),
      );
    }).toList();
    return DropdownButton(
      value: currentSecurityProvider,
      onChanged: (value) {
        setState(() {
          currentSecurityProvider = value;
        });
      },
      items: options,
    );
  }

  Widget buildTableDrawer() {
    if (tables != null) {
      final destinations = tables!.map((table) {
        return NavigationDrawerDestination(
          icon: const Icon(Icons.circle),
          label: Text(table.toRadixString(16).padLeft(16)),
        );
      });
      return NavigationDrawer(
        selectedIndex: 0,
        children: destinations.toList(),
      );
    }
    return const Icon(Icons.hourglass_top);
  }

  @override
  Widget build(BuildContext context) {
    securityProviders ??= loadSecurityProviders(manager);

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
          Align(
            alignment: Alignment.center,
            child: buildSecurityProviderSelector(),
          ),
          Expanded(child: Row(children: [buildTableDrawer()])),
        ],
      ),
    );
  }
}
