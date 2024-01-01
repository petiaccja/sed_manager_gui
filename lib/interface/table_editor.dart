import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/error_popup.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:sed_manager_gui/interface/table_view.dart';

class SecurityProviderDropdown extends StatelessWidget {
  SecurityProviderDropdown(this.encryptedDevice, {this.onSelected, super.key});

  final EncryptedDevice encryptedDevice;
  final void Function(UID)? onSelected;
  late final _securityProviders = request(_getSecurityProviders);

  Future<List<(UID, String)>> _getSecurityProviders() async {
    final adminSp = await encryptedDevice.findUid("SP::Admin");
    if (adminSp == null) {
      throw SEDException("could not find the Admin SP on the device");
    }
    final spTable = await encryptedDevice.findUid("SP");
    if (spTable == null) {
      throw SEDException("could not find the SP table on the device");
    }
    await encryptedDevice.login(adminSp);
    try {
      final securityProviders =
          await encryptedDevice.getTableRows(spTable).toList();
      List<(UID, String)> result = [];
      for (final sp in securityProviders) {
        final name = await encryptedDevice.findName(sp);
        result.add((sp, name ?? sp.toRadixString(16).padLeft(16, '0')));
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
      return const DropdownMenu(
        dropdownMenuEntries: [],
        enabled: false,
        errorText: "No security providers",
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
    return const DropdownMenu(
      dropdownMenuEntries: [],
      enabled: false,
      errorText: "Error loading SPs",
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
      builder:
          (BuildContext context, AsyncSnapshot<List<(UID, String)>> snapshot) {
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

class TableDrawer extends StatelessWidget {
  TableDrawer(
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
    final tableTable = await encryptedDevice.findUid(
      "Table",
      securityProvider: securityProvider,
    );
    if (tableTable == null) {
      throw SEDException("could not find the Table table on the device");
    }

    List<(UID, String)> tables = [];
    await for (final tableDesc in encryptedDevice.getTableRows(tableTable)) {
      final table = tableDesc << 32;
      final name = await encryptedDevice.findName(table);
      tables.add((table, name ?? table.toRadixString(16).padLeft(16, '0')));
    }
    return tables;
  }

  Widget _buildWithData(List<(UID, String)> tables) {
    final entries = tables.map((table) {
      return SizedBox(
        width: 200,
        height: 32,
        child: ElevatedButton(
          child: Text(table.$2),
          onPressed: () {
            onSelected?.call(table.$1);
          },
        ),
      );
    }).toList();

    return SizedBox(
      width: 200,
      height: 300,
      child: ListView(
        children: entries,
      ),
    );
  }

  Widget _buildWithError(Object error) {
    return const Text("error");
  }

  Widget _buildWaiting() {
    return const SizedBox(
      width: 48,
      height: 48,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: tables,
      builder: (context, snapshot) {
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

class EncryptedDeviceBuilder extends StatefulWidget {
  const EncryptedDeviceBuilder(
    this.storageDevice, {
    required this.builder,
    super.key,
  });
  final StorageDevice storageDevice;
  final Widget Function(BuildContext, EncryptedDevice) builder;

  @override
  State<EncryptedDeviceBuilder> createState() => _EncryptedDeviceBuilderState();
}

class _EncryptedDeviceBuilderState extends State<EncryptedDeviceBuilder> {
  late final Request<EncryptedDevice> encryptedDevice =
      request(_getEncryptedDevice);

  @override
  void dispose() {
    request(() async {
      try {
        final result = await encryptedDevice.future;
        await result.end();
        result.dispose();
      } catch (ex) {}
    });
    super.dispose();
  }

  Future<EncryptedDevice> _getEncryptedDevice() async {
    return await EncryptedDevice.start(widget.storageDevice);
  }

  Widget _buildWithData(BuildContext context, EncryptedDevice encryptedDevice) {
    return widget.builder(context, encryptedDevice);
  }

  Widget _buildWithError(Object error) {
    var message = error.toString();
    return ErrorPopupPage(message);
  }

  Widget _buildWaiting() {
    return const Column(children: [
      SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
      Text("Opening device..."),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: encryptedDevice,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
      },
    );
  }
}

class SessionBuilder extends StatefulWidget {
  const SessionBuilder(
    this.encryptedDevice,
    this.securityProvider, {
    required this.builder,
    super.key,
  });
  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final Widget Function(BuildContext, EncryptedDevice, UID) builder;

  @override
  State<SessionBuilder> createState() => _SessionBuilderState();
}

class _SessionBuilderState extends State<SessionBuilder> {
  late final Request<UID> session = request(_getSession);

  @override
  void deactivate() {
    request(() async {
      await session.future;
      await widget.encryptedDevice.end();
    });
    super.deactivate();
  }

  Future<UID> _getSession() async {
    await widget.encryptedDevice.login(widget.securityProvider);
    return widget.securityProvider;
  }

  Widget _buildWithData(BuildContext context, EncryptedDevice encryptedDevice,
      UID securityProvider) {
    return widget.builder(context, encryptedDevice, securityProvider);
  }

  Widget _buildWithError(Object error) {
    return const Text("error");
  }

  Widget _buildWaiting() {
    return const Column(children: [
      SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
      Text("Starting session..."),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: session,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(
              context, widget.encryptedDevice, snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Text(
        "Table editor",
        style: TextStyle(color: colorScheme.onPrimary),
      ),
      backgroundColor: colorScheme.primary,
    );
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
        Container(
          margin: const EdgeInsets.all(6),
          child: TableDrawer(
            encryptedDevice,
            securityProvider,
            onSelected: (table) {
              tableStream.add(table);
            },
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(6),
            child: StreamBuilder(
              stream: tableStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return IntrinsicWidth(
                    child: TableView(
                      encryptedDevice,
                      securityProvider,
                      snapshot.data!,
                    ),
                  );
                }
                return const Center(child: Text("Select a security table"));
              },
            ),
          ),
        ),
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
              return const Center(child: Text("Select a security provider"));
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
