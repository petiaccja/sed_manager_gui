import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class UidCell extends StatelessWidget {
  UidCell(
    this.encryptedDevice,
    this.object,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID object;
  final UID securityProvider;
  late final friendlyName = request(_getFriendlyName);

  Future<String?> _getFriendlyName() async {
    return await encryptedDevice.findName(object,
        securityProvider: securityProvider);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: friendlyName,
      builder: (context, snapshot) {
        final text = snapshot.data ?? object.toRadixString(16).padLeft(16, '0');
        return Text(text, overflow: TextOverflow.ellipsis);
      },
    );
  }
}

class ValueCell extends StatelessWidget {
  ValueCell(
    this.device,
    this.securityProvider,
    this.table,
    this.object,
    this.column, {
    super.key,
  });

  final EncryptedDevice device;
  final UID securityProvider;
  final UID table;
  final UID object;
  final int column;
  late final value = request(_getValue);

  Future<String> _getValue() async {
    return await device.getObjectColumn(
      table,
      object,
      column,
      securityProvider: securityProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: value,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!, overflow: TextOverflow.ellipsis);
        }
        if (snapshot.hasError) {
          return const Text("<error>");
        }
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class TableView extends StatelessWidget {
  TableView(
    this.encryptedDevice,
    this.securityProvider,
    this.table, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final UID table;
  late final layout = request(_getLayout);

  Future<(List<UID>, List<String>)> _getLayout() async {
    final rows = await encryptedDevice.getTableRows(table).toList();
    final columns = await encryptedDevice.getTableColumns(table).toList();
    return (rows, columns);
  }

  Widget _buildWithData(
    BuildContext context,
    List<UID> rows,
    List<String> columns,
  ) {
    Widget headerBuilder(columnIdx) {
      return Text(
        columns[columnIdx + 1],
        style: const TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget rowBuilder(rowIdx) {
      return UidCell(encryptedDevice, rows[rowIdx], securityProvider);
    }

    Widget valueBuilder(columnIdx, rowIdx) {
      return ValueCell(encryptedDevice, securityProvider, table, rows[rowIdx],
          columnIdx + 1);
    }

    return StickyHeadersTable(
      columnsLength: columns.length - 1,
      rowsLength: rows.length,
      columnsTitleBuilder: headerBuilder,
      rowsTitleBuilder: rowBuilder,
      contentCellBuilder: valueBuilder,
      legendCell: headerBuilder(-1),
      showHorizontalScrollbar: true,
      showVerticalScrollbar: true,
      cellDimensions: const CellDimensions.uniform(width: 86, height: 26),
    );
  }

  Widget _buildWithError(Object error) {
    return Text(error.toString());
  }

  Widget _buildWaiting() {
    return const Column(children: [
      SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
      Text("Loading layout..."),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: layout,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rows = snapshot.data!.$1;
          final columns = snapshot.data!.$2;
          return _buildWithData(context, rows, columns);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
      },
    );
  }
}
