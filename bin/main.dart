import 'dart:io';
import 'dart:convert';

import 'package:dart_websocket_sample/profileable_websocket.dart';
import 'package:dart_websocket_sample/frame_event.dart';

const _serverUrl = 'wss://echo.websocket.org';
const _separator = '─────────────────────────────────────────────────────';

void main() async {
  print('Connecting to $_serverUrl ...');
  final ws = await ProfileableWebSocket.connect(_serverUrl);
  print('Connected. Type a message and press Enter. Ctrl+C to exit.\n');

  ws.listen(
    (_) => _printTable(ws.events),
    onDone: () => print('\nConnection closed.'),
    onError: (e) => print('Error: $e'),
  );

  await for (final line
      in stdin.transform(SystemEncoding().decoder).transform(LineSplitter())) {
    if (line.trim().isEmpty) continue;
    ws.add(line);
  }

  await ws.close();
}

/// Prints the last 10 recorded [events] as a formatted traffic table.
void _printTable(List<FrameEvent> events) {
  final rows = events.length > 10 ? events.sublist(events.length - 10) : events;
  final startIndex = events.length - rows.length + 1;

  print('\n$_separator');
  print(' #   Time       Direction   Size      Type    Preview');
  print(_separator);

  for (var i = 0; i < rows.length; i++) {
    final e = rows[i];
    final index = (startIndex + i).toString().padRight(4);
    final time = _formatTime(e.timestamp);
    final dir =
        e.direction == FrameDirection.sent ? '↑ SENT    ' : '↓ RECEIVED';
    final size = '${e.sizeInBytes} B'.padRight(9);
    final type = e.type == FrameType.text ? 'text  ' : 'binary';
    final preview = _preview(e.data);
    print(' $index $time  $dir  $size $type  $preview');
  }

  print('$_separator\n');
}

String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:'
    '${t.minute.toString().padLeft(2, '0')}:'
    '${t.second.toString().padLeft(2, '0')}';

String _preview(dynamic data) {
  final str = data is String ? data : data.toString();
  return str.length > 10 ? '${str.substring(0, 10)}...' : str;
}
