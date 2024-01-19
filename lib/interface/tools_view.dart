import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/value.dart';
import 'package:sed_manager_gui/interface/error_strip.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';
import 'package:sed_manager_gui/interface/row_dropdown.dart';

class ToolDialog extends StatelessWidget {
  const ToolDialog(
    this.title, {
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final header = Text(title, style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary));

    const separator = SizedBox(height: 6);
    final separatedChildren = <Widget>[header];
    for (final child in children) {
      separatedChildren.add(separator);
      separatedChildren.add(child);
    }

    return Dialog(
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: separatedChildren,
        ),
      ),
    );
  }
}

class AuthneticateDialog extends StatefulWidget {
  const AuthneticateDialog(
    this.encryptedDevice,
    this.securityProvider, {
    this.onAuthenticated,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final void Function(UID authority)? onAuthenticated;

  @override
  State<AuthneticateDialog> createState() => _AuthenticateDialogState();
}

class _AuthenticateDialogState extends State<AuthneticateDialog> {
  final _passwordController = TextEditingController();
  int? _selectedAuthority;
  var _result = const AsyncSnapshot<void>.nothing();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthenticate() {
    request(() async {
      var result = const AsyncSnapshot<void>.withError(ConnectionState.done, "Select an authority!");
      if (_selectedAuthority != null) {
        try {
          await widget.encryptedDevice.authenticate(_selectedAuthority!, _passwordController.text);
          result = const AsyncSnapshot<void>.withData(ConnectionState.done, null);
          widget.onAuthenticated?.call(_selectedAuthority!);
        } catch (ex) {
          result = AsyncSnapshot<void>.withError(ConnectionState.done, ex);
        }
      }
      setState(() {
        _result = result;
      });
    });
  }

  void _onBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authoritySelector = RowDropdown(
      widget.encryptedDevice,
      tableName: "Authority",
      securityProvider: widget.securityProvider,
      onSelected: (authority) {
        setState(() {
          _selectedAuthority = authority;
        });
      },
      hintText: "Select authority",
      width: 280,
    );

    final passwordField = TextField(
      obscureText: true,
      controller: _passwordController,
      decoration: const InputDecoration(hintText: "Password"),
    );

    final buttonStrip = Row(
      children: [
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: _onAuthenticate,
            child: const Text("Authenticate"),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: () {
              _onBack(context);
            },
            child: const Text("Back"),
          ),
        ),
      ],
    );

    final errorStrip = _result.hasError
        ? ErrorStrip.error(_result.error!)
        : _result.connectionState == ConnectionState.done
            ? const ErrorStrip.success()
            : const ErrorStrip.nothing();

    return ToolDialog("Authenticate", children: [authoritySelector, passwordField, buttonStrip, errorStrip]);
  }
}

class PasswordDialog extends StatefulWidget {
  const PasswordDialog(
    this.encryptedDevice,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();
  int? _selectedAuthority;
  var _result = const AsyncSnapshot<void>.waiting();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthenticate() {
    request(() async {
      var result = const AsyncSnapshot<void>.withError(ConnectionState.done, "Select an authority!");
      if (_selectedAuthority != null) {
        if (_passwordController.text == _repeatController.text) {
          try {
            final credential = await widget.encryptedDevice.getValue(_selectedAuthority!, 10);
            final credentialUid = credential.getBytes().getUint64(0);
            final ptr = _passwordController.text.toNativeUtf8();
            try {
              final password = Value.bytes(ptr.cast<Uint8>().asTypedList(ptr.length).buffer.asByteData());
              await widget.encryptedDevice.setValue(credentialUid, 3, password);
              result = const AsyncSnapshot<void>.withData(ConnectionState.done, null);
            } finally {
              malloc.free(ptr);
            }
          } catch (ex) {
            result = AsyncSnapshot<void>.withError(ConnectionState.done, ex);
          }
        } else {
          result = const AsyncSnapshot<void>.withError(ConnectionState.done, "Passwords do not match!");
        }
      }
      setState(() {
        _result = result;
      });
    });
  }

  void _onBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authoritySelector = RowDropdown(
      widget.encryptedDevice,
      tableName: "Authority",
      securityProvider: widget.securityProvider,
      onSelected: (authority) {
        setState(() {
          _selectedAuthority = authority;
        });
      },
      hintText: "Select authority",
      width: 280,
    );

    final passwordField = TextField(
      obscureText: true,
      controller: _passwordController,
      decoration: const InputDecoration(hintText: "Password"),
    );

    final repeatField = TextField(
      obscureText: true,
      controller: _repeatController,
      decoration: const InputDecoration(hintText: "Repeat password"),
    );

    final buttonStrip = Row(
      children: [
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: _onAuthenticate,
            child: const Text("Change"),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: () {
              _onBack(context);
            },
            child: const Text("Back"),
          ),
        ),
      ],
    );

    final errorStrip = _result.hasError
        ? ErrorStrip.error(_result.error!)
        : _result.connectionState == ConnectionState.done
            ? const ErrorStrip.success()
            : const ErrorStrip.nothing();

    return ToolDialog("Change password", children: [
      authoritySelector,
      passwordField,
      repeatField,
      buttonStrip,
      errorStrip,
    ]);
  }
}

