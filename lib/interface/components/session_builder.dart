import 'dart:async';
import 'package:flutter/material.dart';
import "package:sed_manager_gui/bindings/encrypted_device.dart";
import 'package:sed_manager_gui/interface/components/result_indicator.dart';
import 'request_queue.dart';

class SessionBuilder extends StatefulWidget {
  const SessionBuilder(
    this.encryptedDevice,
    this.securityProvider, {
    required this.builder,
    super.key,
  });
  final EncryptedDevice encryptedDevice;
  final UID securityProvider;
  final Widget Function(BuildContext context, EncryptedDevice encryptedDevice, UID securityProvider) builder;

  @override
  State<SessionBuilder> createState() => _SessionBuilderState();
}

class _SessionBuilderState extends State<SessionBuilder> {
  late final Request<UID> session = request(_getSession);

  @override
  void deactivate() {
    request(() async {
      await session.future;
      await widget.encryptedDevice.end();
    });
    super.deactivate();
  }

  Future<UID> _getSession() async {
    await widget.encryptedDevice.login(widget.securityProvider);
    return widget.securityProvider;
  }

  Widget _buildWithData(BuildContext context, EncryptedDevice encryptedDevice, UID securityProvider) {
    return widget.builder(context, encryptedDevice, securityProvider);
  }

  Widget _buildWithError(Object error) {
    return FractionallySizedBox(widthFactor: 0.75, child: ErrorStrip.error(error.toString()));
  }

  Widget _buildWaiting() {
    return const Column(children: [
      SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
      Text("Starting session..."),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RequestBuilder(
      request: session,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildWithData(context, widget.encryptedDevice, snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildWithError(snapshot.error!);
        }
        return _buildWaiting();
      },
    );
  }
}
