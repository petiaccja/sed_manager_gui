import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/components/request_queue.dart';
import 'package:sed_manager_gui/interface/table_cell_view.dart';
import 'components/encrypted_device_builder.dart';
import 'components/session_builder.dart';
import 'components/cached_stream.dart';
import 'table_editor_tools_view.dart';
import 'components/row_dropdown_view.dart';

class SecurityProviderDropdown extends StatelessWidget {
  SecurityProviderDropdown(
    this._encryptedDevice, {
    openSession = true,
    this.onSelected,
    super.key,
  }) : _refreshStream = StreamController<bool>() {
    _refreshStream.add(openSession);
  }

  final EncryptedDevice _encryptedDevice;
  final StreamController<bool> _refreshStream;
  final void Function(UID)? onSelected;

  void refresh(bool openSession) {
    _refreshStream.add(openSession);
  }

  Future<UID> _initSession(EncryptedDevice encryptedDevice) async {
    final securityProvider = await encryptedDevice.findUid("SP::Admin");
    await encryptedDevice.login(securityProvider);
    return securityProvider;
  }

  Future<void> _endSession(EncryptedDevice encryptedDevice, UID securityProvider) async {
    await encryptedDevice.end();
  }

  Future<bool> _filter(UID subjectSp, EncryptedDevice encryptedDevice, UID? sessionSp) async {
    const issued = 0;
    const disabled = 1;
    const manufactured = 9;
    const manufacturedDisabled = 10;
    try {
      final lifeCycleState = (await encryptedDevice.getValue(subjectSp, 6)).getInteger();
      final canOpenSession = <int>{issued, disabled, manufactured, manufacturedDisabled}.contains(lifeCycleState);
      return canOpenSession;
    } catch (ex) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _refreshStream.stream,
      builder: (context, snapshot) {
        final openSession = snapshot.data ?? false;
        return RowDropdown(
          _encryptedDevice,
          initSession: openSession ? _initSession : RowDropdown.byName("SP::Admin"),
          endSession: openSession ? _endSession : null,
          getTable: RowDropdown.byName("SP"),
          rowFilter: _filter,
          onSelected: (securityProvider) => onSelected?.call(securityProvider),
          hintText: "Select locking range",
          width: 280,
        );
      },
    );
  }
}

class TableRowListView extends StatelessWidget {
  TableRowListView(
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

  static Stream<Set<UID>> _accumulateAuthorities(Stream<UID> authorities) async* {
    Set<UID> collection = {};
    await for (final authority in authorities) {
      collection.add(authority);
      yield collection;
    }
  }

  static Stream<List<String>> _stringifyAuthoritySets(
    EncryptedDevice encryptedDevice,
    Stream<Set<UID>> authoritySets,
    UID securityProvider,
  ) async* {
    await for (final authoritySet in authoritySets) {
      final nameSet = <String>[];
      for (final authority in authoritySet) {
        try {
          nameSet.add(await encryptedDevice.findName(authority, securityProvider: securityProvider));
        } catch (ex) {
          nameSet.add(authority.toRadixString(16).padLeft(16, '0'));
        }
      }
      nameSet.sort();
      yield nameSet;
    }
  }

  static Widget _buildSession(
    BuildContext context,
    EncryptedDevice encryptedDevice,
    UID securityProvider, {
    void Function(UID authority)? onAuthenticated,
    void Function(UID securityProvider)? onActivated,
  }) {
    final tableStream = StreamController<UID>();
    final cachedTableStream = CachedStream(tableStream.stream);
    final authorityStream = StreamController<UID>();
    final accumulatedAuthorityStream = _stringifyAuthoritySets(
      encryptedDevice,
      _accumulateAuthorities(authorityStream.stream),
      securityProvider,
    );

    final authoritiesView = StreamBuilder(
      stream: accumulatedAuthorityStream,
      builder: (context, snapshot) {
        final text = (snapshot.data ?? <String>["Anybody"]).join("   ");
        return Marquee(child: Text(text, style: const TextStyle(color: Colors.green)));
      },
    );

    final tableListView = TableRowListView(
      encryptedDevice,
      securityProvider,
      onSelected: (table) {
        tableStream.add(table);
      },
    );

    final tableView = StreamBuilder(
      stream: cachedTableStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TableCellView(
            encryptedDevice,
            securityProvider,
            snapshot.data!,
          );
        }
        return const Center(child: Text("Select a table."));
      },
    );

    final toolsView = TableEditorToolsView(
      encryptedDevice,
      securityProvider,
      onAuthenticated: (authority) {
        authorityStream.add(authority);
        if (cachedTableStream.latest != null) {
          tableStream.add(cachedTableStream.latest!);
        }
        onAuthenticated?.call(authority);
      },
      onActivated: (securityProvider) {
        onActivated?.call(securityProvider);
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tableListView,
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(children: [Expanded(flex: 1, child: tableView), SizedBox(height: 32, child: authoritiesView)])),
        const SizedBox(width: 12),
        Center(child: toolsView),
      ],
    );
  }

  Widget _buildBody(EncryptedDevice encryptedDevice) {
    final securityProviderDropdown = SecurityProviderDropdown(
      encryptedDevice,
      onSelected: _onSecurityProvider,
    );

    final sessionPanel = StreamBuilder(
      stream: securityProviderStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SessionBuilder(
            encryptedDevice,
            snapshot.data!,
            builder: (context, encryptedDevice, securityProvider) {
              return _buildSession(
                context,
                encryptedDevice,
                securityProvider,
                onActivated: (securityProvider) => securityProviderDropdown.refresh(false),
              );
            },
            key: ObjectKey(snapshot.data!),
          );
        }
        return const Center(child: Text("Select a security provider."));
      },
    );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 7),
          securityProviderDropdown,
          const Divider(height: 13, thickness: 1, indent: 8, endIndent: 8),
          Expanded(child: sessionPanel),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Table editor")),
      body: EncryptedDeviceBuilder(
        storageDevice,
        builder: (BuildContext context, EncryptedDevice encryptedDevice) {
          return _buildBody(encryptedDevice);
        },
      ),
    );
  }
}