class GenerateMEKDialog extends StatefulWidget {
  const GenerateMEKDialog(
    this.encryptedDevice,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

  @override
  State<GenerateMEKDialog> createState() => _GenerateMEKDialogState();
}

class _GenerateMEKDialogState extends State<GenerateMEKDialog> {
  UID? _selectedLockingRange;
  var _result = const AsyncSnapshot<void>.waiting();

  void _onGenMEK() {
    request(() async {
      var result = const AsyncSnapshot<void>.withError(ConnectionState.done, "Select a locking range!");
      if (_selectedLockingRange != null) {
        try {
          final activeKey = await widget.encryptedDevice.getValue(_selectedLockingRange!, 10);
          final activeKeyUid = activeKey.getBytes().getUint64(0);
          await widget.encryptedDevice.genMEK(activeKeyUid);
          result = const AsyncSnapshot<void>.withData(ConnectionState.done, null);
        } catch (ex) {
          result = AsyncSnapshot<void>.withError(ConnectionState.done, ex);
        }
      }
      setState(() {
        _result = result;
      });
    });
  }

  void _onBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authoritySelector = RowDropdown(
      widget.encryptedDevice,
      tableName: "Locking",
      securityProvider: widget.securityProvider,
      onSelected: (lockingRange) {
        setState(() {
          _selectedLockingRange = lockingRange;
        });
      },
      hintText: "Select locking range",
      width: 280,
    );

    const warningText = Row(
      children: [
        Icon(Icons.warning_outlined, color: Colors.amber),
        SizedBox(width: 6),
        Expanded(child: Text("This will erase all data in the selected locking range!"))
      ],
    );

    final buttonStrip = Row(
      children: [
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: _onGenMEK,
            child: const Text("Generate"),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: () {
              _onBack(context);
            },
            child: const Text("Back"),
          ),
        ),
      ],
    );

    final errorStrip = _result.hasError
        ? ErrorStrip.error(_result.error!)
        : _result.connectionState == ConnectionState.done
            ? const ErrorStrip.success()
            : const ErrorStrip.nothing();

    return ToolDialog(
      "Generate media encryption key",
      children: [
        warningText,
        authoritySelector,
        buttonStrip,
        errorStrip,
      ],
    );
  }
}

class ToolsView extends StatelessWidget {
  const ToolsView(
    this.encryptedDevice,
    this.securityProvider, {
    this.onAuthenticated,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final void Function(UID authority)? onAuthenticated;

  Widget _buildButton(IconData icon, String title, void Function() onPressed) {
    final style = ButtonStyle(
      padding: const MaterialStatePropertyAll(EdgeInsets.all(6)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Tooltip(
          waitDuration: Durations.medium1,
          message: title,
          child: Icon(icon, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticateButton = _buildButton(
      Icons.person,
      "Authenticate",
      () {
        showDialog(
          context: context,
          builder: (context) => AuthneticateDialog(
            encryptedDevice,
            securityProvider,
            onAuthenticated: onAuthenticated,
          ),
        );
      },
    );

    final changePassButton = _buildButton(Icons.password, "Change password", () {
      showDialog(context: context, builder: (context) => PasswordDialog(encryptedDevice, securityProvider));
    });

    final genMekButton = _buildButton(Icons.key, "Generate media encryption key", () {
      showDialog(context: context, builder: (context) => GenerateMEKDialog(encryptedDevice, securityProvider));
    });

    return SizedBox(
      width: 64,
      child: ListView(
        itemExtent: 70,
        children: [
          authenticateButton,
          changePassButton,
          genMekButton,
        ],
      ),
    );
  }
}
