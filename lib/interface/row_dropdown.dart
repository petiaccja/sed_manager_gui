import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';

class RowDropdown extends StatelessWidget {
  RowDropdown(
    this._encryptedDevice, {
    UID? table,
    String? tableName,
    UID? securityProvider,
    String? securityProviderName,
    this.onSelected,
    this.rowFilter,
    this.hintText,
    this.width,
    super.key,
  }) {
    if (table != null) {
      _getTable = () async => table;
    } else {
      _getTable = () => _encryptedDevice.findUid(tableName!);
    }

    if (securityProviderName != null) {
      _getSecurityProvider = () async => _encryptedDevice.findUid(securityProviderName);
    } else {
      _getSecurityProvider = () async => securityProvider;
    }
  }

  final EncryptedDevice _encryptedDevice;
  late final Future<UID> Function() _getTable;
  late final Future<UID?> Function() _getSecurityProvider;
  final void Function(UID row)? onSelected;
  final Future<bool> Function(UID row, EncryptedDevice encryptedDevice, UID? securityProvider)? rowFilter;
  final String? hintText;
  final double? width;
  late final _request = request(_getRows);

  Future<List<(UID, String)>> _getRows() async {
    final table = await _getTable();
    final securityProvider = await _getSecurityProvider();
    final rows = <(UID, String)>[];
    await for (final row in _encryptedDevice.getTableRows(table)) {
      final include = rowFilter != null ? await rowFilter!(row, _encryptedDevice, securityProvider) : true;
      if (include) {
        try {
          rows.add((row, await _encryptedDevice.findName(row)));
        } catch (ex) {
          rows.add((row, row.toRadixString(16).padLeft(16, '0')));
        }
      }
    }
    return rows;
  }

  Widget _buildWithData(List<(UID, String)> securityProviders) {
    final items = securityProviders.map((sp) {
      return DropdownMenuEntry<int>(value: sp.$1, label: sp.$2);
    }).toList();

    if (securityProviders.isEmpty) {
      return DropdownMenu(
        dropdownMenuEntries: const [],
        enabled: false,
        hintText: "Empty",
        width: width,
      );
    }
    return DropdownMenu(
      onSelected: (int? value) => onSelected?.call(value!),
      dropdownMenuEntries: items,
      controller: SearchController(),
      hintText: hintText,
      width: width,
    );
  }

  Widget _buildWithError(Object error) {
    return Tooltip(
      message: error.toString(),
      child: DropdownMenu(
        dropdownMenuEntries: const [],
        hintText: "Error!",
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
