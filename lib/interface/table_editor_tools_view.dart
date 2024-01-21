import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/value.dart';
import 'package:sed_manager_gui/interface/components/result_indicator.dart';
import 'package:sed_manager_gui/interface/components/request_queue.dart';
import 'package:sed_manager_gui/interface/components/row_dropdown_view.dart';

class TableEditorToolDialog extends StatelessWidget {
  const TableEditorToolDialog(
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
      initSession: RowDropdown.byUid(widget.securityProvider),
      getTable: RowDropdown.byName("Authority"),
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

    return TableEditorToolDialog("Authenticate", children: [authoritySelector, passwordField, buttonStrip, errorStrip]);
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
      initSession: RowDropdown.byUid(widget.securityProvider),
      getTable: RowDropdown.byName("Authority"),
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

    return TableEditorToolDialog("Change password", children: [
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
      initSession: RowDropdown.byUid(widget.securityProvider),
      getTable: RowDropdown.byName("Locking"),
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

    return TableEditorToolDialog(
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

class ActivateDialog extends StatefulWidget {
  const ActivateDialog(
    this.encryptedDevice,
    this.securityProvider, {
    this.onActivated,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final void Function(UID securityProvider)? onActivated;

  @override
  State<ActivateDialog> createState() => _ActivateDialogState();
}

class _ActivateDialogState extends State<ActivateDialog> {
  int? _selectedSecurityProvider;
  var _result = const AsyncSnapshot<void>.waiting();

  void _onActivate() {
    request(() async {
      var result = const AsyncSnapshot<void>.withError(ConnectionState.done, "Select a security provider!");
      if (_selectedSecurityProvider != null) {
        try {
          await widget.encryptedDevice.activate(_selectedSecurityProvider!);
          widget.onActivated?.call(_selectedSecurityProvider!);
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

  Future<bool> _filter(UID subjectSp, EncryptedDevice encryptedDevice, UID? sessionSp) async {
    try {
      const manufacturedInactive = 8;
      final lifeCycleState = (await encryptedDevice.getValue(subjectSp, 6)).getInteger();
      return lifeCycleState == manufacturedInactive;
    } catch (ex) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authoritySelector = RowDropdown(
      widget.encryptedDevice,
      initSession: RowDropdown.byUid(widget.securityProvider),
      getTable: RowDropdown.byName("SP"),
      rowFilter: _filter,
      onSelected: (securityProvider) {
        setState(() {
          _selectedSecurityProvider = securityProvider;
        });
      },
      hintText: "Select security provider",
      width: 280,
    );

    final buttonStrip = Row(
      children: [
        Expanded(
          flex: 1,
          child: FilledButton(
            onPressed: _onActivate,
            child: const Text("Activate"),
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

    return TableEditorToolDialog("Activate security provider", children: [
      authoritySelector,
      buttonStrip,
      errorStrip,
    ]);
  }
}

class TableEditorToolsView extends StatelessWidget {
  const TableEditorToolsView(
    this.encryptedDevice,
    this.securityProvider, {
    this.onAuthenticated,
    this.onActivated,
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final void Function(UID authority)? onAuthenticated;
  final void Function(UID securityProvider)? onActivated;

  Widget _buildButton(IconData icon, String title, void Function()? onPressed) {
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
    const UID adminSpUid = 0x0000020500000001;
    const UID lockingSpUid = 0x0000020500000002;

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
      showDialog(
        context: context,
        builder: (context) => PasswordDialog(encryptedDevice, securityProvider),
      );
    });

    final genMekButton = _buildButton(
      Icons.key,
      "Generate media encryption key",
      securityProvider != lockingSpUid
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) => GenerateMEKDialog(encryptedDevice, securityProvider),
              );
            },
    );

    final activateButton = _buildButton(
      Icons.rocket_launch,
      "Activate security provider",
      securityProvider != adminSpUid
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) => ActivateDialog(
                  encryptedDevice,
                  securityProvider,
                  onActivated: onActivated,
                ),
              );
            },
    );

    return SizedBox(
      width: 64,
      child: ListView(
        shrinkWrap: true,
        itemExtent: 70,
        children: [
          authenticateButton,
          changePassButton,
          genMekButton,
          activateButton,
        ],
      ),
    );
  }
}
