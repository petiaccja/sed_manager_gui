import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/error_strip.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:sed_manager_gui/interface/row_dropdown.dart';
import 'package:sed_manager_gui/interface/table_view.dart';
import "encrypted_device_builder.dart";
import "session_builder.dart";
import "tools_view.dart";

class SecurityProviderDropdown extends StatelessWidget {
  SecurityProviderDropdown(this.encryptedDevice, {this.onSelected, super.key});

  final EncryptedDevice encryptedDevice;
  final void Function(UID)? onSelected;
  late final _adminSp = request(() async => await encryptedDevice.findUid("SP::Admin"));

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: _adminSp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorStrip.error(snapshot.error);
        }
        if (!snapshot.hasData) {
          return const SizedBox(width: 32, height: 32, child: CircularProgressIndicator());
        }
        return SessionBuilder(
          encryptedDevice,
          snapshot.data!,
          builder: (context, encryptedDevice, securityProvider) {
            return RowDropdown(
              encryptedDevice,
              tableName: "SP",
              securityProvider: securityProvider,
              onSelected: (row) => onSelected?.call(row),
              hintText: "Select security provider",
              width: 210,
            );
          },
        );
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

class CachedStream<T> {
  CachedStream(this.source);

  final Stream<T> source;
  T? latest;

  late final stream = source.map((event) {
    latest = event;
    return event;
  });
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
    UID securityProvider,
  ) {
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
        final text = (snapshot.data ?? <String>["-"]).join("   ");
        return Marquee(
          text: "Authenticated:   $text",
          blankSpace: 80,
          fadingEdgeStartFraction: 0.1,
          fadingEdgeEndFraction: 0.1,
          crossAxisAlignment: CrossAxisAlignment.center,
        );
      },
    );

    final tableListView = TableListView(
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
          return TableView(
            encryptedDevice,
            securityProvider,
            snapshot.data!,
          );
        }
        return const Center(child: Text("Select a table."));
      },
    );

    final toolsView = ToolsView(
      encryptedDevice,
      securityProvider,
      onAuthenticated: (authority) {
        authorityStream.add(authority);
        if (cachedTableStream.latest != null) {
          tableStream.add(cachedTableStream.latest!);
        }
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
        toolsView,
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
            builder: _buildSession,
            key: ObjectKey(snapshot.data!),
          );
        }
        return const Center(child: Text("Select a security provider."));
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        securityProviderDropdown,
        const SizedBox(height: 12),
        Expanded(child: sessionPanel),
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
