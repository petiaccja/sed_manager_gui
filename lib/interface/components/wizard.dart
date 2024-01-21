import 'package:flutter/material.dart';
import 'package:sed_manager_gui/interface/components/request_queue.dart';
import 'package:sed_manager_gui/interface/components/result_indicator.dart';

class _WizardPageRoute extends PageRoute {
  _WizardPageRoute({required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Color? get barrierColor {
    if (navigator != null) {
      return Theme.of(navigator!.context).colorScheme.background;
    }
    return null;
  }

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final position = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(animation);
    return SlideTransition(position: position, child: child);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}

class _ValidationDialog extends StatelessWidget {
  const _ValidationDialog(this._validate, {this.next, super.key});

  final Future<void> Function() _validate;
  final Widget Function(BuildContext context)? next;

  void _finalize(BuildContext context, bool success) {
    Navigator.of(context).pop(); // Pops this dialog.
    if (success && next == null) {
      if (next != null) {
        Navigator.of(context).push(_WizardPageRoute(builder: (context) {
          return next!(context);
        }));
      } else {
        // Pops until the first wizard page.
        Navigator.of(context).popUntil((route) => route.runtimeType != _WizardPageRoute);
        Navigator.of(context).pop(); // Pops the first wizard page.
      }
    }
  }

  Widget _buildContent(BuildContext context, String title, Widget message, bool done, bool success) {
    final okButton = FilledButton(onPressed: done ? () => _finalize(context, success) : null, child: const Text("OK"));

    return Container(
      margin: const EdgeInsets.all(12),
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          message,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: okButton),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return _buildContent(
      context,
      "Success",
      const SizedBox(height: 48, child: ErrorStrip.success()),
      true,
      true,
    );
  }

  Widget _buildWithError(BuildContext context, Object error) {
    return _buildContent(
      context,
      "Error",
      SizedBox(height: 48, child: ErrorStrip.error(error)),
      true,
      false,
    );
  }

  Widget _buildWaiting(BuildContext context) {
    return _buildContent(
      context,
      "Waiting for results...",
      const SizedBox(width: 48, height: 48, child: CircularProgressIndicator()),
      false,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: RequestBuilder(
        request: request(_validate),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildWithError(context, snapshot.error!);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildSuccess(context);
          }
          return _buildWaiting(context);
        },
      ),
    );
  }
}

class WizardPage extends StatelessWidget {
  const WizardPage({
    required this.title,
    required this.onValidate,
    this.onNext,
    required this.child,
    super.key,
  });

  final String title;
  final Future<void> Function() onValidate;
  final Widget Function(BuildContext context)? onNext;
  final Widget child;

  void _onCancel(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.runtimeType != _WizardPageRoute);
    Navigator.of(context).pop();
  }

  void _onNext(BuildContext context) {
    showDialog(context: context, builder: (context) => _ValidationDialog(onValidate, next: onNext));
  }

  void _onFinish(BuildContext context) {
    showDialog(context: context, builder: (context) => _ValidationDialog(onValidate));
  }

  @override
  Widget build(BuildContext context) {
    final cancelButton = ElevatedButton(onPressed: () => _onCancel(context), child: const Text("Cancel"));
    final nextButton = ElevatedButton(onPressed: () => _onNext(context), child: const Text("Next"));
    final finishButton = ElevatedButton(onPressed: () => _onFinish(context), child: const Text("Finish"));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(child: child),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [cancelButton, const SizedBox(width: 6), onNext != null ? nextButton : finishButton],
            ),
          ),
        ],
      ),
    );
  }
}
