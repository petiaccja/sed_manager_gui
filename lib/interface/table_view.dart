import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:sed_manager_gui/bindings/value.dart';

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

    final border = fill
        ? Border.symmetric(
            vertical: BorderSide(
              color: colorScheme.inversePrimary,
            ),
          )
        : Border.all(
            color: colorScheme.primary,
          );

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: border,
        color: fill ? colorScheme.primary : null,
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
    return await encryptedDevice.findName(object, securityProvider: securityProvider);
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

class CellLinkedTextField extends StatefulWidget {
  const CellLinkedTextField(
    this.encryptedDevice,
    this.securityProvider,
    this.table,
    this.object,
    this.column, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final UID table;
  final UID object;
  final int column;

  @override
  State<StatefulWidget> createState() => _CellLinkedTextFieldState();
}

class _CellLinkedTextFieldState extends State<CellLinkedTextField> {
  var getSnapshot = const AsyncSnapshot<String>.waiting();
  var setSnapshot = const AsyncSnapshot<bool>.waiting();
  Request<void>? getRequest;
  Request<void>? setRequest;

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
      final value = await widget.encryptedDevice.getObjectColumn(
        widget.table,
        widget.object,
        widget.column,
      );
      final rendered = value.handle().toString(); // TODO: render properly.
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
      final parsed = Value.empty();
      await widget.encryptedDevice.setObjectColumn(widget.table, widget.object, widget.column, parsed);
      setState(() {
        getSnapshot = AsyncSnapshot<String>.withData(ConnectionState.done, value);
        setSnapshot = const AsyncSnapshot<bool>.withData(ConnectionState.done, true);
      });
    } catch (ex) {
      setState(() {
        setSnapshot = AsyncSnapshot<bool>.withError(ConnectionState.done, ex);
        _showFailureDialog(ex.toString());
      });
    }
  }

  Widget _buildContentWithData(BuildContext context, String data) {
    final colorScheme = Theme.of(context).colorScheme;

    final textColor = setSnapshot.hasData
        ? Colors.green
        : setSnapshot.hasError
            ? colorScheme.error
            : colorScheme.onBackground;

    final textField = TextField(
      style: TextStyle(color: textColor),
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      autocorrect: false,
      readOnly: false,
      maxLines: 1,
      controller: TextEditingController(text: data),
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

    return textField;
  }

  Widget _buildContentWithError(Object error) {
    return Tooltip(
      message: error.toString(),
      child: const Text(
        "Error",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
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
      content = _buildContentWithData(context, getSnapshot.data!);
    } else if (getSnapshot.hasError) {
      content = _buildContentWithError(getSnapshot.error!);
    } else {
      content = _buildContentWaiting();
    }
    return TableCell(child: content);
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
      return HeaderTableCell(columns[columnIdx + 1]);
    }

    Widget rowBuilder(rowIdx) {
      return UIDTableCell(encryptedDevice, rows[rowIdx], securityProvider);
    }

    Widget valueBuilder(columnIdx, rowIdx) {
      return CellLinkedTextField(
        encryptedDevice,
        securityProvider,
        table,
        rows[rowIdx],
        columnIdx + 1,
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
