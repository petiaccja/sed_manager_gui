import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:sed_manager_gui/interface/table_view.dart';
import "encrypted_device_builder.dart";
import "session_builder.dart";
import "tools_view.dart";

class SecurityProviderDropdown extends StatelessWidget {
  SecurityProviderDropdown(this.encryptedDevice, {this.onSelected, super.key});

  final EncryptedDevice encryptedDevice;
  final void Function(UID)? onSelected;
  late final _securityProviders = request(_getSecurityProviders);

  Future<List<(UID, String)>> _getSecurityProviders() async {
    final adminSp = await encryptedDevice.findUid("SP::Admin");
    final spTable = await encryptedDevice.findUid("SP");
    await encryptedDevice.login(adminSp);
    try {
      final securityProviders = await encryptedDevice.getTableRows(spTable).toList();
      List<(UID, String)> result = [];
      for (final sp in securityProviders) {
        try {
          final name = await encryptedDevice.findName(sp);
          result.add((sp, name));
        } catch (ex) {
          result.add((sp, sp.toRadixString(16).padLeft(16, '0')));
        }
      }
      return result;
    } finally {
      await encryptedDevice.end();
    }
  }

  Widget _buildWithData(List<(UID, String)> securityProviders) {
    final items = securityProviders.map((sp) {
      return DropdownMenuEntry<int>(value: sp.$1, label: sp.$2);
    }).toList();

    if (securityProviders.isEmpty) {
      return const Tooltip(
        message: "no security providers on device",
        child: DropdownMenu(
          dropdownMenuEntries: [],
          enabled: false,
          hintText: "Empty",
        ),
      );
    }
    return DropdownMenu(
      onSelected: (int? value) => onSelected?.call(value!),
      dropdownMenuEntries: items,
      label: const Text("Select security provider"),
      controller: SearchController(),
    );
  }

  Widget _buildWithError(Object error) {
    return Tooltip(
      message: error.toString(),
      child: const DropdownMenu(
        dropdownMenuEntries: [],
        hintText: "Error",
        enabled: false,
      ),
    );
  }

  Widget _buildWaiting() {
    return const DropdownMenu(
      dropdownMenuEntries: [],
      enabled: false,
      helperText: "Loading in progress",
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: _securityProviders,
      builder: (BuildContext context, AsyncSnapshot<List<(UID, String)>> snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
      },
    );
  }
}

class TableListView extends StatelessWidget {
  TableListView(
    this.encryptedDevice,
    this.securityProvider, {
    this.onSelected,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final void Function(UID)? onSelected;
  late final Request<List<(UID, String)>> tables = request(_getTables);

  Future<List<(UID, String)>> _getTables() async {
    final tableTable = await encryptedDevice.findUid("Table", securityProvider: securityProvider);

    List<(UID, String)> tables = [];
    try {
      await for (final tableDesc in encryptedDevice.getTableRows(tableTable)) {
        final table = tableDesc << 32;
        try {
          final name = await encryptedDevice.findName(table);
          tables.add((table, name));
        } catch (ex) {
          tables.add((table, table.toRadixString(16).padLeft(16, '0')));
        }
      }
      return tables;
    } catch (ex) {
      rethrow;
    }
  }

  Widget _buildWithData(BuildContext context, List<(UID, String)> tables) {
    final entries = tables.map((table) {
      return NavigationDrawerDestination(
        icon: Icon(IconData(table.$2.codeUnits[0])),
        label: Text(table.$2),
      );
    }).toList();

    final header = Container(
      margin: const EdgeInsets.all(6),
      child: Center(
        child: Text(
          "Tables",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );

    final selected = StreamController<int>();
    return StreamBuilder(
      stream: selected.stream,
      builder: (context, snapshot) {
        return NavigationDrawer(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          onDestinationSelected: (value) {
            onSelected?.call(tables[value].$1);
            selected.add(value);
          },
          selectedIndex: snapshot.data,
          children: [header, ...entries],
        );
      },
    );
  }

  Widget _buildWithError(Object error) {
    return Column(
      children: [
        const Text(
          "Error loading tables",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          textAlign: TextAlign.center,
          error.toString(),
          maxLines: 1000,
        ),
      ],
    );
  }

  Widget _buildWaiting() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        ),
        Text("Loading tables..."),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: tables,
      builder: (context, snapshot) {
        Widget? content;
        if (snapshot.hasData) {
          content = _buildWithData(context, snapshot.data!);
        } else if (snapshot.hasError) {
          content = _buildWithError(snapshot.error!);
        } else {
          content = _buildWaiting();
        }
        return SizedBox(width: 200, child: content);
      },
    );
  }
}

class TableEditorPage extends StatelessWidget {
  TableEditorPage(this.storageDevice, {super.key});
  final StorageDevice storageDevice;
  final securityProviderStream = StreamController<UID>();

  void _onSecurityProvider(UID securityProvider) {
    securityProviderStream.add(securityProvider);
  }

  static AppBar _buildAppBar(BuildContext context) {
    return AppBar(title: const Text("Table editor"));
  }

  static Widget _buildSession(
    BuildContext context,
    EncryptedDevice encryptedDevice,
    UID securityProvider,
  ) {
    final tableStream = StreamController<UID>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableListView(
          encryptedDevice,
          securityProvider,
          onSelected: (table) {
            tableStream.add(table);
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder(
            stream: tableStream.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TableView(
                  encryptedDevice,
                  securityProvider,
                  snapshot.data!,
                );
              }
              return const Center(child: Text("Select a table."));
            },
          ),
        ),
        const SizedBox(width: 12),
        ToolsView(encryptedDevice, securityProvider),
      ],
    );
  }

  Widget _buildBody(EncryptedDevice encryptedDevice) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          child: Center(
            child: SecurityProviderDropdown(
              encryptedDevice,
              onSelected: _onSecurityProvider,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: securityProviderStream.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SessionBuilder(
                  encryptedDevice,
                  snapshot.data!,
                  builder: _buildSession,
                  key: ObjectKey(snapshot.data!),
                );
              }
              return const Center(child: Text("Select a security provider."));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: EncryptedDeviceBuilder(
        storageDevice,
        builder: (BuildContext context, EncryptedDevice encryptedDevice) {
          return _buildBody(encryptedDevice);
        },
      ),
    );
  }
}
