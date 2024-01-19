import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:sed_manager_gui/bindings/value.dart';
import 'package:sed_manager_gui/bindings/type.dart';
import 'error_strip.dart';

class TableCell extends StatelessWidget {
  const TableCell({
    this.fill = false,
    required this.child,
    super.key,
  });

  final bool fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = Border.all(color: colorScheme.outlineVariant);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: border,
        color: fill ? colorScheme.secondary : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
}

class HeaderTableCell extends StatelessWidget {
  const HeaderTableCell(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TableCell(
      fill: true,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class UIDTableCell extends StatelessWidget {
  UIDTableCell(
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
    try {
      return await encryptedDevice.findName(object, securityProvider: securityProvider);
    } catch (ex) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: friendlyName,
      builder: (context, snapshot) {
        final text = snapshot.data ?? object.toRadixString(16).padLeft(16, '0');
        return Tooltip(
          waitDuration: Durations.long4,
          message: text,
          child: TableCell(
            child: Text(text, overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}

class CellEditDialog extends StatefulWidget {
  const CellEditDialog(
    this.encryptedDevice,
    this.securityProvider,
    this.object,
    this.column,
    this.type,
    this.initialValue, {
    this.onFinished,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final UID object;
  final int column;
  final Type type;
  final String initialValue;
  final void Function()? onFinished;

  @override
  State<CellEditDialog> createState() => _CellEditDialogState();
}

class _CellEditDialogState extends State<CellEditDialog> {
  var _snapshot = const AsyncSnapshot<bool>.waiting();
  Request<void>? _request;
  late final _controller = TextEditingController(text: widget.initialValue);

  Future<void> _setValue(String value) async {
    try {
      final parsed = widget.encryptedDevice.parseValue(value, widget.type, widget.securityProvider);
      await widget.encryptedDevice.setValue(widget.object, widget.column, parsed);
      setState(() {
        _snapshot = const AsyncSnapshot<bool>.withData(ConnectionState.done, true);
      });
    } catch (ex) {
      setState(() {
        _snapshot = AsyncSnapshot<bool>.withError(ConnectionState.done, ex);
      });
    }
  }

  void _set() {
    _request?.cancel();
    _request = request(() => _setValue(_controller.text));
  }

  void _close() {
    Navigator.of(context).pop();
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const title = Text("Edit cell value", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

    final textEdit = TextField(
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(fontSize: 13, fontFamily: "CascadiaCode"),
      expands: true,
      maxLines: null,
      controller: _controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.all(2),
      ),
    );

    final errorStrip = _snapshot.hasData
        ? const ErrorStrip.success()
        : _snapshot.hasError
            ? ErrorStrip.error(_snapshot.error!)
            : const ErrorStrip.nothing();

    final setButton = OutlinedButton(onPressed: _set, child: const Text("Set"));

    final closeButton = OutlinedButton(
      onPressed: _close,
      child: const Text("Close"),
    );

    return Dialog(
      child: FractionallySizedBox(
        widthFactor: 0.66,
        heightFactor: 0.60,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              const Center(child: title),
              const SizedBox(height: 6),
              Expanded(child: textEdit),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: errorStrip),
                  const SizedBox(width: 6),
                  setButton,
                  const SizedBox(width: 6),
                  closeButton,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValueTableCell extends StatefulWidget {
  const ValueTableCell(
    this.encryptedDevice,
    this.securityProvider,
    this.object,
    this.column,
    this.type, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final UID object;
  final int column;
  final Type type;

  @override
  State<StatefulWidget> createState() => _ValueTableCellState();
}

class _ValueTableCellState extends State<ValueTableCell> {
  var getSnapshot = const AsyncSnapshot<String>.waiting();
  var setSnapshot = const AsyncSnapshot<bool>.waiting();
  Request<void>? getRequest;
  Request<void>? setRequest;
  final _controller = TextEditingController();

  @override
  void initState() {
    getRequest = request(_getValue);
    super.initState();
  }

  @override
  void dispose() {
    getRequest?.future.ignore();
    setRequest?.future.ignore();
    getRequest?.cancel();
    setRequest?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showFailureDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Could not set value"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getValue() async {
    try {
      final value = await widget.encryptedDevice.getValue(
        widget.object,
        widget.column,
      );
      final rendered =
          value.hasValue ? widget.encryptedDevice.renderValue(value, widget.type, widget.securityProvider) : "";
      setState(() {
        getSnapshot = AsyncSnapshot<String>.withData(ConnectionState.done, rendered);
      });
    } catch (ex) {
      setState(() {
        getSnapshot = AsyncSnapshot<String>.withError(ConnectionState.done, ex);
      });
    }
  }

  Future<void> _setValue(String value) async {
    try {
      final parsed = widget.encryptedDevice.parseValue(value, widget.type, widget.securityProvider);
      await widget.encryptedDevice.setValue(widget.object, widget.column, parsed);
      setState(() {
        getRequest?.cancel();
        getRequest = request(_getValue);
        setSnapshot = const AsyncSnapshot<bool>.withData(ConnectionState.done, true);
      });
    } catch (ex) {
      setState(() {
        setSnapshot = AsyncSnapshot<bool>.withError(ConnectionState.done, ex);
        _showFailureDialog(ex.toString());
      });
    }
  }

  Widget _buildExpandable(BuildContext context, {required String initialValue, required Widget child}) {
    return GestureDetector(
      child: child,
      onDoubleTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return CellEditDialog(
              widget.encryptedDevice,
              widget.securityProvider,
              widget.object,
              widget.column,
              widget.type,
              initialValue,
              onFinished: () {
                setState(() {
                  getRequest?.cancel();
                  getRequest = request(_getValue);
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContentWithData(BuildContext context, String data) {
    _controller.text = data;

    return TextField(
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      autocorrect: false,
      readOnly: false,
      maxLines: 1,
      controller: _controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
        contentPadding: EdgeInsets.all(0),
      ),
      onSubmitted: (value) {
        setRequest?.future.ignore();
        setRequest?.cancel();
        setRequest = request(() async {
          return await _setValue(value);
        });
      },
    );
  }

  Widget _buildContentWithError(Object error) {
    return Tooltip(
      message: error.toString(),
      child: const SizedBox(width: 14, height: 14, child: Icon(Icons.error_rounded)),
    );
  }

  Widget _buildContentWaiting() {
    return const Center(
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (getSnapshot.hasData) {
      final child = _buildContentWithData(context, getSnapshot.data!);
      content = _buildExpandable(context, initialValue: getSnapshot.data!, child: child);
    } else if (getSnapshot.hasError) {
      final child = _buildContentWithError(getSnapshot.error!);
      content = _buildExpandable(context, initialValue: "", child: child);
    } else {
      content = _buildContentWaiting();
    }
    return TableCell(child: content);
  }
}

class ColumnDesc {
  ColumnDesc(this.name, this.type);
  final String name;
  final Type type;
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

  Future<(List<UID>, List<ColumnDesc>)> _getLayout() async {
    final rows = await encryptedDevice.getTableRows(table).toList();
    final columns = <ColumnDesc>[];
    for (int column = 0; column < encryptedDevice.getColumnCount(table); ++column) {
      columns.add(ColumnDesc(
        encryptedDevice.getColumnName(table, column),
        encryptedDevice.getColumnType(table, column),
      ));
    }
    return (rows, columns);
  }

  Widget _buildWithData(
    BuildContext context,
    List<UID> rows,
    List<ColumnDesc> columns,
  ) {
    Widget headerBuilder(columnIdx) {
      return HeaderTableCell(columns[columnIdx + 1].name);
    }

    Widget rowBuilder(rowIdx) {
      return UIDTableCell(encryptedDevice, rows[rowIdx], securityProvider);
    }

    Widget valueBuilder(columnIdx, rowIdx) {
      return ValueTableCell(
        encryptedDevice,
        securityProvider,
        rows[rowIdx],
        columnIdx + 1,
        columns[columnIdx + 1].type,
        key: ObjectKey((encryptedDevice, table, columnIdx, rowIdx)),
      );
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
      cellDimensions: const CellDimensions.uniform(width: 112, height: 26),
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
