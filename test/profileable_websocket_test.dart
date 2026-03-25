import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:dart_websocket_sample/profileable_websocket.dart';
import 'package:dart_websocket_sample/frame_event.dart';

/// Starts a local echo WebSocket server on a random port.
Future<HttpServer> startEchoServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.transform(WebSocketTransformer()).listen((ws) {
    ws.listen((data) => ws.add(data));
  });
  return server;
}

void main() {
  late HttpServer server;
  late String url;

  setUp(() async {
    server = await startEchoServer();
    url = 'ws://127.0.0.1:${server.port}';
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('sending a text message records a sent event', () async {
    final ws = await ProfileableWebSocket.connect(url);
    ws.add('hello');
    await Future.delayed(Duration(milliseconds: 50));
    await ws.close();

    expect(ws.events.where((e) => e.direction == FrameDirection.sent),
        hasLength(1));
    final sent =
        ws.events.firstWhere((e) => e.direction == FrameDirection.sent);
    expect(sent.type, FrameType.text);
    expect(sent.sizeInBytes, utf8.encode('hello').length);
    expect(sent.data, 'hello');
  });

  test('receiving the echo records a received event', () async {
    final ws = await ProfileableWebSocket.connect(url);
    final completer = Completer<void>();

    ws.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    ws.add('world');
    await completer.future.timeout(Duration(seconds: 2));
    await ws.close();

    expect(ws.events.where((e) => e.direction == FrameDirection.received),
        hasLength(1));
    final received =
        ws.events.firstWhere((e) => e.direction == FrameDirection.received);
    expect(received.data, 'world');
    expect(received.type, FrameType.text);
  });

  test('events list grows after multiple messages', () async {
    final ws = await ProfileableWebSocket.connect(url);
    final received = <dynamic>[];
    final done = Completer<void>();

    ws.listen((data) {
      received.add(data);
      if (received.length == 3) done.complete();
    });

    ws.add('one');
    ws.add('two');
    ws.add('three');

    await done.future.timeout(Duration(seconds: 2));
    await ws.close();

    expect(ws.events, hasLength(6)); // 3 sent + 3 received
  });

  test('binary data is recorded with binary type', () async {
    final ws = await ProfileableWebSocket.connect(url);
    final completer = Completer<void>();

    ws.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    final bytes = [1, 2, 3, 4];
    ws.add(bytes);
    await completer.future.timeout(Duration(seconds: 2));
    await ws.close();

    final sent =
        ws.events.firstWhere((e) => e.direction == FrameDirection.sent);
    expect(sent.type, FrameType.binary);
    expect(sent.sizeInBytes, 4);
  });

  test('close shuts down the connection cleanly', () async {
    final ws = await ProfileableWebSocket.connect(url);
    final doneFired = Completer<void>();
    ws.listen(null, onDone: () => doneFired.complete());
    await ws.close(1000, 'done');
    await doneFired.future.timeout(Duration(seconds: 2));
    expect(ws.readyState, WebSocket.closed);
  });
}
