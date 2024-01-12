import 'package:flutter/material.dart';
import 'package:sed_manager_gui/interface/activity_launcher.dart';
import '../bindings/storage_device.dart';
import 'request_queue.dart';

class StorageDeviceProperties {
  StorageDeviceProperties(this.name, this.serial, this.firmware, this.supportedSSCs);
  final String name;
  final String serial;
  final String firmware;
  final List<String> supportedSSCs;
}

class StorageDeviceCard extends StatelessWidget {
  StorageDeviceCard(
    this._storageDevice, {
    required this.onConfigure,
    super.key,
  });

  final StorageDevice _storageDevice;
  final void Function() onConfigure;
  late final _properties = request(_getProperties);

  Future<StorageDeviceProperties> _getProperties() async {
    final name = _storageDevice.getName();
    final serial = _storageDevice.getSerial();
    return StorageDeviceProperties(name, serial, "???", <String>["???"]);
  }

  Widget _buildCard(BuildContext context, Widget child) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 280,
      height: 160,
      child: Card(
        color: colorScheme.primary,
        child: Container(margin: const EdgeInsets.all(8), child: child),
      ),
    );
  }

  Widget _buildWithData(BuildContext context, StorageDeviceProperties data) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = TextStyle(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold);
    final infoStyle = TextStyle(color: colorScheme.onPrimary, fontSize: 14);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(data.name, style: titleStyle)),
        Text("Serial: ${data.serial}", style: infoStyle),
        Text("Firmware: ${data.firmware}", style: infoStyle),
        Text("Encryption: ${data.supportedSSCs.join(', ')}", style: infoStyle),
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: OutlinedButton(
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(colorScheme.inversePrimary)),
              onPressed: onConfigure,
              child: const Text("Configure"),
            ),
          ),
        ),
      ],
    );
    return _buildCard(context, content);
  }

  Widget _buildWithError(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = TextStyle(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold);
    final infoStyle = TextStyle(color: colorScheme.onPrimary, fontSize: 14);

    final name = _storageDevice.getName();

    final content = Column(
      children: [
        Center(child: Text(name, style: titleStyle)),
        Text(error.toString(), style: infoStyle),
      ],
    );
    return _buildCard(context, content);
  }

  Widget _buildWaiting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = TextStyle(color: colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.bold);

    final name = _storageDevice.getName();

    final content = Column(
      children: [
        Center(child: Text(name, style: titleStyle)),
        const Center(child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator())),
      ],
    );
    return _buildCard(context, content);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: _properties,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(context, snapshot.error!);
        }
        return _buildWaiting(context);
      },
    );
  }
}

class DriveLauncherPage extends StatefulWidget {
  const DriveLauncherPage(this.onFinished, {super.key});

  final void Function() onFinished;

  @override
  State<DriveLauncherPage> createState() => _DriveLauncherPageState();
}

class _DriveLauncherPageState extends State<DriveLauncherPage> {
  List<StorageDevice> storageDevices = [];

  @override
  void initState() {
    storageDevices = enumerateStorageDevices();
    super.initState();
  }

  void _onConfigure(StorageDevice device) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ActivityLauncherPage(device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cards = storageDevices.map((device) {
      return StorageDeviceCard(device, onConfigure: () => _onConfigure(device));
    });

    final appBar = AppBar(
      backgroundColor: colorScheme.primary,
      title: Text(
        "Storage devices",
        style: TextStyle(color: colorScheme.onPrimary),
      ),
    );

    final body = Container(
      margin: const EdgeInsets.all(8),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 16,
        children: cards.toList(),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}
