import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';

class UnlockerPage extends StatefulWidget {
  const UnlockerPage(this.manager, {super.key});

  final EncryptedDevice manager;

  @override
  State<UnlockerPage> createState() => _UnlockerPageState();
}

class _UnlockerPageState extends State<UnlockerPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = [];

  @override
  void dispose() {
    widget.manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    var resultsField = AnimatedList(
      key: _listKey,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        return Text(_items[index], textAlign: TextAlign.center);
      },
    );

    var resultsPanel = Container(
      margin: const EdgeInsets.all(12),
      child: resultsField,
    );

    const usernameField = FractionallySizedBox(
      widthFactor: 0.7,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Username",
        ),
      ),
    );

    const passwordField = FractionallySizedBox(
      widthFactor: 0.7,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Password",
        ),
      ),
    );

    var unlockButton = SizedBox(
      child: FilledButton(
        onPressed: () {
          _items.add("Unlocking not implemented yet.");
          _listKey.currentState!.insertItem(_items.length - 1);
        },
        child: const Text("Unlock"),
      ),
    );

    var credentialsPanel = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        usernameField,
        const SizedBox(height: 8),
        passwordField,
        const SizedBox(height: 8),
        unlockButton,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Unlock drive",
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: credentialsPanel),
          Expanded(flex: 1, child: resultsPanel),
        ],
      ),
    );
  }
}
