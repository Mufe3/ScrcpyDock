<div align="center">

  <img src="assets/icon.png" alt="ScrcpyDock Logo" width="100" />

  # ScrcpyDock

  **Lightweight, Native Desktop Control Panel & Auto-Docking Studio for Scrcpy & Android ADB**

  [![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/Mufe3/ScrcpyDock)
  [![Framework](https://img.shields.io/badge/Flutter-3.x%20Desktop-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Engine](https://img.shields.io/badge/Powered%20By-Scrcpy%203.1+-2ECC71?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Genymobile/scrcpy)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

  <br />

  [English](README.md) • [Bahasa Indonesia](README_ID.md) • [Download Releases](https://github.com/Mufe3/ScrcpyDock/releases) • [Report Bug](https://github.com/Mufe3/ScrcpyDock/issues)

</div>

---

## ⚡ What is ScrcpyDock?

**ScrcpyDock** is a next-generation graphical controller and companion studio for [Genymobile/scrcpy](https://github.com/Genymobile/scrcpy). Built with **native Flutter C++ desktop engine**, ScrcpyDock automatically snaps and docks right next to your active phone mirror window. It allows you to control display quality, audio routing, studio microphone injection, multi-device management, and touch macro automation without memorizing a single CLI command.

Unlike heavy web/Electron-based wrappers that consume hundreds of megabytes of RAM, ScrcpyDock is ultra-compact (~20 MB portable package), launches instantaneously, and uses less than 80 MB of system memory.

---

## 📊 Comparison: Why ScrcpyDock?

| Feature / Metric | **ScrcpyDock** | **Escrcpy** (Electron) | **Standard Scrcpy** (CLI) |
| :--- | :---: | :---: | :---: |
| **Download / Package Size** | **~20 MB** (Portable) | ~145 MB | ~15 MB |
| **RAM Usage** | **~70 – 90 MB** | 350 – 500 MB | ~50 MB |
| **Startup Speed** | **Instant (< 0.5s)** | 2 – 4 seconds | Instant |
| **Window Auto-Docking** | ✅ **Native side-by-side snap** | ❌ Floating / Rigid | ❌ None |
| **Foldable Mini-Dock (48px)** | ✅ **Yes (One-click toggle)** | ❌ None | ❌ None |
| **Built-in Macro Automation** | ✅ **Visual Recorder + Loop** | ⚠️ Complex scripts | ❌ None |
| **Wi-Fi Scanner (Port 5555)** | ✅ **One-click auto discover** | ✅ Yes | ❌ Manual IP command |
| **Studio Mic & Audio Hub** | ✅ **Live waveform visualizer** | ⚠️ Basic forward | ❌ CLI flag only |
| **License & Freedom** | 🟢 **100% Free & Open Source (MIT)** | ⚠️ Moving to paid license | 🟢 Free (Apache 2.0) |

---

## ✨ Key Features

### 🎛️ 1. Intuitive Phone Controller
- Quick navigation buttons: Back, Home, App Switcher, Volume Up/Down, Power, and Notification Shade.
- One-click screen state controls: Turn phone screen off while mirroring, Stay Awake, Lock/Unlock.
- Clipboard synchronizer: Send PC text directly to Android inputs.
- Quick capture: Instant lossless screenshot and MP4 video recording saved straight to your PC.

### 📐 2. Display & Streaming Engine
- Resolution presets: Native Full HD, 1080p, 720p, 480p, or custom dimensions.
- High-framerate tuning: 30 FPS, 60 FPS, 90 FPS, and up to 120 FPS for gaming.
- Dynamic Bitrate: Smooth slider control from 2 Mbps up to 32 Mbps.
- Modern Codecs: Full support for H.264, H.265 (HEVC), and AV1 hardware acceleration.

### 🎙️ 3. Studio Audio & Microphone Hub
- Forward Android system audio directly to PC headphones/speakers with ultra-low buffer latency.
- Inject your PC microphone into your phone as if it were a physical headset.
- Live audio waveform visualizer showing streaming activity and mute states.

### 🤖 4. Built-in Macro Studio
- Record real touch, swipe, click, and delay sequences directly from your phone.
- Save and organize macros into reusable JSON scripts.
- Adjust playback speed (0.5x, 1x, 2x, 5x, 10x) and loop iterations.
- Multi-device runner: Execute the same macro across multiple connected phones simultaneously!

### 📡 5. Wireless ADB & Device Manager
- Automatic local network scanner for ADB TCP/IP port `5555`.
- Wi-Fi ADB pairing QR generator for seamless wireless debugging.
- Multi-device selector with real-time connection status indicators.

---

## 🚀 Quick Start (Portable, No Installation Required)

ScrcpyDock is completely self-contained. It comes bundled with the official `scrcpy` binary, `adb`, and FFmpeg codecs.

1. Download the latest **`ScrcpyDock-v1.0.0-windows-x64.zip`** from [Releases](https://github.com/Mufe3/ScrcpyDock/releases).
2. Extract the zip folder anywhere on your PC (e.g., `D:\ScrcpyDock`).
3. Enable **USB Debugging** on your Android phone:
   - Go to `Settings > About Phone` and tap **Build Number** 7 times.
   - Go to `Developer Options` and enable **USB Debugging**.
4. Double click **`ScrcpyDock.exe`** (or run the installer `ScrcpyDock-v1.0.0-windows-setup-x64.exe`) and click **Start Mirroring**!

---

## ⌨️ Useful Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| **`Alt + D`** | Toggle Mini-Dock mode (Collapse to 48px strip / Expand) |
| **`Alt + P`** | Power button (Turn screen on / off) |
| **`Alt + B`** | Back button |
| **`Alt + H`** | Home button |
| **`Alt + S`** | App Switcher |
| **`Alt + O`** | Turn Android physical screen off while keeping PC mirror active |

---

## 🛠️ Building from Source

If you want to modify or build ScrcpyDock yourself:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (Version 3.13+)
- Visual Studio 2022 with **Desktop development with C++** workload.

### Build Steps
```bash
# 1. Clone repository
git clone https://github.com/Mufe3/ScrcpyDock.git
cd ScrcpyDock

# 2. Get dependencies
flutter pub get

# 3. Run in development mode
flutter run -d windows

# 4. Compile optimized standalone Release bundle
flutter build windows
```
The output executable will be created in `build\windows\x64\runner\Release\`.

---

## 💖 Support the Developer

If ScrcpyDock helps your daily workflow, gaming, or streaming, consider supporting ongoing development:

<div align="center">

  [![Saweria](https://img.shields.io/badge/Saweria-Dukung%20Kreator-059669?style=for-the-badge&logo=google-pay&logoColor=white)](https://saweria.co/Mufe3)
  &nbsp;&nbsp;
  [![Ko-fi](https://img.shields.io/badge/Ko--fi-Buy%20Me%20A%20Coffee-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/mufe3)
  &nbsp;&nbsp;
  [![PayPal](https://img.shields.io/badge/PayPal-Send%20Tip-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.me/Mykulo)

</div>

---

## 📜 Credits & License

- **Scrcpy**: Powered by [Genymobile/scrcpy](https://github.com/Genymobile/scrcpy) by Romain Vimont.
- **Engine**: Built with [Flutter Desktop](https://flutter.dev).
- **License**: Released under the [MIT License](LICENSE).
