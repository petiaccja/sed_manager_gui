import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/errors.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';

class UidCell extends StatefulWidget {
  const UidCell(this.device, this.objectUid, this.securityProviderUid,
      {super.key});
  final EncryptedDevice device;
  final int objectUid;
  final int securityProviderUid;

  @override
  State<UidCell> createState() => _UidCellState();
}

class _UidCellState extends State<UidCell> {
  late String name = widget.objectUid.toRadixString(16).padLeft(16, '0');
  bool fresh = false;

  Future<void> refreshFriendlyName() async {
    final maybeName = await widget.device.findName(
      widget.objectUid,
      securityProvider: widget.securityProviderUid,
    );
    if (maybeName != null) {
      setState(() {
        name = maybeName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!fresh) {
      fresh = true;
      refreshFriendlyName().ignore();
    }
    return Text(name);
  }
}

class ValueCell extends StatefulWidget {
  const ValueCell(
    this.device,
    this.securityProviderUid,
    this.tableUid,
    this.objectUid,
    this.column, {
    super.key,
  });
  final EncryptedDevice device;
  final int securityProviderUid;
  final int tableUid;
  final int objectUid;
  final int column;

  @override
  State<ValueCell> createState() => _ValueCellState();
}

class _ValueCellState extends State<ValueCell> {
  String? value;
  bool fresh = false;

  Future<void> refreshValue() async {
    try {
      final value = await widget.device.getObjectColumn(
        widget.tableUid,
        widget.objectUid,
        widget.column,
        securityProvider: widget.securityProviderUid,
      );
      setState(() {
        this.value = value;
      });
    } catch (ex) {
      setState(() {
        value = "<error>";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!fresh) {
      fresh = true;
      refreshValue().ignore();
    }
    return value != null ? Text(value!) : const Icon(Icons.hourglass_top);
  }
}

class TableEditor extends StatefulWidget {
  const TableEditor(this.device, this.securityProvider, this.tableUid,
      {super.key});
  final EncryptedDevice device;
  final int securityProvider;
  final int tableUid;

  @override
  State<TableEditor> createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  late List<String> columns = [];
  late List<int> rows = [];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refreshCells() async {
    List<String> newColumns = [];
    await for (final column in widget.device.getTableColumns(widget.tableUid)) {
      newColumns.add(column);
    }
    setState(() {
      columns = newColumns;
    });

    await for (final row in widget.device.getTableRows(widget.tableUid)) {
      setState(() {
        rows.add(row);
      });
    }
  }

  TableRow buildLabelRow() {
    return TableRow(
      children: columns
          .map(
            (name) => Align(
              alignment: Alignment.center,
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }

  List<TableRow> buildValueRows() {
    TableRow buildRow(int objectUid) {
      int index = 0;
      List<Widget> cells = [];
      for (final _ in columns) {
        if (index == 0) {
          cells.add(UidCell(widget.device, objectUid, widget.securityProvider));
        } else {
          cells.add(ValueCell(widget.device, widget.securityProvider,
              widget.tableUid, objectUid, index));
        }
        ++index;
      }
      return TableRow(children: cells);
    }

    return rows.map((row) => buildRow(row)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) {
      refreshCells().ignore();
      return const Icon(Icons.hourglass_top);
    }
    return Table(
      border: TableBorder.all(),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        buildLabelRow(),
        ...buildValueRows(),
      ],
    );
  }
}
