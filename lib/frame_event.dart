import 'dart:convert';

/// Whether a frame was sent by the client or received from the server.
enum FrameDirection { sent, received }

/// Whether a frame carries text or binary data.
enum FrameType { text, binary }

/// A single recorded WebSocket frame with its metadata.
class FrameEvent {
  /// When the frame was captured.
  final DateTime timestamp;

  /// Whether the frame was sent or received.
  final FrameDirection direction;

  /// Size of the frame payload in bytes.
  final int sizeInBytes;

  /// Whether the payload is text or binary.
  final FrameType type;

  /// The raw frame payload.
  final dynamic data;

  /// Creates a [FrameEvent] with all required fields.
  FrameEvent({
    required this.timestamp,
    required this.direction,
    required this.sizeInBytes,
    required this.type,
    required this.data,
  });

  /// Creates a [FrameEvent] from raw WebSocket [data], computing size and type automatically.
  factory FrameEvent.fromData(dynamic data, FrameDirection direction) {
    final int size;
    final FrameType type;

    if (data is String) {
      size = utf8.encode(data).length;
      type = FrameType.text;
    } else if (data is List<int>) {
      size = data.length;
      type = FrameType.binary;
    } else {
      size = 0;
      type = FrameType.binary;
    }

    return FrameEvent(
      timestamp: DateTime.now(),
      direction: direction,
      sizeInBytes: size,
      type: type,
      data: data,
    );
  }
}
