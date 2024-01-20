import 'dart:collection';

import 'package:flutter/material.dart';

class CancellationToken {
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
  }

  bool get cancelled => _cancelled;
}

class Request<T> {
  Request(this.future, this.token);

  Future<T> future;
  CancellationToken token;

  void cancel() {
    token.cancel();
  }

  bool get cancelled => token.cancelled;
}

class RequestQueue {
  final _queue = Queue<Request<dynamic>>();

  Request<T> request<T>(Future<T> Function() delegate) {
    final token = CancellationToken();
    final last = _queue.isNotEmpty ? _queue.removeFirst() : null;

    Future<T> wrapper() async {
      try {
        if (last != null) {
          await last.future;
        }
      } catch (ex) {}
      if (!token.cancelled) {
        return await delegate();
      }
      throw Exception("cancelled");
    }

    final future = wrapper();
    final request = Request(future, token);
    _queue.add(request);
    return request;
  }
}

final _requestQueue = RequestQueue();

Request<T> request<T>(Future<T> Function() delegate) {
  return _requestQueue.request(delegate);
}

class RequestBuilder<T> extends StatefulWidget {
  const RequestBuilder({
    super.key,
    required this.request,
    this.initialData,
    required this.builder,
  });

  final Request<T>? request;
  final T? initialData;
  final AsyncWidgetBuilder<T> builder;

  @override
  State<RequestBuilder> createState() => _RequestBuilderState<T>();
}

class _RequestBuilderState<T> extends State<RequestBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.request?.future,
      builder: (context, snapshot) => widget.builder(context, snapshot),
      initialData: widget.initialData,
    );
  }

  @override
  void deactivate() {
    widget.request?.future.ignore();
    widget.request?.cancel();
    super.deactivate();
  }
}
