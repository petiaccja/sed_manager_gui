import 'package:flutter/material.dart';

class ErrorStrip extends StatelessWidget {
  const ErrorStrip.nothing({this.height = 32.0, super.key})
      : _result = false,
        _error = null;
  const ErrorStrip.success({this.height = 32.0, super.key})
      : _result = true,
        _error = null;
  const ErrorStrip.error(this._error, {this.height = 32.0, super.key}) : _result = true;

  final bool _result;
  final Object? _error;
  final double? height;

  Widget _buildIcon(BuildContext context) {
    if (_error != null) {
      return const Icon(Icons.error_outline, color: Colors.red);
    } else if (_result) {
      return const Icon(Icons.check_circle_outline, color: Colors.green);
    } else {
      return const Icon(Icons.question_mark_outlined, color: Colors.transparent);
    }
  }

  String? _getMessage() {
    if (_error != null) {
      return _error.toString();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _buildIcon(context);
    final message = _getMessage();
    final text = Text(message ?? "", maxLines: 1, overflow: TextOverflow.ellipsis);
    final tooltip = message != null ? Tooltip(message: message, child: text) : text;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 6),
          tooltip,
        ],
      ),
    );
  }
}
