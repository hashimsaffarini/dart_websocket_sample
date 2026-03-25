dart_websocket_sample
A Dart CLI sample that demonstrates WebSocket frame profiling — recording
timing, size, and type of every frame sent and received over a WebSocket
connection.
Motivation
The Dart & Flutter DevTools Network panel currently shows HTTP traffic only.
Developers using WebSocket connections have no visibility into their traffic
during debugging. This project explores the data model and interception layer
needed to expose WebSocket frames — a step toward making WebSocket traffic
as visible in DevTools as HTTP traffic is today.
What This Sample Does

Wraps dart:io's WebSocket in a ProfileableWebSocket class
Intercepts every outgoing and incoming frame
Records: timestamp, direction, size in bytes, frame type, and content
Displays a live traffic table in the terminal after every message

Project Structure
dart_websocket_sample/
├── bin/
│   └── main.dart                        # CLI entry point
├── lib/
│   ├── profileable_websocket.dart       # WebSocket wrapper
│   └── frame_event.dart                 # Frame data model
├── test/
│   └── profileable_websocket_test.dart  # Unit tests
└── pubspec.yaml
Getting Started
Requirements

Dart SDK >=3.0.0

Run
bashdart pub get
dart run bin/main.dart
Test
bashdart test
Format
bashdart format .
dart analyze
Example Output
Connected to wss://echo.websocket.org
Type a message and press Enter. Ctrl+C to exit.

> Hello Dart!

─────────────────────────────────────────────────────
 #   Time       Direction   Size    Type    Preview
─────────────────────────────────────────────────────
 1   10:00:01   ↑ SENT      10 B    text    Hello Da...
 2   10:00:01   ↓ RECEIVED  10 B    text    Hello Da...
─────────────────────────────────────────────────────

> WebSocket profiling is working!

─────────────────────────────────────────────────────
 #   Time       Direction   Size    Type    Preview
─────────────────────────────────────────────────────
 1   10:00:01   ↑ SENT      10 B    text    Hello Da...
 2   10:00:01   ↓ RECEIVED  10 B    text    Hello Da...
 3   10:00:05   ↑ SENT      27 B    text    WebSocke...
 4   10:00:05   ↓ RECEIVED  27 B    text    WebSocke...
─────────────────────────────────────────────────────
Design Notes
ProfileableWebSocket uses the wrapper pattern — it holds a reference to
the real dart:io WebSocket internally and delegates all operations to it,
while recording frame metadata before forwarding each frame.
This approach is suitable for the sample. The full GSoC implementation
will instrument dart:io's WebSocket directly, similar to how
HttpClient.enableTimelineLogging works, so that all WebSocket traffic
is captured automatically without requiring a wrapper.
Related

GSoC 2026 Dart Project Ideas
DevTools Network Panel
dart:io WebSocket