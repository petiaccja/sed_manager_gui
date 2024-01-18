import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/error_strip.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';

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
  State<AuthneticateDialog> createState() => _AuthneticateDialogState();
}

class _AuthneticateDialogState extends State<AuthneticateDialog> {
  late final _authorities = request(_getAuthorities);

  final _authorityController = SearchController();
  final _passwordController = TextEditingController();
  int? _selectedAuthority;
  var _result = const AsyncSnapshot<bool>.nothing();

  @override
  void dispose() {
    _authorityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<(UID, String)>> _getAuthorities() async {
    final authorityTable = await widget.encryptedDevice.findUid("Authority");
    final allAuthorities = await widget.encryptedDevice.getTableRows(authorityTable).toList();
    final authoritiesWithNames = <(UID, String)>[];
    for (final authority in allAuthorities) {
      try {
        final name = await widget.encryptedDevice.findName(authority, securityProvider: widget.securityProvider);
        authoritiesWithNames.add((authority, name));
      } catch (ex) {
        authoritiesWithNames.add((authority, authority.toRadixString(16).padLeft(16, '0')));
      }
    }
    return authoritiesWithNames;
  }

  void _onAuthenticate() {
    request(() async {
      if (_selectedAuthority == null) {
        setState(() {
          _result = const AsyncSnapshot<bool>.withError(ConnectionState.done, "Select an authority!");
        });
      } else {
        try {
          await widget.encryptedDevice.authenticate(_selectedAuthority!, _passwordController.text);
          setState(() {
            _result = const AsyncSnapshot<bool>.withData(ConnectionState.done, true);
            widget.onAuthenticated?.call(_selectedAuthority!);
          });
        } catch (ex) {
          setState(() {
            _result = AsyncSnapshot<bool>.withError(ConnectionState.done, ex);
          });
        }
      }
    });
  }

  void _onBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget _buildWithData(BuildContext context, List<(UID, String)> data) {
    final authorityItems = data.map((sp) {
      return DropdownMenuEntry<int>(value: sp.$1, label: sp.$2);
    }).toList();

    final authoritySelector = DropdownMenu(
      width: 280,
      dropdownMenuEntries: authorityItems,
      label: const Text("Select authority"),
      controller: _authorityController,
      onSelected: (value) {
        setState(() {
          _selectedAuthority = value;
        });
      },
    );

    final passwordField = TextField(obscureText: true, controller: _passwordController);

    final authenticateButton = FilledButton(
      onPressed: _onAuthenticate,
      child: const Text("Authenticate"),
    );

    final backButton = FilledButton(
      onPressed: () {
        _onBack(context);
      },
      child: const Text("Back"),
    );

    final errorStrip = _result.hasData
        ? const ErrorStrip.success()
        : _result.hasError
            ? ErrorStrip.error(_result.error!)
            : const ErrorStrip.nothing();

    return SizedBox(
      width: 280,
      child: Column(
        children: [
          authoritySelector,
          const SizedBox(height: 6),
          passwordField,
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(flex: 1, child: authenticateButton),
              const SizedBox(width: 6),
              Expanded(flex: 1, child: backButton),
            ],
          ),
          const SizedBox(height: 6),
          errorStrip,
        ],
      ),
    );
  }

  Widget _buildWithError(BuildContext context, Object error) {
    return Text(error.toString());
  }

  Widget _buildWaiting() {
    return const Center(child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Authenticate", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              RequestBuilder(
                request: _authorities,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildWithData(context, snapshot.data!);
                  } else if (snapshot.hasError) {
                    return _buildWithError(context, snapshot.error!);
                  }
                  return _buildWaiting();
                },
              ),
            ],
          )),
    );
  }
}

class PasswordDialog extends StatelessWidget {
  const PasswordDialog(
    this.encryptedDevice,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

  @override
  Widget build(BuildContext context) {
    return const Dialog.fullscreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Change password", style: TextStyle(fontSize: 18)),
          Text("Coming soon..."),
        ],
      ),
    );
  }
}

class ReplaceMEKDialog extends StatelessWidget {
  const ReplaceMEKDialog(
    this.encryptedDevice,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

  @override
  Widget build(BuildContext context) {
    return const Dialog.fullscreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Replace media encryption key", style: TextStyle(fontSize: 18)),
          Text("Coming soon..."),
        ],
      ),
    );
  }
}

class ActivateDialog extends StatelessWidget {
  const ActivateDialog(
    this.encryptedDevice,
    this.securityProvider, {
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

  @override
  Widget build(BuildContext context) {
    return const Dialog.fullscreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Activate security provider", style: TextStyle(fontSize: 18)),
          Text("Coming soon..."),
        ],
      ),
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

    return SizedBox(
      width: 64,
      child: ListView(
        itemExtent: 70,
        children: [
          authenticateButton,
          _buildButton(Icons.password, "Change password", () {
            showDialog(context: context, builder: (context) => PasswordDialog(encryptedDevice, securityProvider));
          }),
          _buildButton(Icons.key, "Replace media encryption key", () {
            showDialog(context: context, builder: (context) => ReplaceMEKDialog(encryptedDevice, securityProvider));
          }),
          _buildButton(Icons.arrow_circle_up, "Activate security provider", () {
            showDialog(context: context, builder: (context) => ActivateDialog(encryptedDevice, securityProvider));
          }),
        ],
      ),
    );
  }
}
