import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/interface/request_queue.dart';

class AuthneticateDialog extends StatelessWidget {
  const AuthneticateDialog(
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
          Text("Authenticate", style: TextStyle(fontSize: 18)),
          Text("Coming soon..."),
        ],
      ),
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
    super.key,
  });

  final EncryptedDevice encryptedDevice;
  final UID securityProvider;

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
    return SizedBox(
      width: 64,
      child: ListView(
        itemExtent: 70,
        children: [
          _buildButton(Icons.person, "Authenticate", () {
            showDialog(context: context, builder: (context) => AuthneticateDialog(encryptedDevice, securityProvider));
          }),
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
