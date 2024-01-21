import 'package:flutter/material.dart';
import 'package:sed_manager_gui/bindings/encrypted_device.dart';
import 'package:sed_manager_gui/bindings/storage_device.dart';
import 'package:sed_manager_gui/interface/components/encrypted_device_builder.dart';
import 'package:sed_manager_gui/interface/components/request_queue.dart';
import 'package:sed_manager_gui/interface/components/session_builder.dart';
import 'package:sed_manager_gui/interface/components/wizard.dart';

const UID _adminSpUid = 0x0000020500000001;
const UID _lockingSpUid = 0x0000020500000002;
const UID _sidUid = 0x0000000900000006;
const UID _psidUid = 0x000000090001FF01;

class _RevertPage extends StatefulWidget {
  const _RevertPage(this._encryptedDevice, this._isPsidSupported);

  final EncryptedDevice _encryptedDevice;
  final bool _isPsidSupported;

  @override
  State<StatefulWidget> createState() => _RevertPageState();
}

class _RevertPageState extends State<_RevertPage> {
  UID _selectedAuthority = _sidUid;
  int _selectedScope = _adminSpUid;
  final _passwordController = TextEditingController();

  Future<void> _performReset() async {
    await widget._encryptedDevice.authenticate(_selectedAuthority, _passwordController.text);
    await widget._encryptedDevice.revert(_selectedScope);
  }

  Widget _buildForm(BuildContext context) {
    const width = 280.0;

    const dropdownSid = DropdownMenuEntry<UID>(
      label: "Owner (SID)",
      value: _sidUid,
    );
    final dropdownPsid = DropdownMenuEntry<UID>(
      label: "Physical owner (PSID)",
      value: _psidUid,
      enabled: widget._isPsidSupported,
    );
    final authoritySelector = DropdownMenu<UID>(
      dropdownMenuEntries: [dropdownSid, dropdownPsid],
      initialSelection: _selectedAuthority,
      helperText: "How you authenticate",
      width: width,
      onSelected: (value) => setState(() {
        _selectedAuthority = value ?? _sidUid;
        _selectedScope = _adminSpUid;
      }),
    );

    const dropdownResetAll = DropdownMenuEntry<int>(
      label: "Entire configuration",
      value: _adminSpUid,
    );
    final dropdownResetLocking = DropdownMenuEntry<int>(
      label: "Locking configuration",
      value: _lockingSpUid,
      enabled: _selectedAuthority != _psidUid,
    );
    final resetSelector = DropdownMenu(
      dropdownMenuEntries: [dropdownResetAll, dropdownResetLocking],
      initialSelection: _selectedScope,
      helperText: "What to reset",
      width: width,
      onSelected: (value) => setState(() {
        _selectedScope = value ?? _adminSpUid;
      }),
    );

    final passwordHint = _selectedAuthority == _sidUid ? "Password of owner" : "Password of phys. owner";

    final passwordEntry = TextField(
      decoration: InputDecoration(hintText: passwordHint),
      obscureText: true,
      controller: _passwordController,
    );

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          authoritySelector,
          const SizedBox(height: 6),
          resetSelector,
          const SizedBox(height: 6),
          passwordEntry,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WizardPage(
      title: "Factory reset",
      onValidate: _performReset,
      child: _buildForm(context),
    );
  }
}

class FactoryResetWizard extends StatelessWidget {
  const FactoryResetWizard(this._storageDevice, {super.key});

  final StorageDevice _storageDevice;

  Future<bool> _isPsidSupported(EncryptedDevice encryptedDevice) async {
    try {
      await encryptedDevice.getValue(_psidUid, 0);
      return true;
    } catch (ex) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EncryptedDeviceBuilder(
      _storageDevice,
      builder: (context, encryptedDevice) {
        return SessionBuilder(
          encryptedDevice,
          _adminSpUid,
          builder: (context, encryptedDevice, securityProvider) {
            return RequestBuilder(
              request: request(() async => _isPsidSupported(encryptedDevice)),
              builder: (context, snapshot) {
                return _RevertPage(encryptedDevice, snapshot.data ?? false);
              },
            );
          },
        );
      },
    );
  }
}
