import 'dart:io';
import 'dart:async';

import 'frame_event.dart';

/// A [WebSocket] wrapper that intercepts and records every frame.
///
/// Use [connect] to create an instance. All outgoing frames via [add] and
/// all incoming frames via [listen] are recorded in [events].
class ProfileableWebSocket {
  final WebSocket _inner;

  /// All frames recorded so far, in chronological order.
  final List<FrameEvent> events = [];

  ProfileableWebSocket._(this._inner);

  /// Connects to [url] and returns a [ProfileableWebSocket].
  static Future<ProfileableWebSocket> connect(String url) async {
    final socket = await WebSocket.connect(url);
    return ProfileableWebSocket._(socket);
  }

  /// Sends [data] over the WebSocket and records it as a [FrameDirection.sent] event.
  void add(dynamic data) {
    events.add(FrameEvent.fromData(data, FrameDirection.sent));
    _inner.add(data);
  }

  /// Listens to incoming frames, recording each as a [FrameDirection.received] event.
  ///
  /// Wraps [onData] so every message is intercepted before being forwarded.
  StreamSubscription listen(
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _inner.listen(
      (data) {
        events.add(FrameEvent.fromData(data, FrameDirection.received));
        onData?.call(data);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Closes the underlying WebSocket connection.
  Future close([int? code, String? reason]) => _inner.close(code, reason);

  /// The close code sent by the remote peer, or null if not yet closed.
  int? get closeCode => _inner.closeCode;

  /// The close reason sent by the remote peer, or null if not yet closed.
  String? get closeReason => _inner.closeReason;

  /// The current state of the WebSocket connection.
  int get readyState => _inner.readyState;
}
