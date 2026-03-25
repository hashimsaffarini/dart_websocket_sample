<div align="center">

# 🔌 dart_websocket_sample

**A Dart CLI tool that makes WebSocket traffic visible — frame by frame.**

![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-5%20passing-4CAF50?style=for-the-badge&logo=checkmarx&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)
![GSoC](https://img.shields.io/badge/GSoC-2026-4285F4?style=for-the-badge&logo=google&logoColor=white)

</div>

---

## 🧩 The Problem

Flutter DevTools shows HTTP traffic beautifully:

```
GET  /api/users    ✅  200   45ms
POST /api/login    ✅  201  120ms
```

But when your app uses **WebSocket**? The Network panel shows nothing:

```
(empty — no visibility at all)
```

Developers debugging real-time apps are flying blind. 🙈

---

## 💡 The Solution

`ProfileableWebSocket` wraps `dart:io`'s WebSocket and **silently records every frame**:

```
You type → ProfileableWebSocket → real WebSocket → server
                    ↓ records FrameEvent
Echo back ← ProfileableWebSocket ← real WebSocket ← server
                    ↓ records FrameEvent
               prints live table
```

This is the **data model and interception layer** needed to bring WebSocket visibility to Flutter DevTools — making it as observable as HTTP traffic is today.

---

## ✨ What This Sample Does

| Feature | Description |
|---|---|
| 🎁 **Wrapper** | `ProfileableWebSocket` wraps `dart:io` WebSocket transparently |
| 📦 **Recording** | Every frame captured with timestamp, direction, size, and type |
| 🧪 **Tested** | 5 unit tests against a real local echo server — no mocks |
| 📟 **Live Table** | CLI app displays a real-time traffic table in the terminal |

---

## 🗂 Project Structure

```
dart_websocket_sample/
├── bin/
│   └── main.dart                         # CLI entry point
├── lib/
│   ├── profileable_websocket.dart        # WebSocket wrapper ← core
│   └── frame_event.dart                  # Frame data model
├── test/
│   └── profileable_websocket_test.dart   # 5 passing tests
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Requirements
- Dart SDK `>=3.0.0`

### Run
```bash
dart pub get
dart run bin/main.dart
```

### Test
```bash
dart test
```

### Analyze
```bash
dart format .
dart analyze
```

---

## 📟 Live Demo

```
Connecting to wss://echo.websocket.org ...
Connected. Type a message and press Enter. Ctrl+C to exit.

> Hello Dart!

─────────────────────────────────────────────────────────
 #   Time       Direction    Size     Type    Preview
─────────────────────────────────────────────────────────
 1   10:00:01   ↑ SENT       10 B    text    Hello Da...
 2   10:00:01   ↓ RECEIVED   10 B    text    Hello Da...
─────────────────────────────────────────────────────────

> WebSocket profiling is working!

─────────────────────────────────────────────────────────
 #   Time       Direction    Size     Type    Preview
─────────────────────────────────────────────────────────
 1   10:00:01   ↑ SENT       10 B    text    Hello Da...
 2   10:00:01   ↓ RECEIVED   10 B    text    Hello Da...
 3   10:00:05   ↑ SENT       27 B    text    WebSocke...
 4   10:00:05   ↓ RECEIVED   27 B    text    WebSocke...
─────────────────────────────────────────────────────────
```

---

## 🏗 Architecture

```
┌─────────────────────────────────────────┐
│              bin/main.dart              │  ← CLI loop + table printer
└────────────────────┬────────────────────┘
                     │ uses
┌────────────────────▼────────────────────┐
│        ProfileableWebSocket             │  ← intercepts every frame
│  ┌──────────────────────────────────┐   │
│  │   dart:io WebSocket (_inner)     │   │  ← real connection inside
│  └──────────────────────────────────┘   │
│  List<FrameEvent> events                │  ← growing log of frames
└────────────────────┬────────────────────┘
                     │ produces
┌────────────────────▼────────────────────┐
│             FrameEvent                  │  ← timestamp, direction,
│                                         │    size, type, data
└─────────────────────────────────────────┘
```

---

## 🔬 Design Notes

`ProfileableWebSocket` uses the **Wrapper Pattern** — it holds a reference to the real `dart:io` WebSocket internally and delegates all operations to it, while recording frame metadata before forwarding each frame.

> **Why a wrapper for the sample?**
> The full GSoC implementation will instrument `dart:io`'s WebSocket directly — similar to how `HttpClient.enableTimelineLogging` works — so all traffic is captured automatically without requiring a wrapper. The wrapper approach was chosen for this sample to keep it self-contained and easy to run.
> *(Approach confirmed with mentor Samuel Rawlins.)*

---

## 🔗 Related

- [GSoC 2026 Dart Project Ideas](https://github.com/dart-lang/sdk/blob/main/docs/gsoc/Dart-GSoC-2026-Project-Ideas.md)
- [Flutter DevTools Network Panel](https://docs.flutter.dev/tools/devtools/network)
- [dart:io WebSocket docs](https://api.dart.dev/stable/dart-io/WebSocket-class.html)

---

<div align="center">

Made with ❤️ for GSoC 2026 — Dart Organization

</div>
