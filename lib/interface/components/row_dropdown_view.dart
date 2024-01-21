import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/components/request_queue.dart';

class RowDropdown extends StatelessWidget {
  RowDropdown(
    this._encryptedDevice, {
    required this.initSession,
    this.endSession,
    required this.getTable,
    this.onSelected,
    this.rowFilter,
    this.hintText,
    this.width,
    super.key,
  });

  final EncryptedDevice _encryptedDevice;
  final Future<UID> Function(EncryptedDevice encryptedDevice) initSession;
  final Future<void> Function(EncryptedDevice encryptedDevice, UID securityProvider)? endSession;
  final Future<UID> Function(EncryptedDevice encryptedDevice) getTable;
  final void Function(UID row)? onSelected;
  final Future<bool> Function(UID row, EncryptedDevice encryptedDevice, UID? securityProvider)? rowFilter;
  final String? hintText;
  final double? width;
  late final _request = request(_getRows);

  static Future<UID> Function(EncryptedDevice) byUid(UID table) {
    return (encryptedDevice) async => table;
  }

  static Future<UID> Function(EncryptedDevice) byName(String name) {
    return (encryptedDevice) async => await encryptedDevice.findUid(name);
  }

  Future<List<(UID, String)>> _getRows() async {
    final table = await getTable(_encryptedDevice);
    final securityProvider = await initSession(_encryptedDevice);
    try {
      final rows = <(UID, String)>[];
      await for (final row in _encryptedDevice.getTableRows(table)) {
        final include = rowFilter != null ? await rowFilter!(row, _encryptedDevice, securityProvider) : true;
        if (include) {
          try {
            rows.add((row, await _encryptedDevice.findName(row, securityProvider: securityProvider ?? 0)));
          } catch (ex) {
            rows.add((row, row.toRadixString(16).padLeft(16, '0')));
          }
        }
      }
      return rows;
    } finally {
      await endSession?.call(_encryptedDevice, securityProvider);
    }
  }

  Widget _buildWithData(List<(UID, String)> securityProviders) {
    final items = securityProviders.map((sp) {
      return DropdownMenuEntry<int>(value: sp.$1, label: sp.$2);
    }).toList();

    return DropdownMenu(
      onSelected: (int? value) => onSelected?.call(value!),
      dropdownMenuEntries: items,
      controller: SearchController(),
      hintText: securityProviders.isNotEmpty ? hintText : "Empty",
      enabled: securityProviders.isNotEmpty,
      width: width,
    );
  }

  Widget _buildWithError(Object error) {
    return Tooltip(
      message: error.toString(),
      child: DropdownMenu(
        dropdownMenuEntries: const [],
        hintText: "Error",
        enabled: false,
        width: width,
      ),
    );
  }

  Widget _buildWaiting() {
    return const DropdownMenu(
      dropdownMenuEntries: [],
      enabled: false,
      helperText: "Loading...",
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: _request,
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
