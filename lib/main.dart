import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:math' as math;
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:win32/win32.dart';

typedef _KeybdEventC = Void Function(Uint8 bVk, Uint8 bScan, Uint32 dwFlags, IntPtr dwExtraInfo);
typedef _KeybdEventDart = void Function(int bVk, int bScan, int dwFlags, int dwExtraInfo);

void _callKeybdEvent(int bVk, int bScan, int dwFlags, int dwExtraInfo) {
  if (Platform.environment['FLUTTER_TEST'] == 'true') return;
  try {
    final user32 = DynamicLibrary.open('user32.dll');
    final keybdEvent = user32.lookupFunction<_KeybdEventC, _KeybdEventDart>('keybd_event');
    keybdEvent(bVk, bScan, dwFlags, dwExtraInfo);
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(320, 520),
    minimumSize: Size(48, 520),
    maximumSize: Size(320, 520),
    center: false,
    backgroundColor: Color(0xFF131518),
    titleBarStyle: TitleBarStyle.hidden,
    title: 'ScrcpyDock',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPosition(const Offset(20, 40));
  });

  runApp(const ScrcpyPremiumApp());
}

final ValueNotifier<bool> appThemeModeNotifier = ValueNotifier<bool>(true);

class PanelTheme {
  final bool isDark;
  const PanelTheme(this.isDark);

  Color get bgMain => isDark ? const Color(0xFF121417) : const Color(0xFFF6F8FA);
  Color get bgHeader => isDark ? const Color(0xFF181B20) : const Color(0xFFFFFFFF);
  Color get bgCard => isDark ? const Color(0xFF16191E) : const Color(0xFFFFFFFF);
  Color get bgSubCard => isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA);
  Color get bgDock => isDark ? const Color(0xFF111317) : const Color(0xFFFFFFFF);
  Color get bgTabContainer => isDark ? const Color(0xFF181B20) : const Color(0xFFEAEEF2);
  Color get bgTabActive => isDark ? const Color(0xFF262C36) : const Color(0xFFFFFFFF);
  Color get bgButton => isDark ? const Color(0xFF181A1F) : const Color(0xFFF3F4F6);
  Color get bgSegmentInactive => isDark ? const Color(0xFF16191E) : const Color(0xFFEAEEF2);
  Color get bgModeBox => isDark ? const Color(0xFF13151A) : const Color(0xFFEAEEF2);

  Color get borderPrimary => isDark ? const Color(0xFF282D37) : const Color(0xFFD0D7DE);
  Color get borderSecondary => isDark ? const Color(0xFF21262D) : const Color(0xFFE1E4E8);
  Color get borderSubtle => isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
  Color get borderHeaderIcon => isDark ? const Color(0xFF38404D) : const Color(0xFFD0D7DE);

  Color get textPrimary => isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);
  Color get textSecondary => isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76);
  Color get textMuted => isDark ? const Color(0xFF7D8590) : const Color(0xFF8C959F);

  Color get divider => isDark ? const Color(0xFF222630) : const Color(0xFFE1E4E8);
  Color get toastBg => isDark ? const Color(0xFF262C36) : const Color(0xFFFFFFFF);
  Color get headerIconBg => isDark ? const Color(0xFF1E2228) : const Color(0xFFEAEEF2);
  Color get inputFill => isDark ? const Color(0xFF13151A) : const Color(0xFFF6F8FA);
  Color get activeCardBg => isDark ? const Color(0x1F2F81F7) : const Color(0xFFEFF6FF);
  Color get brandPrimary => isDark ? const Color(0xFF2F81F7) : const Color(0xFF0969DA);
}

class ScrcpyPremiumApp extends StatelessWidget {
  const ScrcpyPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appThemeModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'ScrcpyDock',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF6F8FA),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0969DA),
              surface: Colors.white,
            ),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD0D7DE), width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              textStyle: const TextStyle(
                color: Color(0xFF1F2328),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              waitDuration: const Duration(milliseconds: 250),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121417),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2F81F7),
              surface: Color(0xFF181B20),
            ),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: const Color(0xFF1E2228),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF38404D), width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              textStyle: const TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              waitDuration: const Duration(milliseconds: 250),
            ),
          ),
          home: const DashboardPanel(),
        );
      },
    );
  }
}

class DeviceInfo {
  final String serial;
  final String model;
  final String state;
  final bool isWifi;

  DeviceInfo({
    required this.serial,
    required this.model,
    required this.state,
    required this.isWifi,
  });

  String get displayName => model.isNotEmpty ? '$model ($serial)' : serial;
}

class MacroStep {
  final String action; // 'tap', 'double_tap', 'long_press', 'rapid_tap', 'swipe', 'swipe_up', 'swipe_down', 'swipe_left', 'swipe_right', 'edge_back', 'key_back', 'key_home', 'key_recent', 'key_notif'
  final int x;
  final int y;
  final int endX;
  final int endY;
  final int durationMs;
  final int delayMs;
  final int repeatCount;
  final String description;

  MacroStep({
    required this.action,
    this.x = 540,
    this.y = 960,
    this.endX = 540,
    this.endY = 400,
    this.durationMs = 300,
    this.delayMs = 500,
    this.repeatCount = 1,
    required this.description,
  });

  MacroStep copyWith({
    String? action,
    int? x,
    int? y,
    int? endX,
    int? endY,
    int? durationMs,
    int? delayMs,
    int? repeatCount,
    String? description,
  }) {
    return MacroStep(
      action: action ?? this.action,
      x: x ?? this.x,
      y: y ?? this.y,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
      durationMs: durationMs ?? this.durationMs,
      delayMs: delayMs ?? this.delayMs,
      repeatCount: repeatCount ?? this.repeatCount,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'action': action,
    'x': x,
    'y': y,
    'endX': endX,
    'endY': endY,
    'durationMs': durationMs,
    'delayMs': delayMs,
    'repeatCount': repeatCount,
    'description': description,
  };

  factory MacroStep.fromJson(Map<String, dynamic> json) => MacroStep(
    action: json['action'] as String? ?? 'tap',
    x: (json['x'] as num?)?.toInt() ?? 540,
    y: (json['y'] as num?)?.toInt() ?? 960,
    endX: (json['endX'] as num?)?.toInt() ?? 540,
    endY: (json['endY'] as num?)?.toInt() ?? 400,
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 300,
    delayMs: (json['delayMs'] as num?)?.toInt() ?? 500,
    repeatCount: (json['repeatCount'] as num?)?.toInt() ?? 1,
    description: json['description'] as String? ?? '',
  );
}

class SavedMacro {
  final String id;
  final String name;
  final String createdAt;
  final int loopCount;
  final double speed;
  final int screenWidth;
  final int screenHeight;
  final List<MacroStep> steps;
  final String filePath;

  SavedMacro({
    required this.id,
    required this.name,
    required this.createdAt,
    this.loopCount = 1,
    this.speed = 1.0,
    this.screenWidth = 720,
    this.screenHeight = 1640,
    required this.steps,
    this.filePath = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt,
    'loopCount': loopCount,
    'speed': speed,
    'screenWidth': screenWidth,
    'screenHeight': screenHeight,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory SavedMacro.fromJson(Map<String, dynamic> json, [String filePath = '']) => SavedMacro(
    id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] as String? ?? 'Makro',
    createdAt: json['createdAt'] as String? ?? '',
    loopCount: (json['loopCount'] as num?)?.toInt() ?? 1,
    speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
    screenWidth: (json['screenWidth'] as num?)?.toInt() ?? 720,
    screenHeight: (json['screenHeight'] as num?)?.toInt() ?? 1640,
    steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => MacroStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    filePath: filePath,
  );
}

typedef TinyTaskStep = MacroStep;

class DeviceRunnerStatus {
  final String serial;
  String? assignedMacroName;
  SavedMacro? assignedMacro;
  bool isRunning;
  int currentLoop;
  int currentStep;
  bool shouldStop;
  int loopCount;
  double speed;

  DeviceRunnerStatus({
    required this.serial,
    this.assignedMacroName,
    this.assignedMacro,
    this.isRunning = false,
    this.currentLoop = 0,
    this.currentStep = 0,
    this.shouldStop = false,
    this.loopCount = 1,
    this.speed = 1.0,
  });
}

class StudioAudioVisualizer extends StatefulWidget {
  final bool isStreaming;
  final bool isMuted;

  const StudioAudioVisualizer({
    super.key,
    required this.isStreaming,
    required this.isMuted,
  });

  @override
  State<StudioAudioVisualizer> createState() => _StudioAudioVisualizerState();
}

class _StudioAudioVisualizerState extends State<StudioAudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isStreaming || widget.isMuted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(11, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: 3.5,
            height: widget.isMuted ? 5.0 : 4.0,
            decoration: BoxDecoration(
              color: widget.isMuted ? const Color(0xFFF85149) : const Color(0xFF30363D),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      );
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final t = _animController.value * 2 * math.pi;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(11, (i) {
            final offset = i * 0.58;
            final dynamicH = (math.sin(t + offset).abs() * 22 + math.cos(t * 1.5 + offset).abs() * 10).clamp(5.0, 32.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: dynamicH,
              decoration: BoxDecoration(
                color: const Color(0xFF58A6FF),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class DashboardPanel extends StatefulWidget {
  const DashboardPanel({super.key});

  @override
  State<DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<DashboardPanel> with WindowListener {
  bool get _isDarkMode => appThemeModeNotifier.value;
  PanelTheme get t => PanelTheme(_isDarkMode);

  late bool _isIndonesian = (Platform.localeName.toLowerCase().startsWith('id'));
  String tr(String en, String id) => _isIndonesian ? id : en;

  void _toggleLanguage() {
    setState(() {
      _isIndonesian = !_isIndonesian;
    });
    _showToast(_isIndonesian ? "Bahasa Indonesia aktif" : "English language active");
  }

  void _toggleThemeMode() {
    setState(() {
      appThemeModeNotifier.value = !appThemeModeNotifier.value;
    });
  }

  String get _userHomeDir {
    return Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
  }

  void _openFolderInFileManager(String folderPath) {
    try {
      final dir = Directory(folderPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      if (Platform.isWindows) {
        // Windows explorer.exe menganggap '/' sebagai flag parameter CLI.
        // Wajib diubah menjadi backslash '\' agar Explorer langsung membuka folder tujuan spesifik.
        final winPath = dir.path.replaceAll('/', r'\');
        Process.run('explorer.exe', [winPath]);
      } else if (Platform.isMacOS) {
        Process.run('open', [dir.path]);
      } else {
        Process.run('xdg-open', [dir.path]);
      }
    } catch (_) {}
  }

  Future<void> _openUrlInBrowser(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else {
        await Process.run('xdg-open', [url]);
      }
    } catch (_) {}
  }

  final String _donationSaweriaUrl = 'https://saweria.co/Mufe3';
  final String _donationKofiUrl = 'https://ko-fi.com/mufe3';
  final String _donationPaypalUrl = 'https://www.paypal.me/Mykulo';


  String get scrcpyIconPath {
    final currentDir = Directory.current.path;
    final devPath = File('$currentDir/assets/icon.png').absolute.path;
    if (File(devPath).existsSync()) return devPath;
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final installedPath = File('$exeDir/data/flutter_assets/assets/icon.png').absolute.path;
    if (File(installedPath).existsSync()) return installedPath;
    return devPath;
  }

  String get scrcpyExePath {
    final currentDir = Directory.current.path;
    final exeName = Platform.isWindows ? 'scrcpy.exe' : 'scrcpy';
    final devPath = '$currentDir/assets/$exeName';
    if (File(devPath).existsSync()) return devPath;
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final installedPath = '$exeDir/data/flutter_assets/assets/$exeName';
    if (File(installedPath).existsSync()) return installedPath;
    return 'scrcpy';
  }

  String get adbExePath {
    final currentDir = Directory.current.path;
    final exeName = Platform.isWindows ? 'adb.exe' : 'adb';
    final devPath = '$currentDir/assets/$exeName';
    if (File(devPath).existsSync()) return devPath;
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final installedPath = '$exeDir/data/flutter_assets/assets/$exeName';
    if (File(installedPath).existsSync()) return installedPath;
    return 'adb';
  }

  // State Navigation & Layout
  bool _isFolded = false;
  int _selectedTab = 0; // 0: Kontrol, 1: Kualitas, 2: Macro, 3: Perangkat, 4: About
  final ScrollController _mainScrollController = ScrollController();
  static const double _gapBetweenWindows = 10.0;
  static const int _keyeventfKeyup = 0x0002;

  // MacroDock Engine & Live Recording State
  bool _isMacroRunning = false;
  bool _isMacroRecording = false;
  int _macroLoopCount = 1; // 1, 5, 10, -1 (Infinite)
  int _macroCurrentLoop = 0;
  int _macroCurrentStep = -1;
  double _macroSpeed = 1.0; // 1.0, 1.5, 2.0
  final List<MacroStep> _macroSteps = [];
  String? _currentLoadedMacroName;
  int _macroViewMode = 0; // 0: Studio (Device Aktif), 1: Multi-Runner (Semua HP)
  final Map<String, DeviceRunnerStatus> _multiDeviceRunners = {};
  Timer? _recordTimer;
  DateTime? _lastActionUpTime;
  DateTime? _mouseDownTime;
  int _mouseDownX = 0;
  int _mouseDownY = 0;
  bool _wasMouseDown = false;
  bool _isDownInsideScrcpy = false;
  int _deviceScreenWidth = 720;
  int _deviceScreenHeight = 1640;

  // Konfigurasi & Toggles
  bool _chkScreenOff = true;
  bool _chkAlwaysTop = true;
  bool _chkAudioToPC = true;
  bool _chkStayAwake = true;
  bool _chkShowTouches = false;
  bool _chkPowerOffOnClose = false;
  bool _chkRecordScreen = false;
  bool _chkAutoFitAspectRatio = true;
  final Map<int, Size> _lastObservedWindowSizes = {};
  final Map<int, DateTime> _lastResizeTimes = {};
  final Map<int, bool> _lastResizeAxis = {};
  String _liveScreenRecordLocalFile = '';

  // Mode Operasi Scrcpy
  String _scrcpyMode = 'screen'; // 'screen', 'camera', 'audio', 'otg'
  String _cameraFacing = 'front'; // 'front', 'back'
  String _cameraOrientation = 'portrait'; // 'portrait' (Bentuk HP Tegak), 'landscape' (Mendatar)
  String _otgMouseMode = 'sdk'; // 'sdk' (Bebas Keluar Masuk PC), 'uhid' (Kunci Kursor / Mode Game HID)
  final String _recordFormat = 'mp4'; // 'mp4', 'mkv'

  // Parameter Kualitas Streaming
  String _selectedResolution = '1080p'; // 'Original', '1080p', '720p', '480p'
  int _selectedFps = 60; // 30, 60, 90, 120
  int _selectedBitrate = 16; // 4, 8, 16, 24 (Mbps)
  String _selectedCodec = 'h264'; // 'h264', 'h265'

  // Wi-Fi Wireless State & Network Diagnostics
  String _deviceIp = '';
  String _deviceSsid = '';
  String _pcLocalIp = '';
  bool _isConnectingWifi = false;
  String _wifiStatusMsgEn = 'Select a connection method below.';
  String _wifiStatusMsgId = 'Pilih metode sambungan di bawah.';
  String get _wifiStatusMsg => _isIndonesian ? _wifiStatusMsgId : _wifiStatusMsgEn;
  void _setWifiStatus(String en, String id) {
    _wifiStatusMsgEn = en;
    _wifiStatusMsgId = id;
  }
  bool _isWifiConnected = false;
  int _wirelessMethodTab = 0; // 0: Kode QR, 1: Otomatis USB, 2: Android 11+ Pairing, 3: Manual IP, 4: Scan Jaringan

  // Input Controllers for Wi-Fi
  final TextEditingController _manualIpController = TextEditingController();
  final TextEditingController _manualPortController = TextEditingController(text: '5555');
  final TextEditingController _pairingHostController = TextEditingController();
  final TextEditingController _pairingCodeController = TextEditingController();
  final TextEditingController _pairingConnectPortController = TextEditingController();

  // Network Scan State
  bool _isScanningWifi = false;
  final List<Map<String, String>> _discoveredDevices = [];

  // QR Code Wireless Pairing State
  String _qrPairingName = '';
  String _qrPairingPassword = '';
  String _qrPairingPayload = '';
  bool _isQrPairingActive = false;
  Timer? _qrMdnsPollTimer;
  String _qrPairingStatusEn = 'Waiting for phone camera scan...';
  String _qrPairingStatusId = 'Menunggu pemindaian kamera HP...';
  String get _qrPairingStatus => _isIndonesian ? _qrPairingStatusId : _qrPairingStatusEn;
  void _setQrPairingStatus(String en, String id) {
    _qrPairingStatusEn = en;
    _qrPairingStatusId = id;
  }

  // Status & Multi-Device Runtime
  bool _isDisplayOff = false;
  // Orientasi Android Asli (0: Auto-Rotate Sensor, 1: Tegak 0°, 2: Mendatar 90°)
  int _androidOrientationMode = 0;
  // Tata Letak Multi-Device ('grid': Kisi adaptif 2-10+ device, 'horizontal': Berdampingan)
  String _multiWindowLayout = 'grid';

  // Live Screen Recording (On-Demand saat Mirror Aktif)
  Process? _liveScreenRecordProcess;
  bool _isLiveScreenRecording = false;
  int _liveScreenRecordSeconds = 0;
  Timer? _liveScreenRecordTimer;

  // Studio Mic Hub State
  bool _isMicMuted = false;
  int _micStreamingSeconds = 0;
  Timer? _micStreamingTimer;

  // Studio Webcam Hub State
  int _webcamStreamingSeconds = 0;
  Timer? _webcamStreamingTimer;

  // Hardware OTG Deck State
  int _otgActiveSeconds = 0;
  Timer? _otgActiveTimer;

  void _toggleMicMute() async {
    final nextState = !_isMicMuted;
    setState(() {
      _isMicMuted = nextState;
    });
    final serial = _selectedDeviceSerial.isNotEmpty
        ? _selectedDeviceSerial
        : (_connectedDevices.isNotEmpty ? _connectedDevices.first : '');
    if (serial.isNotEmpty) {
      try {
        await Process.run(adbExePath, ['-s', serial, 'shell', 'input', 'keyevent', '91']);
      } catch (_) {}
    }
    _showToast(nextState ? tr('Phone Mic Muted', 'Mikrofon HP Dibisukan (Muted)') : tr('Phone Mic Unmuted (Active)', 'Mikrofon HP Aktif (Unmuted)'));
  }

  bool _lastScrcpyMinimized = false;
  bool _lastPanelMinimized = false;
  bool _isRestoring = false;
  String _connectionStatus = 'Memeriksa ADB...';
  String _connectedDeviceName = '';
  List<String> _connectedDevices = [];
  List<DeviceInfo> _connectedDevicesList = [];
  String _selectedDeviceSerial = '';
  Process? _scrcpyProcess;
  final Map<String, Process> _activeScrcpyProcesses = {};
  int _scrcpyHwnd = 0;
  final Map<String, int> _deviceHwnds = {};
  final List<String> _mirroredSerialOrder = [];
  bool _isSyncing = false;
  Timer? _timer;
  Timer? _syncTimer;

  List<String> _withSerial(List<String> args) {
    if (_selectedDeviceSerial.isNotEmpty) {
      return ['-s', _selectedDeviceSerial, ...args];
    }
    return args;
  }

  // Floating Toast Notification
  String? _toastMessage;
  Timer? _toastTimer;

  void _showToast(String message) {
    _toastTimer?.cancel();
    if (mounted) {
      setState(() {
        _toastMessage = message;
      });
      _toastTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _toastMessage = null;
          });
        }
      });
    }
  }

  void _applyDarkDwmTheme() {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true') return;
    try {
      final title0Ptr = TEXT('ScrcpyDock');
      final title1Ptr = TEXT('Scrcpy Control Panel');
      final title2Ptr = TEXT('scrcpy_premium_panel');
      final classPtr = TEXT('FLUTTER_RUNNER_WIN32_WINDOW');
      var hwnd = FindWindow(classPtr, title0Ptr);
      if (hwnd == 0) hwnd = FindWindow(classPtr, title1Ptr);
      if (hwnd == 0) hwnd = FindWindow(classPtr, title2Ptr);
      if (hwnd == 0) hwnd = FindWindow(classPtr, nullptr);
      free(title0Ptr);
      free(title1Ptr);
      free(title2Ptr);
      free(classPtr);
      if (hwnd == 0) return;

      final pvDarkMode = calloc<BOOL>()..value = 1;
      DwmSetWindowAttribute(hwnd, 20, pvDarkMode, sizeOf<BOOL>());
      free(pvDarkMode);

      final pvBorderColor = calloc<COLORREF>()..value = 0xFFFFFFFE;
      DwmSetWindowAttribute(hwnd, 34, pvBorderColor, sizeOf<COLORREF>());
      free(pvBorderColor);

      final pvCorner = calloc<DWORD>()..value = 2; // DWMWCP_ROUND
      DwmSetWindowAttribute(hwnd, 33, pvCorner, sizeOf<DWORD>());
      free(pvCorner);
    } catch (_) {}
  }

  int _getScrcpyHwnd() {
    if (!Platform.isWindows) return 0;
    if (_selectedDeviceSerial.isNotEmpty && _deviceHwnds.containsKey(_selectedDeviceSerial)) {
      final h = _deviceHwnds[_selectedDeviceSerial]!;
      if (h != 0 && IsWindow(h) != 0) return h;
    }
    if (_scrcpyHwnd != 0 && IsWindow(_scrcpyHwnd) != 0) {
      return _scrcpyHwnd;
    }
    for (var h in _deviceHwnds.values) {
      if (h != 0 && IsWindow(h) != 0) return h;
    }
    final classSdl = TEXT('SDL_app');
    var hwnd = FindWindow(classSdl, nullptr);
    free(classSdl);
    if (hwnd == 0) {
      final classScrcpy = TEXT('scrcpy');
      hwnd = FindWindow(classScrcpy, nullptr);
      free(classScrcpy);
    }
    if (hwnd != 0) _scrcpyHwnd = hwnd;
    return hwnd;
  }

  void _focusScrcpyWindow() {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true') return;
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd == 0) return;
    try {
      final currentThreadId = GetCurrentThreadId();
      final targetThreadId = GetWindowThreadProcessId(scrcpyHwnd, nullptr);
      if (currentThreadId != targetThreadId) {
        AttachThreadInput(currentThreadId, targetThreadId, TRUE);
      }
      SetForegroundWindow(scrcpyHwnd);
      SetFocus(scrcpyHwnd);
      if (currentThreadId != targetThreadId) {
        AttachThreadInput(currentThreadId, targetThreadId, FALSE);
      }
    } catch (_) {}
  }

  void _sendScrcpyScreenPower({required bool turnOff}) async {
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd == 0 || Platform.environment['FLUTTER_TEST'] == 'true') {
      if (mounted) {
        setState(() {
          _isDisplayOff = turnOff;
        });
      }
      return;
    }

    try {
      final currentThreadId = GetCurrentThreadId();
      final targetThreadId = GetWindowThreadProcessId(scrcpyHwnd, nullptr);

      if (currentThreadId != targetThreadId) {
        AttachThreadInput(currentThreadId, targetThreadId, TRUE);
      }
      SetForegroundWindow(scrcpyHwnd);
      SetFocus(scrcpyHwnd);
      if (currentThreadId != targetThreadId) {
        AttachThreadInput(currentThreadId, targetThreadId, FALSE);
      }

      await Future.delayed(const Duration(milliseconds: 60));

      if (turnOff) {
        // Alt + O
        _callKeybdEvent(0xA4, 0x38, 0, 0); // LALT down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x4F, 0x18, 0, 0); // 'O' down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x4F, 0x18, _keyeventfKeyup, 0); // 'O' up
        _callKeybdEvent(0xA4, 0x38, _keyeventfKeyup, 0); // LALT up

        PostMessage(scrcpyHwnd, 0x0104, 0x4F, 0x20180001); // WM_SYSKEYDOWN
        PostMessage(scrcpyHwnd, 0x0105, 0x4F, 0xE0180001); // WM_SYSKEYUP
      } else {
        // Shift + Alt + O
        _callKeybdEvent(0xA0, 0x2A, 0, 0); // LSHIFT down
        _callKeybdEvent(0xA4, 0x38, 0, 0); // LALT down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x4F, 0x18, 0, 0); // 'O' down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x4F, 0x18, _keyeventfKeyup, 0); // 'O' up
        _callKeybdEvent(0xA4, 0x38, _keyeventfKeyup, 0); // LALT up
        _callKeybdEvent(0xA0, 0x2A, _keyeventfKeyup, 0); // LSHIFT up

        PostMessage(scrcpyHwnd, 0x0104, 0x4F, 0x20180001);
        PostMessage(scrcpyHwnd, 0x0105, 0x4F, 0xE0180001);
      }

      if (mounted) {
        setState(() {
          _isDisplayOff = turnOff;
        });
      }
    } catch (e) {
      debugPrint("Gagal kirim shortcut layar: $e");
    }
  }

  // Format detik ke mm:ss
  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Perekam Layar Dinamis (On-Demand via Engine Scrcpy FFmpeg PC)
  void _startLiveScreenRecord() async {
    if (_isLiveScreenRecording) return;
    final serial = _selectedDeviceSerial.isNotEmpty
        ? _selectedDeviceSerial
        : (_connectedDevices.isNotEmpty ? _connectedDevices.first : '');
    if (serial.isEmpty) {
      _showToast(tr('No connected device to record', 'Tidak ada perangkat terhubung untuk direkam'));
      return;
    }

    final videoDir = Directory('$_userHomeDir/Videos/Scrcpy_Recordings');
    if (!videoDir.existsSync()) videoDir.createSync(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localFile = '${videoDir.path}/record_$timestamp.mp4';
    _liveScreenRecordLocalFile = localFile;
    _liveScreenRecordSeconds = 0;

    try {
      final List<String> recordArgs = [
        '-s', serial,
        '--no-playback',
        '--window-title', 'ScrcpyRecordHidden_$timestamp',
        '--window-x', '-9999',
        '--window-y', '-9999',
        '--window-width', '1',
        '--window-height', '1',
        '--window-borderless',
        '--record', localFile,
        '--record-format', 'mp4',
        '--video-bit-rate', '${_selectedBitrate}M',
        '--max-fps', '$_selectedFps',
      ];
      if (_selectedResolution == '1080p') {
        recordArgs.addAll(['--max-size', '1080']);
      } else if (_selectedResolution == '720p') {
        recordArgs.addAll(['--max-size', '720']);
      }

      final proc = await Process.start(
        scrcpyExePath,
        recordArgs,
        environment: {
          'SCRCPY_ICON_PATH': scrcpyIconPath,
          'SCRCPY_ICON_DIR': File(scrcpyIconPath).parent.path,
        },
      );
      _liveScreenRecordProcess = proc;
      _isLiveScreenRecording = true;

      _liveScreenRecordTimer?.cancel();
      _liveScreenRecordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isLiveScreenRecording) {
          timer.cancel();
          return;
        }
        setState(() {
          _liveScreenRecordSeconds++;
        });
      });

      if (mounted) setState(() {});
      _showToast(tr('Screen recording MP4 started via Scrcpy engine...', 'Merekam layar MP4 dimulai via engine Scrcpy...'));
    } catch (e) {
      _showToast(tr('Failed to start screen recording: $e', 'Gagal memulai perekaman layar: $e'));
    }
  }

  void _stopLiveScreenRecord() async {
    if (!_isLiveScreenRecording) return;
    _isLiveScreenRecording = false;
    _liveScreenRecordTimer?.cancel();
    final proc = _liveScreenRecordProcess;
    final localFile = _liveScreenRecordLocalFile;

    _showToast(tr('Finalizing MP4 video...', 'Memfinalisasi video MP4...'));

    if (proc != null) {
      try {
        if (Platform.environment['FLUTTER_TEST'] != 'true') {
          if (Platform.isWindows) {
            // Kirim sinyal tutup graceful via taskkill (tanpa /f) agar Scrcpy/FFmpeg menulis moov atom dengan bersih
            await Process.run('taskkill', ['/pid', proc.pid.toString()]);
          } else {
            // Di Linux/macOS kirim sinyal SIGINT (-2) agar FFmpeg/Scrcpy flush moov atom dengan bersih
            await Process.run('kill', ['-2', proc.pid.toString()]);
          }
        }
        await proc.exitCode.timeout(const Duration(milliseconds: 3500), onTimeout: () {
          proc.kill();
          return 0;
        });
      } catch (_) {
        try { proc.kill(); } catch (_) {}
      }
    }
    _liveScreenRecordProcess = null;
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 600));
    final file = File(localFile);
    if (file.existsSync() && file.lengthSync() > 1000) {
      _showToast(tr('MP4 video saved & ready to open!', 'Video MP4 tersimpan & siap dibuka!'));
    } else {
      _showToast(tr('Video recording saved in Videos folder.', 'Rekaman video tersimpan di folder Videos.'));
    }
  }

  // Rotasi Layar HP Alami & Sensor Auto-Rotate (Dual Normal Function)
  // mode: 0 = Sensor Otomatis, 1 = Tegak (Portrait 0°), 2 = Mendatar (Landscape 90°)
  void _setAndroidOrientation(int mode) async {
    final serial = _selectedDeviceSerial.isNotEmpty
        ? _selectedDeviceSerial
        : (_connectedDevices.isNotEmpty ? _connectedDevices.first : '');

    setState(() {
      _androidOrientationMode = mode;
    });

    if (serial.isNotEmpty) {
      if (mode == 0) {
        // Mode 0: Sensor Auto-Rotate Normal Aktif
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'set-ignore-orientation-request', '0']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'user-rotation', 'free']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'settings', 'put', 'system', 'accelerometer_rotation', '1']);
        _showToast(tr('Phone Auto-Rotate Sensor Active (Automatic)', 'Sensor Auto-Rotate HP Aktif (Otomatis)'));
      } else if (mode == 1) {
        // Mode 1: Kunci Tegak (Portrait 0°)
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'set-ignore-orientation-request', '0']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'user-rotation', 'lock', '0']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'settings', 'put', 'system', 'accelerometer_rotation', '0']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'settings', 'put', 'system', 'user_rotation', '0']);
        _showToast(tr('Phone screen locked Portrait (0°)', 'Layar HP dikunci Tegak (Portrait 0°)'));
      } else if (mode == 2) {
        // Mode 2: Kunci Mendatar (Landscape 90°)
        // Paksa aplikasi (termasuk Reels/TikTok/Beranda) untuk berputar mendatar
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'set-ignore-orientation-request', '1']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'cmd', 'window', 'user-rotation', 'lock', '1']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'settings', 'put', 'system', 'accelerometer_rotation', '0']);
        await Process.run(adbExePath, ['-s', serial, 'shell', 'settings', 'put', 'system', 'user_rotation', '1']);
        _showToast(tr('Phone screen rotated Landscape (90°)', 'Layar HP diputar Mendatar (Landscape 90°)'));
      }
    }

    // Adaptasi ukuran & aspect ratio jendela Scrcpy
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd != 0 && Platform.environment['FLUTTER_TEST'] != 'true') {
      try {
        await Future.delayed(const Duration(milliseconds: 250));
        final rect = calloc<RECT>();
        if (GetWindowRect(scrcpyHwnd, rect) != 0) {
          final curW = rect.ref.right - rect.ref.left;
          final curH = rect.ref.bottom - rect.ref.top;
          final curX = rect.ref.left;
          final curY = rect.ref.top;

          if (mode == 2 && curW < curH) {
            // Berputar ke Mendatar (Landscape): sesuaikan ukuran jendela melebar agar YouTube/Video pas & tidak berbar hitam
            final newW = (curH * 1.5).round().clamp(640, 1600);
            final newH = (curW * 0.9).round().clamp(400, 1000);
            SetWindowPos(scrcpyHwnd, 0, curX, curY, newW, newH, SWP_NOZORDER | SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS);
          } else if (mode == 1 && curW > curH) {
            // Berputar ke Tegak (Portrait): kembalikan jendela ke proporsi tegak
            final newW = (curH * 0.55).round().clamp(320, 650);
            final newH = (curW * 0.85).round().clamp(550, 1050);
            SetWindowPos(scrcpyHwnd, 0, curX, curY, newW, newH, SWP_NOZORDER | SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS);
          }
        }
        calloc.free(rect);

        await Future.delayed(const Duration(milliseconds: 100));
        SetForegroundWindow(scrcpyHwnd);
        // Kirim MOD+w (Alt+Ctrl+W) untuk sesuaikan aspect ratio jendela scrcpy & hilangkan garis hitam
        _callKeybdEvent(0xA4, 0x38, 0, 0); // LALT down
        _callKeybdEvent(0xA2, 0x1D, 0, 0); // LCTRL down
        _callKeybdEvent(0x57, 0x11, 0, 0); // 'W' down
        await Future.delayed(const Duration(milliseconds: 20));
        _callKeybdEvent(0x57, 0x11, _keyeventfKeyup, 0); // 'W' up
        _callKeybdEvent(0xA2, 0x1D, _keyeventfKeyup, 0); // LCTRL up
        _callKeybdEvent(0xA4, 0x38, _keyeventfKeyup, 0); // LALT up
        await Future.delayed(const Duration(milliseconds: 150));
        _syncScrcpyToPanel();
      } catch (_) {}
    }
  }

  void _cycleAndroidOrientation() {
    // Siklus: Auto-Rotate (0) -> Mendatar (2) -> Tegak (1) -> Auto-Rotate (0)
    final nextMode = _androidOrientationMode == 0
        ? 2
        : (_androidOrientationMode == 2 ? 1 : 0);
    _setAndroidOrientation(nextMode);
  }

  Future<String?> _pickFile({required String filter, required String title}) async {
    try {
      if (Platform.isWindows) {
        final script =
            '''[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null; \$d = New-Object System.Windows.Forms.OpenFileDialog; \$d.Filter = '$filter'; \$d.Title = '$title'; if(\$d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){ Write-Output \$d.FileName }''';
        final res = await Process.run('powershell', ['-NoProfile', '-Command', script]);
        final out = res.stdout.toString().trim();
        return out.isNotEmpty ? out : null;
      } else if (Platform.isMacOS) {
        final script = 'POSIX path of (choose file with prompt "$title")';
        final res = await Process.run('osascript', ['-e', script]);
        final out = res.stdout.toString().trim();
        return out.isNotEmpty ? out : null;
      } else {
        final res = await Process.run('zenity', ['--file-selection', '--title=$title']);
        final out = res.stdout.toString().trim();
        return out.isNotEmpty ? out : null;
      }
    } catch (_) {
      return null;
    }
  }

  void _installApk() async {
    _showToast(tr("Open APK file dialog...", "Buka dialog pilih APK..."));
    final apkPath = await _pickFile(
      filter: "APK Files (*.apk)|*.apk|All Files (*.*)|*.*",
      title: tr("Select APK file to install on phone", "Pilih File APK untuk Dipasang ke HP"),
    );
    if (apkPath == null || apkPath.isEmpty) return;

    final fileName = apkPath.split(RegExp(r'[/\\]')).last;
    _showToast(tr("Installing $fileName on phone...", "Memasang $fileName ke HP..."));
    try {
      final res = await Process.run(adbExePath, _withSerial(['install', '-r', apkPath]));
      final out = res.stdout.toString();
      if (out.contains('Success')) {
        _showToast(tr("APK $fileName installed successfully.", "APK $fileName berhasil terpasang."));
      } else {
        _showToast(tr("Result: $out", "Hasil: $out"));
      }
    } catch (e) {
      _showToast(tr("Failed to install APK: $e", "Gagal pasang APK: $e"));
    }
  }

  void _pushFileToDevice() async {
    _showToast(tr("Open file picker...", "Buka dialog pilih berkas..."));
    final filePath = await _pickFile(
      filter: tr("All Files (*.*)|*.*", "Semua Berkas (*.*)|*.*"),
      title: tr("Select file to push to phone (/sdcard/Download/)", "Pilih Berkas untuk Dikirim ke HP (/sdcard/Download/)"),
    );
    if (filePath == null || filePath.isEmpty) return;

    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    _showToast(tr("Pushing $fileName to phone...", "Mengirim $fileName ke HP..."));
    try {
      final res = await Process.run(adbExePath, _withSerial(['push', filePath, '/sdcard/Download/']));
      final out = res.stdout.toString();
      if (out.contains('pushed') || out.contains('1 file pushed') || res.exitCode == 0) {
        // Memicu Android Media Scanner agar foto/video/dokumen langsung muncul di Galeri & Pengelola Berkas
        await Process.run(adbExePath, _withSerial([
          'shell',
          'am',
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file:///sdcard/Download/$fileName',
        ]));
        _showToast(tr("$fileName saved in phone Download folder.", "$fileName tersimpan di folder Download HP."));
      } else {
        _showToast(tr("Push result: $out", "Hasil kirim: $out"));
      }
    } catch (e) {
      _showToast(tr("Failed to push file: $e", "Gagal kirim berkas: $e"));
    }
  }

  void _openPhoneFileManager() async {
    try {
      // 1. Coba Pengelola Berkas resmi Xiaomi / POCO
      final res = await Process.run(adbExePath, _withSerial(['shell', 'monkey', '-p', 'com.mi.android.globalFileexplorer', '1']));
      if (res.exitCode != 0 || res.stdout.toString().contains('No activities')) {
        // 2. Coba Google Files / Android DocumentsUI
        final res2 = await Process.run(adbExePath, _withSerial(['shell', 'monkey', '-p', 'com.google.android.documentsui', '1']));
        if (res2.exitCode != 0) {
          // 3. Coba Samsung MyFiles
          await Process.run(adbExePath, _withSerial(['shell', 'monkey', '-p', 'com.sec.android.app.myfiles', '1']));
        }
      }
      _focusScrcpyWindow();
      _showToast(tr("Opening File Manager on phone.", "Membuka Pengelola File di HP."));
    } catch (_) {}
  }

  void _sendScrcpyNotifShortcut() async {
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd == 0 || Platform.environment['FLUTTER_TEST'] == 'true') return;
    try {
      _focusScrcpyWindow();
      await Future.delayed(const Duration(milliseconds: 30));
      // Alt + N (Scrcpy MOD+n = Expand notification shade)
      _callKeybdEvent(0xA4, 0x38, 0, 0); // LALT down
      await Future.delayed(const Duration(milliseconds: 20));
      _callKeybdEvent(0x4E, 0x31, 0, 0); // 'N' down
      await Future.delayed(const Duration(milliseconds: 20));
      _callKeybdEvent(0x4E, 0x31, _keyeventfKeyup, 0); // 'N' up
      _callKeybdEvent(0xA4, 0x38, _keyeventfKeyup, 0); // LALT up

      PostMessage(scrcpyHwnd, 0x0104, 0x4E, 0x20310001); // WM_SYSKEYDOWN
      PostMessage(scrcpyHwnd, 0x0105, 0x4E, 0xE0310001); // WM_SYSKEYUP
    } catch (_) {}
  }

  void _pasteClipboardToPhone() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text;
      if (text != null && text.isNotEmpty) {
        _focusScrcpyWindow();
        await Future.delayed(const Duration(milliseconds: 50));
        // Alt + V (Scrcpy Paste computer clipboard to device)
        _callKeybdEvent(0xA4, 0x38, 0, 0); // LALT down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x56, 0x2F, 0, 0); // 'V' down
        await Future.delayed(const Duration(milliseconds: 25));
        _callKeybdEvent(0x56, 0x2F, _keyeventfKeyup, 0); // 'V' up
        _callKeybdEvent(0xA4, 0x38, _keyeventfKeyup, 0); // LALT up
        _showToast(tr("Clipboard text pasted to phone.", "Teks clipboard disalin ke HP."));
      } else {
        _showToast(tr("PC Clipboard is empty.", "Clipboard PC masih kosong."));
      }
    } catch (_) {}
  }

  void _takeScreenshot() async {
    try {
      final saveDir = Directory('$_userHomeDir/Pictures/Scrcpy_Screenshots');
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }
      final now = DateTime.now();
      final dateStr =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final filePath = "${saveDir.path}/screenshot_$dateStr.png";

      final result = await Process.run(
        adbExePath,
        _withSerial(['exec-out', 'screencap', '-p']),
        stdoutEncoding: null,
      );

      if (result.stdout is List<int> && (result.stdout as List<int>).isNotEmpty) {
        final file = File(filePath);
        await file.writeAsBytes(result.stdout as List<int>);
        _showToast(tr("Screenshot saved in Pictures folder.", "Screenshot tersimpan di folder Pictures."));
        _focusScrcpyWindow();
      } else {
        _showToast(tr("Failed to take screenshot.", "Gagal mengambil screenshot."));
      }
    } catch (e) {
      _showToast(tr("Screenshot error: $e", "Error screenshot: $e"));
    }
  }

  void _openScreenshotFolder() {
    final saveDir = Directory('$_userHomeDir/Pictures/Scrcpy_Screenshots');
    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }
    _openFolderInFileManager(saveDir.path);
  }

  void _openRecordingsFolder() {
    final saveDir = Directory('$_userHomeDir/Videos/Scrcpy_Recordings');
    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }
    _openFolderInFileManager(saveDir.path);
  }

  Future<void> _gracefullyStopScrcpy(Process proc, {int? hwnd}) async {
    try {
      if (Platform.isWindows && hwnd != null && hwnd != 0 && IsWindow(hwnd) != 0) {
        PostMessage(hwnd, 0x0010, 0, 0); // WM_CLOSE
      }

      if (Platform.environment['FLUTTER_TEST'] != 'true') {
        if (Platform.isWindows) {
          try {
            await Process.run('taskkill', ['/pid', proc.pid.toString()]);
          } catch (_) {}
        } else {
          try {
            await Process.run('kill', ['-15', proc.pid.toString()]); // SIGTERM
          } catch (_) {}
        }
      }

      await proc.exitCode.timeout(const Duration(milliseconds: 1500), onTimeout: () {
        proc.kill();
        return -1;
      });
    } catch (_) {
      try {
        proc.kill();
      } catch (_) {}
    }
  }

  Future<void> _updateDeviceResolution() async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') return;
    try {
      final res = await Process.run(adbExePath, _withSerial(['shell', 'wm', 'size']));
      final out = res.stdout.toString();
      final overrideMatch = RegExp(r'Override size:\s*(\d+)x(\d+)').firstMatch(out);
      final physicalMatch = RegExp(r'Physical size:\s*(\d+)x(\d+)').firstMatch(out);
      final match = overrideMatch ?? physicalMatch;
      if (match != null) {
        final w = int.tryParse(match.group(1) ?? '');
        final h = int.tryParse(match.group(2) ?? '');
        if (w != null && h != null && w > 0 && h > 0) {
          if (mounted) {
            setState(() {
              _deviceScreenWidth = w;
              _deviceScreenHeight = h;
            });
          }
        }
      }
    } catch (_) {}
  }

  Map<String, dynamic>? _mapScreenToPhone(int screenX, int screenY, int scrcpyHwnd, {bool clampToBounds = false}) {
    if (scrcpyHwnd == 0 || IsWindow(scrcpyHwnd) == 0) return null;

    final clientRect = calloc<RECT>();
    final clientPt = calloc<POINT>();

    try {
      if (GetClientRect(scrcpyHwnd, clientRect) == 0) return null;

      clientPt.ref.x = 0;
      clientPt.ref.y = 0;
      if (ClientToScreen(scrcpyHwnd, clientPt) == 0) return null;

      final clientScreenLeft = clientPt.ref.x;
      final clientScreenTop = clientPt.ref.y;
      final clientW = clientRect.ref.right - clientRect.ref.left;
      final clientH = clientRect.ref.bottom - clientRect.ref.top;

      if (clientW <= 40 || clientH <= 40) return null;

      // Deteksi orientasi otomatis berdasarkan rasio aspek Scrcpy
      int activeDevW = _deviceScreenWidth;
      int activeDevH = _deviceScreenHeight;
      if (clientW > clientH && _deviceScreenWidth < _deviceScreenHeight) {
        // Scrcpy mendatar (landscape), resolusi fisik dasar tegak
        activeDevW = _deviceScreenHeight;
        activeDevH = _deviceScreenWidth;
      } else if (clientW <= clientH && _deviceScreenWidth > _deviceScreenHeight) {
        // Scrcpy tegak (portrait), resolusi fisik dasar mendatar
        activeDevW = _deviceScreenHeight;
        activeDevH = _deviceScreenWidth;
      }

      final devAspect = activeDevW / activeDevH;
      final clientAspect = clientW / clientH;

      double videoW = clientW.toDouble();
      double videoH = clientH.toDouble();
      double videoOffsetX = 0.0;
      double videoOffsetY = 0.0;

      if (clientAspect > devAspect) {
        // Pillarbox: bar hitam di sisi kiri dan kanan
        videoH = clientH.toDouble();
        videoW = videoH * devAspect;
        videoOffsetX = (clientW - videoW) / 2.0;
        videoOffsetY = 0.0;
      } else if (clientAspect < devAspect) {
        // Letterbox: bar hitam di sisi atas dan bawah
        videoW = clientW.toDouble();
        videoH = videoW / devAspect;
        videoOffsetX = 0.0;
        videoOffsetY = (clientH - videoH) / 2.0;
      }

      final videoLeft = clientScreenLeft + videoOffsetX;
      final videoTop = clientScreenTop + videoOffsetY;
      final videoRight = videoLeft + videoW;
      final videoBottom = videoTop + videoH;

      if (!clampToBounds) {
        if (screenX < videoLeft || screenX > videoRight || screenY < videoTop || screenY > videoBottom) {
          return null;
        }
      }

      final normX = ((screenX - videoLeft) / videoW).clamp(0.0, 1.0);
      final normY = ((screenY - videoTop) / videoH).clamp(0.0, 1.0);

      final phoneX = (normX * activeDevW).round().clamp(0, activeDevW);
      final phoneY = (normY * activeDevH).round().clamp(0, activeDevH);

      return {
        'x': phoneX,
        'y': phoneY,
        'activeDevW': activeDevW,
        'activeDevH': activeDevH,
      };
    } finally {
      free(clientRect);
      free(clientPt);
    }
  }

  Future<void> _executeStepForSerial({
    required String serial,
    required MacroStep step,
    required int screenWidth,
    required int screenHeight,
  }) async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') return;
    final prefix = serial.isNotEmpty ? ['-s', serial] : <String>[];

    try {
      if (step.action == 'tap') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'tap', step.x.toString(), step.y.toString()]);
      } else if (step.action == 'double_tap') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'tap', step.x.toString(), step.y.toString()]);
        await Future.delayed(const Duration(milliseconds: 90));
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'tap', step.x.toString(), step.y.toString()]);
      } else if (step.action == 'long_press') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', step.x.toString(), step.y.toString(), step.x.toString(), step.y.toString(), step.durationMs.toString()]);
      } else if (step.action == 'rapid_tap') {
        final count = step.repeatCount.clamp(2, 50);
        for (int r = 0; r < count; r++) {
          await Process.run(adbExePath, [...prefix, 'shell', 'input', 'tap', step.x.toString(), step.y.toString()]);
          await Future.delayed(const Duration(milliseconds: 80));
        }
      } else if (step.action == 'swipe') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', step.x.toString(), step.y.toString(), step.endX.toString(), step.endY.toString(), step.durationMs.toString()]);
      } else if (step.action == 'swipe_up') {
        final midX = (screenWidth / 2).round();
        final startY = (screenHeight * 0.65).round();
        final endY = (screenHeight * 0.25).round();
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', midX.toString(), startY.toString(), midX.toString(), endY.toString(), '260']);
      } else if (step.action == 'swipe_down') {
        final midX = (screenWidth / 2).round();
        final startY = (screenHeight * 0.25).round();
        final endY = (screenHeight * 0.65).round();
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', midX.toString(), startY.toString(), midX.toString(), endY.toString(), '260']);
      } else if (step.action == 'swipe_left') {
        final startX = (screenWidth * 0.85).round();
        final endX = (screenWidth * 0.15).round();
        final midY = (screenHeight / 2).round();
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', startX.toString(), midY.toString(), endX.toString(), midY.toString(), '240']);
      } else if (step.action == 'swipe_right') {
        final startX = (screenWidth * 0.15).round();
        final endX = (screenWidth * 0.85).round();
        final midY = (screenHeight / 2).round();
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', startX.toString(), midY.toString(), endX.toString(), midY.toString(), '240']);
      } else if (step.action == 'edge_back') {
        final midY = (screenHeight / 2).round();
        final endX = (screenWidth * 0.4).round();
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'swipe', '15', midY.toString(), endX.toString(), midY.toString(), '180']);
      } else if (step.action == 'key_back') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'keyevent', '4']);
      } else if (step.action == 'key_home') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'keyevent', '3']);
      } else if (step.action == 'key_recent') {
        await Process.run(adbExePath, [...prefix, 'shell', 'input', 'keyevent', '187']);
      } else if (step.action == 'key_notif') {
        await Process.run(adbExePath, [...prefix, 'shell', 'cmd', 'statusbar', 'expand-notifications']);
      }
    } catch (_) {}
  }

  Future<void> _playMacro() async {
    if (_macroSteps.isEmpty) {
      _showToast(tr("Add or record macro actions first.", "Tambahkan atau rekam aksi makro terlebih dahulu."));
      return;
    }
    if (_isMacroRunning) return;
    if (_isMacroRecording) _stopMacroRecording();

    setState(() {
      _isMacroRunning = true;
      _macroCurrentLoop = 1;
      _macroCurrentStep = 0;
    });

    _showToast(tr("MacroDock started (Loop: ${_macroLoopCount == -1 ? 'Loop Forever' : '$_macroLoopCount times'})...", "MacroDock dimulai (Loop: ${_macroLoopCount == -1 ? 'Loop Terus' : '$_macroLoopCount kali'})..."));

    int loop = 0;
    while (_isMacroRunning && (_macroLoopCount == -1 || loop < _macroLoopCount)) {
      loop++;
      if (mounted) setState(() => _macroCurrentLoop = loop);

      for (int i = 0; i < _macroSteps.length; i++) {
        if (!_isMacroRunning) break;
        if (mounted) setState(() => _macroCurrentStep = i);

        final step = _macroSteps[i];
        await _executeStepForSerial(
          serial: _selectedDeviceSerial,
          step: step,
          screenWidth: _deviceScreenWidth,
          screenHeight: _deviceScreenHeight,
        );

        final waitDuration = (step.delayMs / _macroSpeed).round();
        if (Platform.environment['FLUTTER_TEST'] != 'true') {
          await Future.delayed(Duration(milliseconds: waitDuration.clamp(40, 10000)));
        }
      }
    }

    if (mounted) {
      setState(() {
        _isMacroRunning = false;
        _macroCurrentStep = -1;
      });
      _showToast(tr("Macro execution finished.", "Makro selesai dijalankan."));
    }
  }

  void _stopMacro() {
    setState(() {
      _isMacroRunning = false;
      _macroCurrentStep = -1;
    });
    _showToast(tr("Macro stopped.", "Makro dihentikan."));
  }

  Future<void> _startMultiRunner(String serial) async {
    final runner = _multiDeviceRunners.putIfAbsent(serial, () => DeviceRunnerStatus(serial: serial));
    if (runner.assignedMacro == null || runner.isRunning) return;

    setState(() {
      runner.isRunning = true;
      runner.shouldStop = false;
      runner.currentLoop = 1;
      runner.currentStep = 0;
    });

    _showToast(tr("Playing macro '${runner.assignedMacroName}' on $serial...", "Memutar makro '${runner.assignedMacroName}' di $serial..."));

    final macro = runner.assignedMacro!;
    final steps = macro.steps;
    final loopCount = runner.loopCount;
    final speed = runner.speed;
    final screenW = macro.screenWidth;
    final screenH = macro.screenHeight;

    int loop = 0;
    while (runner.isRunning && !runner.shouldStop && (loopCount == -1 || loop < loopCount)) {
      loop++;
      if (mounted) setState(() => runner.currentLoop = loop);

      for (int i = 0; i < steps.length; i++) {
        if (!runner.isRunning || runner.shouldStop) break;
        if (mounted) setState(() => runner.currentStep = i);

        final step = steps[i];
        await _executeStepForSerial(
          serial: serial,
          step: step,
          screenWidth: screenW,
          screenHeight: screenH,
        );

        final waitDuration = (step.delayMs / speed).round();
        if (Platform.environment['FLUTTER_TEST'] != 'true') {
          await Future.delayed(Duration(milliseconds: waitDuration.clamp(40, 10000)));
        }
      }
    }

    if (mounted) {
      setState(() {
        runner.isRunning = false;
        runner.shouldStop = false;
      });
      _showToast(tr("Macro on $serial completed.", "Makro di $serial selesai."));
    }
  }

  void _stopMultiRunner(String serial) {
    final runner = _multiDeviceRunners[serial];
    if (runner != null) {
      setState(() {
        runner.shouldStop = true;
        runner.isRunning = false;
      });
      _showToast(tr("Macro on $serial stopped.", "Makro di $serial dihentikan."));
    }
  }

  void _startAllMultiRunners() {
    int started = 0;
    for (final dev in _connectedDevices) {
      final runner = _multiDeviceRunners[dev];
      if (runner != null && runner.assignedMacro != null && !runner.isRunning) {
        _startMultiRunner(dev);
        started++;
      }
    }
    if (started == 0) {
      _showToast(tr("Assign a macro to devices first.", "Pilih makro untuk perangkat terlebih dahulu."));
    } else {
      _showToast(tr("Starting $started macros simultaneously...", "Memulai $started makro secara bersamaan..."));
    }
  }

  void _stopAllMultiRunners() {
    for (final runner in _multiDeviceRunners.values) {
      runner.shouldStop = true;
      runner.isRunning = false;
    }
    setState(() {});
    _showToast(tr("All multi-device macros stopped.", "Semua makro multi-device dihentikan."));
  }

  void _startMacroRecording() async {
    if (_isMacroRecording) return;
    if (_isMacroRunning) _stopMacro();

    await _updateDeviceResolution();

    setState(() {
      _isMacroRecording = true;
      _wasMouseDown = false;
      _isDownInsideScrcpy = false;
      _mouseDownTime = null;
      _lastActionUpTime = null;
    });

    _showToast(tr("Recording active! Resolution: ${_deviceScreenWidth}x$_deviceScreenHeight", "Perekaman aktif! Resolusi: ${_deviceScreenWidth}x$_deviceScreenHeight"));

    if (Platform.environment['FLUTTER_TEST'] == 'true') return;

    final pt = calloc<POINT>();
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (!_isMacroRecording) {
        timer.cancel();
        free(pt);
        return;
      }

      try {
        final isDown = (GetAsyncKeyState(0x01) & 0x8000) != 0; // VK_LBUTTON
        GetCursorPos(pt);
        final curX = pt.ref.x;
        final curY = pt.ref.y;
        final scrcpyHwnd = _getScrcpyHwnd();

        if (isDown && !_wasMouseDown) {
          _wasMouseDown = true;
          _mouseDownTime = DateTime.now();
          _mouseDownX = curX;
          _mouseDownY = curY;

          // Cek apakah klik awal ini berada di dalam jendela cermin Scrcpy
          final mappedDown = _mapScreenToPhone(curX, curY, scrcpyHwnd);
          if (mappedDown != null) {
            _isDownInsideScrcpy = true;

            // Perbarui jeda waktu (delayMs) langkah sebelumnya secara presisi
            if (_macroSteps.isNotEmpty && _lastActionUpTime != null) {
              final idlePause = _mouseDownTime!.difference(_lastActionUpTime!).inMilliseconds.clamp(60, 8000);
              final prev = _macroSteps.last;
              _macroSteps[_macroSteps.length - 1] = prev.copyWith(delayMs: idlePause);
              if (mounted) setState(() {});
            }
          } else {
            _isDownInsideScrcpy = false;
          }
        } else if (!isDown && _wasMouseDown) {
          _wasMouseDown = false;
          final upTime = DateTime.now();
          final downTime = _mouseDownTime ?? upTime;
          final pressDuration = upTime.difference(downTime).inMilliseconds;

          if (_isDownInsideScrcpy) {
            _isDownInsideScrcpy = false;
            _lastActionUpTime = upTime;

            final mappedDown = _mapScreenToPhone(_mouseDownX, _mouseDownY, scrcpyHwnd, clampToBounds: true);
            final mappedUp = _mapScreenToPhone(curX, curY, scrcpyHwnd, clampToBounds: true);

            if (mappedDown != null && mappedUp != null) {
              final phoneX = mappedDown['x'] as int;
              final phoneY = mappedDown['y'] as int;
              final phoneEndX = mappedUp['x'] as int;
              final phoneEndY = mappedUp['y'] as int;

              final dx = curX - _mouseDownX;
              final dy = curY - _mouseDownY;
              final distSq = (dx * dx + dy * dy);

              if (distSq < 225) {
                // Sentuhan di tempat (Tap, Double Tap, atau Long Press) - toleransi pergeseran 15 pixel
                if (pressDuration >= 450) {
                  // Tekan & Tahan (Long Press)
                  final dur = pressDuration.clamp(500, 3000);
                  if (mounted) {
                    setState(() {
                      _macroSteps.add(MacroStep(
                        action: 'long_press',
                        x: phoneX,
                        y: phoneY,
                        endX: phoneX,
                        endY: phoneY,
                        durationMs: dur,
                        delayMs: 600,
                        description: 'Tahan ($phoneX, $phoneY) ${dur}ms',
                      ));
                    });
                  }
                } else {
                  // Cek apakah klik sebelumnya adalah tap di titik yang sama dalam waktu < 320ms -> Double Tap
                  final lastDelay = _macroSteps.isNotEmpty ? _macroSteps.last.delayMs : 9999;
                  if (_macroSteps.isNotEmpty &&
                      _macroSteps.last.action == 'tap' &&
                      lastDelay < 320 &&
                      (_macroSteps.last.x - phoneX).abs() < 40 &&
                      (_macroSteps.last.y - phoneY).abs() < 40) {
                    final lastTap = _macroSteps.removeLast();
                    if (mounted) {
                      setState(() {
                        _macroSteps.add(MacroStep(
                          action: 'double_tap',
                          x: phoneX,
                          y: phoneY,
                          delayMs: lastTap.delayMs,
                          description: 'Double Tap / Like ($phoneX, $phoneY)',
                        ));
                      });
                    }
                  } else {
                    if (mounted) {
                      setState(() {
                        _macroSteps.add(MacroStep(
                          action: 'tap',
                          x: phoneX,
                          y: phoneY,
                          delayMs: 600,
                          description: 'Tap ($phoneX, $phoneY)',
                        ));
                      });
                    }
                  }
                }
              } else {
                // Geser / Usap Layar (Swipe / Scroll) dengan koordinat dan durasi nyata
                final dur = pressDuration.clamp(140, 600);
                String swipeLabel = 'Geser';
                if (dy.abs() > dx.abs()) {
                  swipeLabel = dy < 0 ? 'Scroll Naik' : 'Scroll Turun';
                } else {
                  swipeLabel = dx < 0 ? 'Geser Kiri' : 'Geser Kanan';
                }

                if (mounted) {
                  setState(() {
                    _macroSteps.add(MacroStep(
                      action: 'swipe',
                      x: phoneX,
                      y: phoneY,
                      endX: phoneEndX,
                      endY: phoneEndY,
                      durationMs: dur,
                      delayMs: 600,
                      description: '$swipeLabel ($phoneX,$phoneY -> $phoneEndX,$phoneEndY)',
                    ));
                  });
                }
              }
            }
          }
        }
      } catch (_) {}
    });
  }

  void _stopMacroRecording() {
    _recordTimer?.cancel();
    _recordTimer = null;
    if (_macroSteps.isNotEmpty && _lastActionUpTime != null) {
      final finalIdle = DateTime.now().difference(_lastActionUpTime!).inMilliseconds.clamp(200, 3000);
      _macroSteps[_macroSteps.length - 1] = _macroSteps.last.copyWith(delayMs: finalIdle);
    }
    setState(() {
      _isMacroRecording = false;
    });
    _showToast(tr("Recording finished! Total ${_macroSteps.length} precise actions recorded.", "Perekaman selesai! Total ${_macroSteps.length} aksi terekam presisi."));
  }

  void _showDonateDialog() {
    int activeTab = 0; // 0 = Saweria, 1 = Ko-fi, 2 = PayPal
    showDialog(
      context: context,
      builder: (ctx) {
        final t = PanelTheme(appThemeModeNotifier.value);

        return StatefulBuilder(
          builder: (context, setDlgState) {
            final String currentUrl;
            final String actionLabel;
            if (activeTab == 0) {
              currentUrl = _donationSaweriaUrl;
              actionLabel = tr('Open Saweria', 'Buka Saweria');
            } else if (activeTab == 1) {
              currentUrl = _donationKofiUrl;
              actionLabel = tr('Open Ko-fi', 'Buka Ko-fi');
            } else {
              currentUrl = _donationPaypalUrl;
              actionLabel = tr('Open PayPal', 'Buka PayPal');
            }

            return AlertDialog(
              backgroundColor: t.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: t.borderPrimary),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFE5534B)),
                  const SizedBox(width: 6),
                  Text(
                    tr('Support Developer', 'Dukungan Donasi'),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary),
                  ),
                ],
              ),
              content: SizedBox(
                width: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clean 3-way Segmented Tab: Saweria | Ko-fi | PayPal
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: t.bgSubCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: t.borderSecondary),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setDlgState(() => activeTab = 0),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: activeTab == 0 ? (t.isDark ? const Color(0xFF2D333B) : Colors.white) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Saweria',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: activeTab == 0 ? FontWeight.w600 : FontWeight.w400,
                                    color: activeTab == 0 ? t.textPrimary : t.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setDlgState(() => activeTab = 1),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: activeTab == 1 ? (t.isDark ? const Color(0xFF2D333B) : Colors.white) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Ko-fi',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: activeTab == 1 ? FontWeight.w600 : FontWeight.w400,
                                    color: activeTab == 1 ? t.textPrimary : t.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setDlgState(() => activeTab = 2),
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: activeTab == 2 ? (t.isDark ? const Color(0xFF2D333B) : Colors.white) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'PayPal',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: activeTab == 2 ? FontWeight.w600 : FontWeight.w400,
                                    color: activeTab == 2 ? t.textPrimary : t.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Clean QR Code generated directly from link
                    Container(
                      width: 155,
                      height: 155,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD0D7DE)),
                      ),
                      child: QrImageView(
                        data: currentUrl,
                        version: QrVersions.auto,
                        size: 139.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      tr('Scan QR or click button below', 'Scan QR atau klik tombol di bawah'),
                      style: TextStyle(fontSize: 8.5, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.textSecondary,
                    side: BorderSide(color: t.borderSecondary),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(tr('Close', 'Tutup'), style: const TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _openUrlInBrowser(currentUrl);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 12),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _isEngineAvailable(String pathOrCmd) async {
    try {
      if (pathOrCmd.contains('/') || pathOrCmd.contains('\\')) {
        return File(pathOrCmd).existsSync();
      }
      final res = await Process.run(pathOrCmd, ['--version']).timeout(const Duration(seconds: 2));
      return res.exitCode == 0 || res.stdout.toString().isNotEmpty || res.stderr.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showEngineMissingDialog() {
    if (!mounted) return;
    int selectedPlatform = Platform.isMacOS ? 0 : (Platform.isLinux ? 1 : 2);

    showDialog(
      context: context,
      builder: (ctx) {
        final t = PanelTheme(appThemeModeNotifier.value);
        return StatefulBuilder(
          builder: (context, setDlgState) {
            String commandText = '';
            String platformTitle = '';
            String packageManagerNote = '';

            if (selectedPlatform == 0) {
              platformTitle = 'macOS (Homebrew)';
              commandText = 'brew install scrcpy android-platform-tools';
              packageManagerNote = tr(
                'Make sure Homebrew is installed, then paste this into Terminal.',
                'Pastikan Homebrew terpasang, lalu tempel ke Terminal.',
              );
            } else if (selectedPlatform == 1) {
              platformTitle = 'Linux (Ubuntu / Debian / Arch / Fedora)';
              commandText = 'sudo apt update && sudo apt install -y scrcpy adb';
              packageManagerNote = tr(
                'For Ubuntu/Debian/Mint. (Arch: sudo pacman -S scrcpy android-tools | Fedora: sudo dnf install scrcpy android-tools)',
                'Untuk Ubuntu/Debian/Mint. (Arch: sudo pacman -S scrcpy android-tools | Fedora: sudo dnf install scrcpy android-tools)',
              );
            } else {
              platformTitle = 'Windows (Winget / Standalone)';
              commandText = 'winget install Genymobile.scrcpy';
              packageManagerNote = tr(
                'Run in PowerShell or Windows Terminal to install Scrcpy globally.',
                'Jalankan di PowerShell atau Windows Terminal untuk install Scrcpy global.',
              );
            }

            return AlertDialog(
              backgroundColor: t.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: t.borderPrimary),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5534B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF85149)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr('Scrcpy & ADB Engine Required', 'Engine Scrcpy & ADB Diperlukan'),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: t.textPrimary),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tr(
                        'ScrcpyDock is a visual dock controller that powers the official Scrcpy and ADB engines. On macOS and Linux, please install Scrcpy & ADB via your terminal to start mirroring.',
                        'ScrcpyDock adalah dock controller visual untuk engine resmi Scrcpy & ADB. Di macOS dan Linux, silakan pasang Scrcpy & ADB via terminal agar HP dapat di-mirror.',
                      ),
                      style: TextStyle(fontSize: 10, color: t.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPlatformTab(0, 'macOS', selectedPlatform == 0, () => setDlgState(() => selectedPlatform = 0), t),
                        const SizedBox(width: 6),
                        _buildPlatformTab(1, 'Linux', selectedPlatform == 1, () => setDlgState(() => selectedPlatform = 1), t),
                        const SizedBox(width: 6),
                        _buildPlatformTab(2, 'Windows', selectedPlatform == 2, () => setDlgState(() => selectedPlatform = 2), t),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: t.borderPrimary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                platformTitle,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: t.textSecondary),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: commandText));
                                  _showToast(tr('Command copied to clipboard!', 'Perintah disalin ke clipboard!'));
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded, size: 11, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                                      const SizedBox(width: 4),
                                      Text(
                                        tr('Copy', 'Salin'),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            commandText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3FB950),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            packageManagerNote,
                            style: TextStyle(fontSize: 8.5, color: t.textSecondary.withValues(alpha: 0.8), height: 1.25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: t.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(tr('Close', 'Tutup'), style: const TextStyle(fontSize: 10)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final scrcpyOk = await _isEngineAvailable(scrcpyExePath);
                    final adbOk = await _isEngineAvailable(adbExePath);
                    if (scrcpyOk && adbOk) {
                      if (ctx.mounted) Navigator.pop(ctx);
                      _showToast(tr('Engine detected successfully!', 'Engine Scrcpy & ADB berhasil terdeteksi!'));
                      _checkAdbConnection();
                    } else {
                      _showToast(tr('Engine still not detected. Please run the command first.', 'Engine belum terdeteksi. Silakan jalankan perintah di atas terlebih dahulu.'));
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 12),
                  label: Text(
                    tr('Check Again', 'Cek Ulang'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlatformTab(int index, String label, bool isSelected, VoidCallback onTap, PanelTheme t) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? (t.isDark ? const Color(0xFF21262D) : const Color(0xFFE1E4E8)) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)) : t.borderPrimary,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)) : t.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }


  bool _isSameSubnet(String ip1, String ip2) {
    if (ip1.isEmpty || ip2.isEmpty) return false;
    final p1 = ip1.split('.');
    final p2 = ip2.split('.');
    if (p1.length == 4 && p2.length == 4) {
      return p1[0] == p2[0] && p1[1] == p2[1] && p1[2] == p2[2];
    }
    return false;
  }

  Future<void> _detectNetworkInfo() async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') return;
    try {
      // 1. Detect PC Local IPv4
      if (_pcLocalIp.isEmpty) {
        final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        for (var iface in interfaces) {
          for (var addr in iface.addresses) {
            if (!addr.isLoopback && !addr.address.startsWith('169.254.')) {
              _pcLocalIp = addr.address;
              break;
            }
          }
          if (_pcLocalIp.isNotEmpty) break;
        }
      }

      // 2. Detect Phone IP and SSID if device is connected
      if (_selectedDeviceSerial.isNotEmpty) {
        final wifiRes = await Process.run(adbExePath, _withSerial(['shell', 'dumpsys', 'wifi']));
        final wifiOut = wifiRes.stdout.toString();

        final ssidMatch = RegExp(r'mWifiInfo SSID:\s*"([^"]+)"').firstMatch(wifiOut);
        final ipMatch = RegExp(r'IP:\s*/([\d\.]+)').firstMatch(wifiOut);

        String foundSsid = ssidMatch?.group(1) ?? '';
        String foundIp = ipMatch?.group(1) ?? '';

        if (foundIp.isEmpty) {
          final ipRes = await Process.run(adbExePath, _withSerial(['shell', 'ip', 'route']));
          final match = RegExp(r'src\s+([\d\.]+)').firstMatch(ipRes.stdout.toString());
          foundIp = match?.group(1) ?? '';
        }

        if (foundIp.isEmpty) {
          final ipRes2 = await Process.run(adbExePath, _withSerial(['shell', 'ip', '-f', 'inet', 'addr', 'show', 'wlan0']));
          final match2 = RegExp(r'inet\s+([\d\.]+)/').firstMatch(ipRes2.stdout.toString());
          foundIp = match2?.group(1) ?? '';
        }

        if (mounted) {
          setState(() {
            if (foundIp.isNotEmpty) {
              _deviceIp = foundIp;
              if (_manualIpController.text.isEmpty) {
                _manualIpController.text = foundIp;
              }
              if (_pairingHostController.text.isEmpty) {
                _pairingHostController.text = foundIp;
              }
            }
            if (foundSsid.isNotEmpty) _deviceSsid = foundSsid;
          });
        }
      }
    } catch (_) {}
  }

  // Jalur 1: Otomatis via USB Helper -> Wi-Fi
  void _connectWifiWireless() async {
    setState(() {
      _isConnectingWifi = true;
      _setWifiStatus('Detecting IP & enabling port 5555...', 'Mendeteksi IP & mengaktifkan port 5555...');
    });
    try {
      await _detectNetworkInfo();

      if (_deviceIp.isEmpty) {
        setState(() {
          _setWifiStatus('Failed to detect phone Wi-Fi IP. Ensure Wi-Fi on phone is turned on.', 'Gagal mendeteksi IP Wi-Fi HP. Pastikan Wi-Fi di HP sudah menyala.');
        });
        _showToast(tr('Failed: Phone IP not detected.', 'Gagal: IP HP tidak terdeteksi.'));
        return;
      }

      final isDiff = _pcLocalIp.isNotEmpty && !_isSameSubnet(_pcLocalIp, _deviceIp);
      if (isDiff) {
        _setWifiStatus('Warning: Different subnet (PC: $_pcLocalIp vs Phone: $_deviceIp). Attempting to connect...', 'Peringatan: Beda subnet (PC: $_pcLocalIp vs HP: $_deviceIp). Mencoba hubungkan...');
      }

      await Process.run(adbExePath, _withSerial(['tcpip', '5555']));
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _setWifiStatus('Connecting to $_deviceIp:5555...', 'Menyambungkan ke $_deviceIp:5555...'));
      }

      final connRes = await Process.run(adbExePath, ['connect', '$_deviceIp:5555'])
          .timeout(const Duration(seconds: 4), onTimeout: () {
        return ProcessResult(0, 1, '', 'Timeout koneksi (Beda subnet / port diblokir router)');
      });

      final fullOut = '${connRes.stdout} ${connRes.stderr}'.trim();
      if (fullOut.contains('connected to') || fullOut.contains('already connected')) {
        _isWifiConnected = true;
        _setWifiStatus('Successfully connected to $_deviceIp:5555! USB cable can now be disconnected.', 'Berhasil tersambung ke $_deviceIp:5555! Kabel USB sekarang bisa dicabut.');
        _showToast(tr('Wi-Fi mode active. USB cable can be disconnected.', 'Mode Wi-Fi aktif. Kabel USB bisa dicabut.'));
      } else {
        if (isDiff) {
          _setWifiStatus(
            'Failed to connect: Different Network Subnet!\nPC: $_pcLocalIp (Ethernet) vs Phone: $_deviceIp ($_deviceSsid).\nSolution: Connect Phone to the same Wi-Fi as PC (192.168.100.x).',
            'Gagal terhubung: Beda Subnet Jaringan!\nPC: $_pcLocalIp (Ethernet) vs HP: $_deviceIp ($_deviceSsid).\nSolusi: Sambungkan HP ke Wi-Fi yang sama dengan PC (192.168.100.x).',
          );
        } else {
          _setWifiStatus('Connection failed: $fullOut', 'Gagal connect: $fullOut');
        }
        _showToast(tr('Failed to connect Wi-Fi.', 'Gagal menyambung Wi-Fi.'));
      }
    } catch (e) {
      _setWifiStatus('Error: $e', 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isConnectingWifi = false);
        _checkAdbConnection();
      }
    }
  }

  // Jalur 2: Input Manual IP & Port
  void _connectManualWifi() async {
    final ip = _manualIpController.text.trim();
    final port = _manualPortController.text.trim().isEmpty ? '5555' : _manualPortController.text.trim();

    if (ip.isEmpty) {
      _showToast(tr('Enter phone IP address.', 'Masukkan alamat IP HP.'));
      return;
    }

    setState(() {
      _isConnectingWifi = true;
      _setWifiStatus('Connecting to $ip:$port...', 'Menghubungkan ke $ip:$port...');
    });

    try {
      final connRes = await Process.run(adbExePath, ['connect', '$ip:$port'])
          .timeout(const Duration(seconds: 4), onTimeout: () {
        return ProcessResult(0, 1, '', 'Timeout menghubungi $ip:$port');
      });

      final out = '${connRes.stdout} ${connRes.stderr}'.trim();
      if (out.contains('connected to') || out.contains('already connected')) {
        _deviceIp = ip;
        _isWifiConnected = true;
        _setWifiStatus('Successfully connected to $ip:$port!', 'Berhasil terhubung ke $ip:$port!');
        _showToast(tr('Connected to $ip:$port', 'Tersambung ke $ip:$port'));
      } else {
        _setWifiStatus('Failed: $out', 'Gagal: $out');
        _showToast(tr('Failed to reach $ip:$port', 'Gagal menghubungi $ip:$port'));
      }
    } catch (e) {
      _setWifiStatus('Error: $e', 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isConnectingWifi = false);
        _checkAdbConnection();
      }
    }
  }

  // Jalur 3: Android 11+ Wireless Debugging Pairing
  void _pairAndConnectWireless() async {
    final hostPort = _pairingHostController.text.trim();
    final code = _pairingCodeController.text.trim();
    final connectPort = _pairingConnectPortController.text.trim();

    if (hostPort.isEmpty || code.isEmpty) {
      _showToast(tr('Fill in Pairing Host:Port and 6-Digit Code', 'Isi Host:Port Pairing dan Kode 6-Digit'));
      return;
    }

    setState(() {
      _isConnectingWifi = true;
      _setWifiStatus('Pairing device ($hostPort)...', 'Memasangkan perangkat ($hostPort)...');
    });

    try {
      final pairRes = await Process.run(adbExePath, ['pair', hostPort, code])
          .timeout(const Duration(seconds: 6), onTimeout: () {
        return ProcessResult(0, 1, '', 'Pairing timeout. Pastikan layar dialog di HP tetap menyala.');
      });

      final pairOut = '${pairRes.stdout} ${pairRes.stderr}'.trim();
      if (pairOut.toLowerCase().contains('successfully paired') || pairOut.contains('paired to')) {
        _setWifiStatus('Pairing successful! Connecting...', 'Pairing sukses! Menyambungkan...');
        if (mounted) setState(() {});

        final hostIp = hostPort.contains(':') ? hostPort.split(':').first : hostPort;
        final targetConnect = connectPort.isNotEmpty ? '$hostIp:$connectPort' : hostPort;

        final connRes = await Process.run(adbExePath, ['connect', targetConnect])
            .timeout(const Duration(seconds: 4), onTimeout: () {
          return ProcessResult(0, 1, '', 'Timeout connect ke $targetConnect');
        });

        final connOut = '${connRes.stdout} ${connRes.stderr}'.trim();
        if (connOut.contains('connected to') || connOut.contains('already connected')) {
          _deviceIp = hostIp;
          _isWifiConnected = true;
          _setWifiStatus('Successfully paired & connected to $targetConnect!', 'Berhasil terpasang & terhubung ke $targetConnect!');
          _showToast(tr('Wireless Debugging active!', 'Wireless Debugging aktif!'));
        } else {
          _setWifiStatus(
            'Pairing successful! But connection to $targetConnect failed ($connOut). Enter port shown on main Wireless Debugging screen.',
            'Pairing sukses! Tapi connect ke $targetConnect gagal ($connOut). Masukkan port yang ada di layar utama Wireless Debugging.',
          );
        }
      } else {
        _setWifiStatus('Pairing failed: $pairOut. Make sure code matches and devices are on same Wi-Fi.', 'Gagal pairing: $pairOut. Pastikan kode cocok dan berada dalam 1 Wi-Fi.');
        _showToast(tr('Pairing failed', 'Pairing gagal'));
      }
    } catch (e) {
      _setWifiStatus('Pairing error: $e', 'Error pairing: $e');
    } finally {
      if (mounted) {
        setState(() => _isConnectingWifi = false);
        _checkAdbConnection();
      }
    }
  }

  // Jalur 0: Pairing Nirkabel Otomatis via Kode QR
  void _generateQrPairingData() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final randChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final nameSuffix = List.generate(6, (i) => randChars[(random + i * 7) % randChars.length]).join();
    final pwd = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();

    _qrPairingName = 'ADB_WIFI_$nameSuffix';
    _qrPairingPassword = pwd;
    _qrPairingPayload = 'WIFI:T:ADB;S:$_qrPairingName;P:$_qrPairingPassword;;';
    _setQrPairingStatus('Waiting for phone camera scan...', 'Menunggu pemindaian kamera HP...');
  }

  void _stopQrPairingListener() {
    _qrMdnsPollTimer?.cancel();
    _isQrPairingActive = false;
  }

  void _startQrPairingListener() {
    _stopQrPairingListener();
    if (_qrPairingPayload.isEmpty) {
      _generateQrPairingData();
    }
    _isQrPairingActive = true;
    _setQrPairingStatus('Point phone camera at the QR code above...', 'Arahkan kamera HP ke Kode QR di atas...');
    if (mounted) setState(() {});

    _qrMdnsPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if (!mounted || !_isQrPairingActive || Platform.environment['FLUTTER_TEST'] == 'true') {
        timer.cancel();
        return;
      }

      try {
        final mdnsRes = await Process.run(adbExePath, ['mdns', 'services']).timeout(const Duration(seconds: 3));
        final out = mdnsRes.stdout.toString();

        final lines = out.split('\n');
        String? pairingHostPort;
        String? connectHostPort;

        for (var line in lines) {
          final trimmed = line.trim();
          if (trimmed.contains('_adb-tls-pairing._tcp')) {
            for (var p in trimmed.split(RegExp(r'\s+'))) {
              if (p.contains(':') && !p.contains('_adb')) {
                pairingHostPort = p;
                break;
              }
            }
          }
          if (trimmed.contains('_adb-tls-connect._tcp')) {
            for (var p in trimmed.split(RegExp(r'\s+'))) {
              if (p.contains(':') && !p.contains('_adb')) {
                connectHostPort = p;
                break;
              }
            }
          }
        }

        if (pairingHostPort != null && pairingHostPort.isNotEmpty) {
          if (mounted) {
            setState(() {
              _setQrPairingStatus('Phone detected ($pairingHostPort)! Pairing...', 'HP terdeteksi ($pairingHostPort)! Memasangkan...');
            });
          }

          final pairRes = await Process.run(adbExePath, ['pair', pairingHostPort, _qrPairingPassword])
              .timeout(const Duration(seconds: 5));
          final pairOut = pairRes.stdout.toString();

          if (pairOut.contains('Successfully paired') || pairRes.exitCode == 0) {
            if (mounted) {
              setState(() {
                _setQrPairingStatus('Successfully paired! Connecting to phone...', 'Berhasil dipasangkan! Menghubungkan ke HP...');
              });
            }

            await Future.delayed(const Duration(milliseconds: 700));

            final ip = pairingHostPort.split(':').first;
            String targetToConnect = connectHostPort ?? '$ip:5555';

            try {
              final mdnsRes2 = await Process.run(adbExePath, ['mdns', 'services']);
              for (var line in mdnsRes2.stdout.toString().split('\n')) {
                if (line.contains('_adb-tls-connect._tcp') && line.contains(ip)) {
                  for (var p in line.trim().split(RegExp(r'\s+'))) {
                    if (p.contains(':') && !p.contains('_adb')) {
                      targetToConnect = p;
                      break;
                    }
                  }
                }
              }
            } catch (_) {}

            final connRes = await Process.run(adbExePath, ['connect', targetToConnect]);
            final connOut = connRes.stdout.toString();

            timer.cancel();
            _isQrPairingActive = false;

            if (connOut.contains('connected') || connRes.exitCode == 0) {
              _showToast(tr('Phone Successfully Connected via QR Code!', 'HP Berhasil Terhubung via Kode QR!'));
              if (mounted) {
                setState(() {
                  _setQrPairingStatus('Successfully connected to $targetToConnect 🎉', 'Sukses terhubung ke $targetToConnect 🎉');
                  _setWifiStatus('Connected via QR to $targetToConnect', 'Terhubung via QR ke $targetToConnect');
                  _isWifiConnected = true;
                });
                _checkAdbConnection();
              }
            } else {
              if (mounted) {
                setState(() {
                  _setQrPairingStatus('Paired! Connect to $targetToConnect', 'Dipasangkan! Sambungkan ke $targetToConnect');
                });
                _checkAdbConnection();
              }
            }
          }
        } else if (connectHostPort != null && connectHostPort.isNotEmpty && !_isWifiConnected) {
          final connRes = await Process.run(adbExePath, ['connect', connectHostPort]);
          if (connRes.stdout.toString().contains('connected')) {
            timer.cancel();
            _isQrPairingActive = false;
            _showToast(tr('Phone Connected Wirelessly!', 'HP Terhubung via Nirkabel!'));
            if (mounted) {
              setState(() {
                _setQrPairingStatus('Successfully connected to $connectHostPort 🎉', 'Sukses terhubung ke $connectHostPort 🎉');
                _isWifiConnected = true;
              });
              _checkAdbConnection();
            }
          }
        }
      } catch (_) {}
    });
  }

  // Jalur 4: Pindai Jaringan (mDNS & Subnet Scanner)
  void _scanWifiNetwork() async {
    setState(() {
      _isScanningWifi = true;
      _discoveredDevices.clear();
      _setWifiStatus('Scanning devices on network (mDNS & Port 5555)...', 'Memindai perangkat di jaringan (mDNS & Port 5555)...');
    });

    try {
      await _detectNetworkInfo();

      // A. mDNS discovery
      final mdnsRes = await Process.run(adbExePath, ['mdns', 'services'])
          .timeout(const Duration(seconds: 3), onTimeout: () => ProcessResult(0, 0, '', ''));
      final mdnsLines = mdnsRes.stdout.toString().split('\n');
      for (var line in mdnsLines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('List of')) continue;
        final ipMatch = RegExp(r'([\d\.]+:\d+)').firstMatch(trimmed);
        if (ipMatch != null) {
          final addr = ipMatch.group(1)!;
          if (!_discoveredDevices.any((d) => d['address'] == addr)) {
            _discoveredDevices.add({
              'address': addr,
              'name': trimmed.split(RegExp(r'\s+')).first,
              'type': 'mDNS (Wireless Debug)',
            });
          }
        }
      }

      // B. Subnet port scan on port 5555
      final subnetsToScan = <String>{};
      if (_pcLocalIp.isNotEmpty && _pcLocalIp.contains('.')) {
        final p = _pcLocalIp.split('.');
        subnetsToScan.add('${p[0]}.${p[1]}.${p[2]}.');
      }
      if (_deviceIp.isNotEmpty && _deviceIp.contains('.')) {
        final p = _deviceIp.split('.');
        subnetsToScan.add('${p[0]}.${p[1]}.${p[2]}.');
      }

      for (var baseSubnet in subnetsToScan) {
        final allIps = List.generate(254, (i) => '$baseSubnet${i + 1}');
        for (int i = 0; i < allIps.length; i += 40) {
          final chunk = allIps.sublist(i, (i + 40 > allIps.length) ? allIps.length : i + 40);
          await Future.wait(chunk.map((ip) async {
            try {
              final s = await Socket.connect(ip, 5555, timeout: const Duration(milliseconds: 120));
              s.destroy();
              final addr = '$ip:5555';
              if (!_discoveredDevices.any((d) => d['address'] == addr)) {
                _discoveredDevices.add({
                  'address': addr,
                  'name': tr('Device Port 5555', 'Perangkat Port 5555'),
                  'type': 'ADB TCP/IP',
                });
              }
            } catch (_) {}
          }));
        }
      }

      if (_discoveredDevices.isNotEmpty) {
        _setWifiStatus('Found ${_discoveredDevices.length} targets on network!', 'Ditemukan ${_discoveredDevices.length} target di jaringan!');
        _showToast(tr('Found ${_discoveredDevices.length} Wi-Fi devices', 'Ditemukan ${_discoveredDevices.length} perangkat Wi-Fi'));
      } else {
        _setWifiStatus('No devices found. Ensure Port 5555 or Wireless Debugging is active on phone.', 'Tidak ada perangkat ditemukan. Pastikan Port 5555 atau Wireless Debugging aktif di HP.');
        _showToast(tr('Scan finished: 0 devices', 'Pemindaian selesai: 0 perangkat'));
      }
    } catch (e) {
      _setWifiStatus('Scan error: $e', 'Error pemindaian: $e');
    } finally {
      if (mounted) setState(() => _isScanningWifi = false);
    }
  }

  void _disconnectWifi([String? specificTarget]) async {
    final target = specificTarget ?? (_deviceIp.isNotEmpty ? '$_deviceIp:5555' : '');
    if (target.isNotEmpty) {
      await Process.run(adbExePath, ['disconnect', target]);
    } else {
      await Process.run(adbExePath, ['disconnect']);
    }
    if (mounted) {
      setState(() {
        _isWifiConnected = false;
        _setWifiStatus('Wi-Fi connection disconnected.', 'Koneksi Wi-Fi diputuskan.');
      });
      _showToast(tr('Wi-Fi disconnected.', 'Wi-Fi diputuskan.'));
      _checkAdbConnection();
    }
  }

  void _closeApp() async {
    await _stopAllMirroring();
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd != 0 && IsWindow(scrcpyHwnd) != 0) {
      PostMessage(scrcpyHwnd, 0x0010, 0, 0); // WM_CLOSE
      _scrcpyHwnd = 0;
    }
    await windowManager.close();
  }

  void _toggleScreenDisplay() {
    _sendScrcpyScreenPower(turnOff: !_isDisplayOff);
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _generateQrPairingData();
    if (Platform.environment['FLUTTER_TEST'] != 'true') {
      windowManager.setAsFrameless();
      _applyDarkDwmTheme();
      _checkAdbConnection();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _checkAdbConnection();
      });
      if (_wirelessMethodTab == 0) {
        _startQrPairingListener();
      }
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _timer?.cancel();
    _syncTimer?.cancel();
    _toastTimer?.cancel();
    _recordTimer?.cancel();
    _qrMdnsPollTimer?.cancel();
    _liveScreenRecordTimer?.cancel();
    _liveScreenRecordProcess?.kill();
    _isMacroRunning = false;
    _isMacroRecording = false;
    for (var runner in _multiDeviceRunners.values) {
      runner.shouldStop = true;
      runner.isRunning = false;
    }
    for (var proc in _activeScrcpyProcesses.values) {
      proc.kill();
    }
    _activeScrcpyProcesses.clear();
    _scrcpyProcess?.kill();
    _mainScrollController.dispose();
    _manualIpController.dispose();
    _manualPortController.dispose();
    _pairingHostController.dispose();
    _pairingCodeController.dispose();
    _pairingConnectPortController.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await _stopAllMirroring();
    if (Platform.isWindows) {
      final scrcpyHwnd = _getScrcpyHwnd();
      if (scrcpyHwnd != 0 && IsWindow(scrcpyHwnd) != 0) {
        PostMessage(scrcpyHwnd, 0x0010, 0, 0); // WM_CLOSE
      }
    }
  }

  @override
  void onWindowRestore() async {
    _isRestoring = true;
    _lastPanelMinimized = false;
    _lastScrcpyMinimized = false;
    if (Platform.isWindows) {
      for (var hwnd in _deviceHwnds.values) {
        if (hwnd != 0 && IsWindow(hwnd) != 0) {
          ShowWindow(hwnd, SW_RESTORE);
        }
      }
      final scrcpyHwnd = _getScrcpyHwnd();
      if (scrcpyHwnd != 0 && IsWindow(scrcpyHwnd) != 0 && !_deviceHwnds.containsValue(scrcpyHwnd)) {
        ShowWindow(scrcpyHwnd, SW_RESTORE);
      }
      _syncScrcpyToPanel();
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      _isRestoring = false;
    });
  }

  @override
  void onWindowMinimize() async {
    _lastPanelMinimized = true;
    _lastScrcpyMinimized = true;
    if (Platform.isWindows) {
      for (var hwnd in _deviceHwnds.values) {
        if (hwnd != 0 && IsWindow(hwnd) != 0) {
          ShowWindow(hwnd, SW_MINIMIZE);
        }
      }
      final scrcpyHwnd = _getScrcpyHwnd();
      if (scrcpyHwnd != 0 && IsWindow(scrcpyHwnd) != 0 && !_deviceHwnds.containsValue(scrcpyHwnd)) {
        ShowWindow(scrcpyHwnd, SW_MINIMIZE);
      }
    }
  }

  @override
  void onWindowMove() async {
    _syncScrcpyToPanel();
  }

  bool _snapWindowToAspectRatio(int hwnd, {bool force = false, bool? resizedWidthMostly}) {
    if (!Platform.isWindows) return false;
    if (hwnd == 0 || IsWindow(hwnd) == 0 || IsIconic(hwnd) != 0) return false;
    if (Platform.environment['FLUTTER_TEST'] == 'true') return false;

    final winRect = calloc<RECT>();
    final clientRect = calloc<RECT>();
    try {
      if (GetWindowRect(hwnd, winRect) == 0) return false;
      if (GetClientRect(hwnd, clientRect) == 0) return false;

      final winW = winRect.ref.right - winRect.ref.left;
      final winH = winRect.ref.bottom - winRect.ref.top;
      final clientW = clientRect.ref.right - clientRect.ref.left;
      final clientH = clientRect.ref.bottom - clientRect.ref.top;

      if (clientW <= 40 || clientH <= 40) return false;

      final borderW = winW - clientW;
      final borderH = winH - clientH;

      // Hitung target aspect ratio video yang sebenarnya
      final double targetRatio;
      if (_scrcpyMode == 'camera') {
        targetRatio = _cameraOrientation == 'portrait' ? (9.0 / 16.0) : (16.0 / 9.0);
      } else {
        final maxDim = math.max(_deviceScreenWidth, _deviceScreenHeight).toDouble();
        final minDim = math.min(_deviceScreenWidth, _deviceScreenHeight).toDouble();
        if (clientW > clientH) {
          targetRatio = maxDim / (minDim > 0 ? minDim : 1.0);
        } else {
          targetRatio = minDim / (maxDim > 0 ? maxDim : 1.0);
        }
      }

      if (targetRatio <= 0.05) return false;

      final currentRatio = clientW / clientH;
      final ratioDiff = (currentRatio - targetRatio).abs();

      // Jika rasio berbeda > 0.015 (ada bar hitam di layar) atau dipaksa tombol Rapikan
      if (force || ratioDiff > 0.015) {
        int newClientW;
        int newClientH;

        if (resizedWidthMostly == true) {
          // User mengubah lebar jendela -> sesuaikan tinggi otomatis
          newClientW = clientW;
          newClientH = (newClientW / targetRatio).round();
        } else if (resizedWidthMostly == false) {
          // User mengubah tinggi jendela -> sesuaikan lebar otomatis
          newClientH = clientH;
          newClientW = (newClientH * targetRatio).round();
        } else {
          // Penyelarasan otomatis: pangkas sisi yang berlebih agar pas
          if (currentRatio > targetRatio) {
            // Ada bar hitam di kiri & kanan (pillarbox) -> pangkas lebar
            newClientW = (clientH * targetRatio).round();
            newClientH = clientH;
          } else {
            // Ada bar hitam di atas & bawah (letterbox) -> pangkas tinggi
            newClientH = (clientW / targetRatio).round();
            newClientW = clientW;
          }
        }

        newClientW = newClientW.clamp(180, 2560);
        newClientH = newClientH.clamp(200, 1600);

        final newWinW = newClientW + borderW;
        final newWinH = newClientH + borderH;

        if ((newWinW - winW).abs() > 1 || (newWinH - winH).abs() > 1) {
          SetWindowPos(
            hwnd,
            0,
            winRect.ref.left,
            winRect.ref.top,
            newWinW,
            newWinH,
            SWP_NOZORDER | SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS,
          );
          return true;
        }
      }
    } finally {
      calloc.free(winRect);
      calloc.free(clientRect);
    }
    return false;
  }

  void _snapAllActiveWindowsToAspectRatio({bool force = false}) {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true') return;
    final hwnds = <int>{};
    if (_scrcpyHwnd != 0) hwnds.add(_scrcpyHwnd);
    hwnds.addAll(_deviceHwnds.values.where((h) => h != 0));

    bool anyChanged = false;
    for (var h in hwnds) {
      if (_snapWindowToAspectRatio(h, force: force)) {
        anyChanged = true;
      }
    }
    if (anyChanged) {
      _syncScrcpyToPanel();
    }
  }

  void _syncScrcpyToPanel() async {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true') return;
    if (_isSyncing) return;
    if (_scrcpyHwnd == 0 && _deviceHwnds.isEmpty) return;

    _isSyncing = true;
    try {
      final panelPos = await windowManager.getPosition();
      final panelSize = await windowManager.getSize();
      final zOrder = _chkAlwaysTop ? HWND_TOPMOST : HWND_TOP;

      int currentX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows).toInt();
      final currentY = panelPos.dy.toInt();

      final rect = calloc<RECT>();

      // Build ordered list of active devices
      final serialsToAlign = <String>[];
      for (var s in _mirroredSerialOrder) {
        if (_activeScrcpyProcesses.containsKey(s) || _deviceHwnds.containsKey(s)) {
          serialsToAlign.add(s);
        }
      }
      for (var s in _activeScrcpyProcesses.keys) {
        if (!serialsToAlign.contains(s)) {
          serialsToAlign.add(s);
        }
      }

      final validEntries = <MapEntry<String, int>>[];
      for (var s in serialsToAlign) {
        final hwnd = _deviceHwnds[s] ?? (_scrcpyHwnd != 0 && s == _selectedDeviceSerial ? _scrcpyHwnd : 0);
        if (hwnd != 0 && IsWindow(hwnd) != 0 && IsIconic(hwnd) == 0) {
          validEntries.add(MapEntry(s, hwnd));
        }
      }

      // Deteksi otomatis setiap jendela Scrcpy yang aktif di desktop tapi belum terdaftar di validEntries
      int searchHwnd = 0;
      final titleBuf = calloc<Uint16>(512);
      while (true) {
        searchHwnd = FindWindowEx(0, searchHwnd, nullptr, nullptr);
        if (searchHwnd == 0) break;
        if (IsWindow(searchHwnd) == 0 || IsIconic(searchHwnd) != 0) continue;

        final len = GetWindowText(searchHwnd, titleBuf.cast(), 512);
        if (len > 0) {
          final t = titleBuf.cast<Utf16>().toDartString();
          if (t.startsWith('Scrcpy [') && !validEntries.any((e) => e.value == searchHwnd)) {
            String matchedSerial = '';
            for (var s in _activeScrcpyProcesses.keys) {
              if (!_deviceHwnds.containsKey(s) || _deviceHwnds[s] == 0) {
                matchedSerial = s;
                break;
              }
            }
            if (matchedSerial.isNotEmpty) {
              _deviceHwnds[matchedSerial] = searchHwnd;
              validEntries.add(MapEntry(matchedSerial, searchHwnd));
            } else {
              validEntries.add(MapEntry('win_${validEntries.length}', searchHwnd));
            }
          }
        }
      }
      calloc.free(titleBuf);

      if (validEntries.isEmpty) {
        final h = _getScrcpyHwnd();
        if (h != 0 && IsWindow(h) != 0 && IsIconic(h) == 0) {
          if (GetWindowRect(h, rect) != 0) {
            final curX = rect.ref.left;
            final curY = rect.ref.top;
            if ((curX - currentX).abs() > 2 || (curY - currentY).abs() > 2) {
              SetWindowPos(
                h,
                zOrder,
                currentX,
                currentY,
                0,
                0,
                SWP_NOSIZE | SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS,
              );
            }
          }
        }
      } else if (validEntries.length < 4 || _multiWindowLayout == 'horizontal') {
        // Mode 1 s/d 3 Jendela atau Mode Berdampingan:
        // Ukuran jendela BEBAS diperbesar oleh user (SWP_NOSIZE) untuk pengujian aplikasi & video YouTube.
        // Dock hanya menyelaraskan posisi X & Y tanpa mengecilkan/memaksa lebar & tinggi jendela.
        for (var entry in validEntries) {
          final hwnd = entry.value;
          if (GetWindowRect(hwnd, rect) != 0) {
            final curX = rect.ref.left;
            final curY = rect.ref.top;
            final curW = rect.ref.right - rect.ref.left;

            if ((curX - currentX).abs() > 2 || (curY - currentY).abs() > 2) {
              SetWindowPos(
                hwnd,
                zOrder,
                currentX,
                currentY,
                0,
                0,
                SWP_NOSIZE | SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS,
              );
            }
            currentX += (curW + _gapBetweenWindows).toInt();
          }
        }
      } else {
        // Mode Grid Adaptif (2 hingga 10+ Perangkat Otomatis Pas di Layar)
        final workArea = calloc<RECT>();
        SystemParametersInfo(SPI_GETWORKAREA, 0, workArea, 0);
        final screenLeft = workArea.ref.left;
        final screenTop = workArea.ref.top;
        final screenRight = workArea.ref.right;
        final screenBottom = workArea.ref.bottom;
        final totalWorkWidth = screenRight - screenLeft;
        final totalWorkHeight = screenBottom - screenTop;
        calloc.free(workArea);

        final bool isPanelOnLeft = panelPos.dx < (totalWorkWidth / 2);
        final int gridStartX = isPanelOnLeft
            ? (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows).toInt()
            : (screenLeft + 8);
        final int availableW = isPanelOnLeft
            ? (screenRight - gridStartX - 8).clamp(320, 7680)
            : (panelPos.dx - 8 - _gapBetweenWindows).clamp(320, 7680).toInt();
        final int N = validEntries.length;
        int cols;
        int rows;
        if (N == 2) {
          cols = 2;
          rows = 1;
        } else if (N == 3) {
          cols = availableW >= 850 ? 3 : 2;
          rows = (N / cols).ceil();
        } else if (N == 4) {
          cols = 2;
          rows = 2;
        } else if (N <= 6) {
          cols = 3;
          rows = 2;
        } else if (N <= 8) {
          cols = 4;
          rows = 2;
        } else if (N == 9) {
          cols = 3;
          rows = 3;
        } else if (N <= 12) {
          cols = 4;
          rows = 3;
        } else if (N <= 16) {
          cols = 4;
          rows = 4;
        } else {
          cols = 5;
          rows = (N / cols).ceil();
        }

        final int gap = _gapBetweenWindows.toInt().clamp(2, 6);
        final int gridStartY = (rows == 1) ? panelPos.dy.toInt() : (screenTop + 8);
        final int availableH = (totalWorkHeight - 16).clamp(320, 4320);
        final int effectiveH = (rows == 1)
            ? panelSize.height.toInt().clamp(500, 680)
            : availableH;

        final int cellW = ((availableW - (cols - 1) * gap) / cols).floor();
        final int cellH = ((effectiveH - (rows - 1) * gap) / rows).floor();

        const double targetRatio = 0.52;
        int winW;
        int winH;

        if (cellW / cellH > targetRatio) {
          winH = cellH;
          winW = (cellH * targetRatio).floor().clamp(120, cellW);
        } else {
          winW = cellW;
          winH = (cellW / targetRatio).floor().clamp(180, cellH);
        }

        for (int i = 0; i < N; i++) {
          final hwnd = validEntries[i].value;
          final c = i % cols;
          final r = i ~/ cols;

          final targetX = gridStartX + c * (winW + gap);
          final targetY = gridStartY + r * (winH + gap);

          if (GetWindowRect(hwnd, rect) != 0) {
            final curX = rect.ref.left;
            final curY = rect.ref.top;
            final curW = rect.ref.right - rect.ref.left;
            final curH = rect.ref.bottom - rect.ref.top;

            if ((curX - targetX).abs() > 3 || (curY - targetY).abs() > 3 || (curW - winW).abs() > 3 || (curH - winH).abs() > 3) {
              SetWindowPos(
                hwnd,
                zOrder,
                targetX,
                targetY,
                winW,
                winH,
                SWP_NOACTIVATE | SWP_ASYNCWINDOWPOS,
              );
            }
          }
        }
      }

      calloc.free(rect);
    } finally {
      _isSyncing = false;
    }
  }

  void _startBidirectionalSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) async {
      if ((_scrcpyHwnd == 0 && _deviceHwnds.isEmpty) || !mounted || Platform.environment['FLUTTER_TEST'] == 'true') return;

      // Clean up dead HWNDs
      _deviceHwnds.removeWhere((k, v) => v == 0 || IsWindow(v) == 0);
      _lastObservedWindowSizes.removeWhere((k, v) => k == 0 || IsWindow(k) == 0);
      _lastResizeTimes.removeWhere((k, v) => k == 0 || IsWindow(k) == 0);
      _lastResizeAxis.removeWhere((k, v) => k == 0 || IsWindow(k) == 0);
      _mirroredSerialOrder.removeWhere((s) => !_activeScrcpyProcesses.containsKey(s) && !_deviceHwnds.containsKey(s));
      if (_scrcpyHwnd != 0 && IsWindow(_scrcpyHwnd) == 0) {
        _scrcpyHwnd = _deviceHwnds.values.firstOrNull ?? 0;
        if (_scrcpyHwnd == 0 && _activeScrcpyProcesses.isEmpty) {
          _scrcpyProcess = null;
          _syncTimer?.cancel();
          if (mounted) setState(() {});
          return;
        }
      }

      if (_isRestoring) return;

      final primaryHwnd = _getScrcpyHwnd();
      final isScrcpyMinimized = primaryHwnd != 0 && IsIconic(primaryHwnd) != 0;
      final isPanelMinimized = await windowManager.isMinimized();

      if (isScrcpyMinimized != _lastScrcpyMinimized) {
        _lastScrcpyMinimized = isScrcpyMinimized;
        _lastPanelMinimized = isScrcpyMinimized;
        if (isScrcpyMinimized) {
          if (!isPanelMinimized) await windowManager.minimize();
        } else {
          if (isPanelMinimized) {
            await windowManager.restore();
            _syncScrcpyToPanel();
          }
        }
        return;
      }

      if (isPanelMinimized != _lastPanelMinimized) {
        _lastPanelMinimized = isPanelMinimized;
        _lastScrcpyMinimized = isPanelMinimized;
        if (isPanelMinimized) {
          for (var h in _deviceHwnds.values) {
            if (h != 0 && IsWindow(h) != 0) ShowWindow(h, SW_MINIMIZE);
          }
        } else {
          for (var h in _deviceHwnds.values) {
            if (h != 0 && IsWindow(h) != 0) ShowWindow(h, SW_RESTORE);
          }
          _syncScrcpyToPanel();
        }
        return;
      }

      if (isPanelMinimized || isScrcpyMinimized) return;

      // Auto-Snap Aspect Ratio (Kunci Proporsional Tanpa Area Hitam saat Resize)
      if (_chkAutoFitAspectRatio) {
        final now = DateTime.now();
        final hwnds = <int>{};
        if (_scrcpyHwnd != 0 && IsWindow(_scrcpyHwnd) != 0 && IsIconic(_scrcpyHwnd) == 0) hwnds.add(_scrcpyHwnd);
        for (var h in _deviceHwnds.values) {
          if (h != 0 && IsWindow(h) != 0 && IsIconic(h) == 0) hwnds.add(h);
        }

        final rect = calloc<RECT>();
        for (var h in hwnds) {
          if (GetWindowRect(h, rect) != 0) {
            final curW = rect.ref.right - rect.ref.left;
            final curH = rect.ref.bottom - rect.ref.top;
            final lastSize = _lastObservedWindowSizes[h];

            if (lastSize != null) {
              final diffW = (curW - lastSize.width).abs();
              final diffH = (curH - lastSize.height).abs();
              if (diffW > 4 || diffH > 4) {
                // Sedang di-resize oleh user dengan mouse
                _lastResizeTimes[h] = now;
                _lastResizeAxis[h] = diffW > diffH;
                _lastObservedWindowSizes[h] = Size(curW.toDouble(), curH.toDouble());
              } else {
                // Ukuran stabil setelah dilepas
                final lastResizeTime = _lastResizeTimes[h];
                if (lastResizeTime != null && now.difference(lastResizeTime).inMilliseconds >= 250) {
                  _lastResizeTimes.remove(h);
                  final resizedWidth = _lastResizeAxis[h];
                  if (_snapWindowToAspectRatio(h, resizedWidthMostly: resizedWidth)) {
                    _lastObservedWindowSizes[h] = Size(curW.toDouble(), curH.toDouble());
                    _syncScrcpyToPanel();
                  }
                }
              }
            } else {
              _lastObservedWindowSizes[h] = Size(curW.toDouble(), curH.toDouble());
            }
          }
        }
        calloc.free(rect);
      }

      _syncScrcpyToPanel();
    });
  }

  void _minimizeBothWindows() async {
    _lastPanelMinimized = true;
    _lastScrcpyMinimized = true;
    for (var hwnd in _deviceHwnds.values) {
      if (hwnd != 0 && IsWindow(hwnd) != 0) {
        ShowWindow(hwnd, SW_MINIMIZE);
      }
    }
    final scrcpyHwnd = _getScrcpyHwnd();
    if (scrcpyHwnd != 0 && IsWindow(scrcpyHwnd) != 0 && !_deviceHwnds.containsValue(scrcpyHwnd)) {
      ShowWindow(scrcpyHwnd, SW_MINIMIZE);
    }
    await windowManager.minimize();
  }

  void _toggleFoldPanel() async {
    final willFold = !_isFolded;
    if (willFold) {
      setState(() {
        _isFolded = true;
      });
      if (Platform.environment['FLUTTER_TEST'] != 'true') {
        await windowManager.setMinimumSize(const Size(48.0, 520.0));
        await windowManager.setMaximumSize(const Size(48.0, 520.0));
        await windowManager.setSize(const Size(48.0, 520.0));
      }
    } else {
      if (Platform.environment['FLUTTER_TEST'] != 'true') {
        await windowManager.setMaximumSize(const Size(320.0, 520.0));
        await windowManager.setSize(const Size(320.0, 520.0));
        await windowManager.setMinimumSize(const Size(320.0, 520.0));
      }
      if (mounted) {
        setState(() {
          _isFolded = false;
        });
      }
    }
    _applyDarkDwmTheme();

    if (Platform.environment['FLUTTER_TEST'] != 'true') {
      await Future.delayed(const Duration(milliseconds: 60));
      _syncScrcpyToPanel();
    }
  }

  void _checkAdbConnection() async {
    try {
      final result = await Process.run(adbExePath, ['devices', '-l']);
      final output = result.stdout.toString();

      final List<DeviceInfo> devList = [];
      final lines = output.split('\n');
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('List of devices')) continue;

        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final serial = parts[0];
          final state = parts[1];
          if (state == 'device' || state == 'offline' || state == 'unauthorized') {
            String model = '';
            for (var p in parts) {
              if (p.startsWith('model:')) {
                model = p.replaceFirst('model:', '');
              }
            }
            devList.add(DeviceInfo(
              serial: serial,
              model: model,
              state: state,
              isWifi: serial.contains(':'),
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _connectedDevicesList = devList;
          _connectedDevices = devList.map((d) => d.serial).toList();
          final isConnected = devList.any((d) => d.state == 'device');
          _connectionStatus = isConnected ? 'Connected' : 'Disconnected';
          _isWifiConnected = devList.any((d) => d.isWifi && d.state == 'device');
          if (!_connectedDevices.contains(_selectedDeviceSerial)) {
            _selectedDeviceSerial = _connectedDevices.isNotEmpty ? _connectedDevices.first : '';
          }
          final currentDev = devList.where((d) => d.serial == _selectedDeviceSerial).firstOrNull;
          _connectedDeviceName = currentDev != null
              ? (currentDev.model.isNotEmpty ? currentDev.model : currentDev.serial)
              : _selectedDeviceSerial;
        });
        if (devList.any((d) => d.state == 'device')) {
          _updateDeviceResolution();
          _detectNetworkInfo();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectedDevicesList = [];
          _connectedDevices = [];
          _selectedDeviceSerial = '';
          _connectionStatus = 'Offline';
          _connectedDeviceName = '';
        });
      }
    }
  }

  String _getDeviceWindowTitle(DeviceInfo? dev, String serial) {
    final model = dev != null && dev.model.isNotEmpty ? dev.model : (serial.isNotEmpty ? serial : 'Device');
    final isWifi = (dev != null && dev.isWifi) || serial.contains(':');
    if (isWifi) {
      return 'Scrcpy [$model ($serial)]';
    }
    final usbCount = _connectedDevicesList.where((d) => !d.isWifi).length;
    if (usbCount > 1 && serial.isNotEmpty) {
      final shortSerial = serial.length > 5 ? serial.substring(serial.length - 5) : serial;
      return 'Scrcpy [$model (USB-$shortSerial)]';
    }
    return 'Scrcpy [$model (USB)]';
  }

  void _dockMirrorWindowNextToPanel([String? serial, String? windowTitle]) async {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true') return;

    final targetProc = (serial != null && serial.isNotEmpty)
        ? _activeScrcpyProcesses[serial]
        : _scrcpyProcess;
    final targetPid = targetProc?.pid ?? 0;

    int foundHwnd = 0;
    Pointer<Utf16>? titlePtr;
    final clsPtr = TEXT('SDL_app');
    final scrcpyClsPtr = TEXT('scrcpy');

    if (windowTitle != null && windowTitle.isNotEmpty) {
      titlePtr = TEXT(windowTitle);
    }

    final pidPtr = calloc<DWORD>();

    // Poll for up to 35 iterations (total ~7 seconds, 200ms interval)
    for (int i = 0; i < 35; i++) {
      await Future.delayed(const Duration(milliseconds: 200));

      // 1. Try finding by exact window title
      if (titlePtr != null) {
        var h = FindWindow(clsPtr, titlePtr);
        if (h == 0) h = FindWindow(scrcpyClsPtr, titlePtr);
        if (h == 0) h = FindWindow(nullptr, titlePtr);

        if (h != 0 && IsWindow(h) != 0) {
          final alreadyUsed = _deviceHwnds.entries.any((e) => e.key != serial && e.value == h);
          if (!alreadyUsed) {
            foundHwnd = h;
            break;
          }
        }
      }

      // 2. If title match hasn't succeeded, find by Process ID (PID)
      if (foundHwnd == 0 && targetPid != 0) {
        int nextHwnd = 0;
        while (true) {
          nextHwnd = FindWindowEx(0, nextHwnd, clsPtr, nullptr);
          if (nextHwnd == 0) break;

          final alreadyUsed = _deviceHwnds.entries.any((e) => e.key != serial && e.value == nextHwnd);
          if (alreadyUsed) continue;

          GetWindowThreadProcessId(nextHwnd, pidPtr);
          if (pidPtr.value == targetPid) {
            foundHwnd = nextHwnd;
            break;
          }
        }

        if (foundHwnd == 0) {
          nextHwnd = 0;
          while (true) {
            nextHwnd = FindWindowEx(0, nextHwnd, scrcpyClsPtr, nullptr);
            if (nextHwnd == 0) break;

            final alreadyUsed = _deviceHwnds.entries.any((e) => e.key != serial && e.value == nextHwnd);
            if (alreadyUsed) continue;

            GetWindowThreadProcessId(nextHwnd, pidPtr);
            if (pidPtr.value == targetPid) {
              foundHwnd = nextHwnd;
              break;
            }
          }
        }

        if (foundHwnd != 0) break;
      }

      // 3. Fallback search by title text if exact match or PID didn't catch it
      if (foundHwnd == 0) {
        int nextHwnd = 0;
        final buf = calloc<Uint16>(512);
        while (true) {
          nextHwnd = FindWindowEx(0, nextHwnd, nullptr, nullptr);
          if (nextHwnd == 0) break;

          final alreadyUsed = _deviceHwnds.entries.any((e) => e.key != serial && e.value == nextHwnd);
          if (alreadyUsed) continue;

          final len = GetWindowText(nextHwnd, buf.cast(), 512);
          if (len > 0) {
            final wTitle = buf.cast<Utf16>().toDartString();
            if (wTitle.startsWith('Scrcpy') && (
                (windowTitle != null && wTitle == windowTitle) ||
                (serial != null && serial.isNotEmpty && wTitle.contains(serial))
            )) {
              foundHwnd = nextHwnd;
              break;
            }
          }
        }
        calloc.free(buf);
        if (foundHwnd != 0) break;
      }

      // 4. Fallback: only if no other device is active and window not already taken
      if (foundHwnd == 0 && _deviceHwnds.isEmpty) {
        var h = FindWindow(clsPtr, nullptr);
        if (h == 0) h = FindWindow(scrcpyClsPtr, nullptr);
        if (h != 0 && IsWindow(h) != 0) {
          foundHwnd = h;
          break;
        }
      }
    }

    free(pidPtr);
    if (titlePtr != null) free(titlePtr);
    free(clsPtr);
    free(scrcpyClsPtr);

    if (foundHwnd != 0) {
      if (serial != null && serial.isNotEmpty) {
        _deviceHwnds[serial] = foundHwnd;
        if (!_mirroredSerialOrder.contains(serial)) {
          _mirroredSerialOrder.add(serial);
        }
      }
      if (_scrcpyHwnd == 0 || serial == _selectedDeviceSerial) {
        _scrcpyHwnd = foundHwnd;
      }

      if (_chkAlwaysTop) {
        await windowManager.setAlwaysOnTop(true);
      }

      _setScrcpyWindowIcon(foundHwnd);
      _syncScrcpyToPanel();
      _startBidirectionalSync();
    }
  }

  void _setScrcpyWindowIcon(int hwnd) {
    if (!Platform.isWindows || Platform.environment['FLUTTER_TEST'] == 'true' || hwnd == 0) return;
    try {
      final candidates = [
        '${Directory.current.path}/assets/app_icon.ico',
        '${File(Platform.resolvedExecutable).parent.path}/data/flutter_assets/assets/app_icon.ico',
        'assets/app_icon.ico',
        '${Directory.current.path}/windows/runner/resources/app_icon.ico',
      ];
      String? icoPath;
      for (final p in candidates) {
        if (File(p).existsSync()) {
          icoPath = File(p).absolute.path.replaceAll('/', '\\');
          break;
        }
      }
      if (icoPath != null) {
        final p = TEXT(icoPath);
        final hSmall = LoadImage(0, p, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
        final hBig = LoadImage(0, p, IMAGE_ICON, 32, 32, LR_LOADFROMFILE);
        free(p);
        if (hSmall != 0) {
          SendMessage(hwnd, WM_SETICON, ICON_SMALL, hSmall);
        }
        if (hBig != 0) {
          SendMessage(hwnd, WM_SETICON, ICON_BIG, hBig);
        }
      }
    } catch (_) {}
  }

  void _startMirroring() async {
    final isScrcpyAvailable = await _isEngineAvailable(scrcpyExePath);
    if (!isScrcpyAvailable) {
      if (mounted) _showEngineMissingDialog();
      return;
    }

    if (_connectionStatus != 'Connected' || (_connectedDevicesList.isEmpty && _connectedDevices.isEmpty)) {
      _showToast(tr('No Android device connected. Please connect via USB or Wi-Fi first.', 'Tidak ada HP Android terhubung. Sambungkan via USB atau Wi-Fi terlebih dahulu.'));
      return;
    }

    if (_selectedDeviceSerial.isEmpty && _connectedDevices.isNotEmpty) {
      _selectedDeviceSerial = _connectedDevices.first;
    }

    final panelPos = await windowManager.getPosition();
    final panelSize = await windowManager.getSize();
    final startX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows).toInt();
    final startY = panelPos.dy.toInt();

    List<String> args = [];

    if (_scrcpyMode == 'camera') {
      // 1. MODE WEBCAM PC (Format Tegak Bentuk HP)
      final int captureOrientation = _cameraOrientation == 'portrait'
          ? (_cameraFacing == 'front' ? 270 : 90)
          : 0;

      args = [
        "--video-source=camera",
        "--camera-facing=$_cameraFacing",
        "--camera-size=1920x1080",
        "--capture-orientation=$captureOrientation",
        "--max-fps", "$_selectedFps",
        "--shortcut-mod", "lalt,lctrl",
        "--window-x", startX.toString(),
        "--window-y", startY.toString(),
      ];

      if (_cameraOrientation == 'portrait') {
        args.addAll(["--window-height", "520"]);
      } else {
        args.addAll(["--window-width", "640"]);
      }

      if (_chkAlwaysTop) args.add("--always-on-top");
      if (!_chkAudioToPC) args.add("--no-audio");
      _webcamStreamingTimer?.cancel();
      _webcamStreamingSeconds = 0;
      _webcamStreamingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _scrcpyProcess == null || _scrcpyMode != 'camera') {
          timer.cancel();
          return;
        }
        setState(() {
          _webcamStreamingSeconds++;
        });
      });
      _showToast(tr("Starting PC Webcam (${_cameraFacing == 'front' ? 'Front Camera' : 'Back Camera'}, ${_cameraOrientation == 'portrait' ? 'portrait' : 'landscape'})...", "Memulai Webcam PC (${_cameraFacing == 'front' ? 'Kamera Depan' : 'Kamera Belakang'}, bentuk ${_cameraOrientation == 'portrait' ? 'HP tegak' : 'mendatar'})..."));
    } else if (_scrcpyMode == 'audio') {
      // 2. MODE AUDIO / MIC SAJA (Headless Studio Mic - Tanpa Jendela SDL TV Hijau Kuno)
      args.addAll([
        "--no-video",
        "--no-window",
        "--audio-source=mic",
      ]);
      _micStreamingTimer?.cancel();
      _micStreamingSeconds = 0;
      _micStreamingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _scrcpyProcess == null || _scrcpyMode != 'audio') {
          timer.cancel();
          return;
        }
        setState(() {
          _micStreamingSeconds++;
        });
      });
      _showToast(tr("Studio Mic Phone to PC active...", "Studio Mic HP ke PC aktif..."));
    } else if (_scrcpyMode == 'otg') {
      // 3. MODE OTG HARDWARE HID (Keyboard Fisik + Mouse Bebas/Game)
      args = [
        "--keyboard=uhid",
        if (_otgMouseMode == 'uhid') "--mouse=uhid" else "--mouse=sdk",
        "--video-bit-rate", "${_selectedBitrate}M",
        "--max-fps", "$_selectedFps",
        "--shortcut-mod", "lalt,lctrl",
        "--window-x", startX.toString(),
        "--window-y", startY.toString(),
      ];
      if (_selectedResolution == '1080p') {
        args.addAll(["--max-size", "1080"]);
      } else if (_selectedResolution == '720p') {
        args.addAll(["--max-size", "720"]);
      }
      if (_chkAlwaysTop) args.add("--always-on-top");
      if (_chkScreenOff) args.add("--turn-screen-off");
      if (!_chkAudioToPC) args.add("--no-audio");
      _otgActiveTimer?.cancel();
      _otgActiveSeconds = 0;
      _otgActiveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _scrcpyProcess == null || _scrcpyMode != 'otg') {
          timer.cancel();
          return;
        }
        setState(() {
          _otgActiveSeconds++;
        });
      });
      final mouseDesc = _otgMouseMode == 'uhid'
          ? tr('Cursor Locked (Press LAlt to release)', 'Kursor Terkunci (Tekan LAlt untuk lepas)')
          : tr('Free Cursor In/Out', 'Kursor Bebas Keluar Masuk');
      _showToast(tr("Starting OTG HID Control mode ($mouseDesc)...", "Memulai mode Kontrol OTG HID ($mouseDesc)..."));
    } else {
      // 4. MODE MIRRORING LAYAR NORMAL
      // Jangan paksa lebar & tinggi agar ukuran jendela leluasa, alami, dan bebas diperbesar user dengan mouse
      args = [
        "--video-bit-rate", "${_selectedBitrate}M",
        "--max-fps", "$_selectedFps",
        "--shortcut-mod", "lalt,lctrl",
        "--window-x", startX.toString(),
        "--window-y", startY.toString(),
      ];

      if (_selectedResolution == '1080p') {
        args.addAll(["--max-size", "1080"]);
      } else if (_selectedResolution == '720p') {
        args.addAll(["--max-size", "720"]);
      } else if (_selectedResolution == '480p') {
        args.addAll(["--max-size", "480"]);
      }

      if (_selectedCodec == 'h265') {
        args.addAll(["--video-codec", "h265"]);
      }

      if (_chkScreenOff) args.add("--turn-screen-off");
      if (_chkAlwaysTop) args.add("--always-on-top");
      if (!_chkAudioToPC) args.add("--no-audio");
      if (_chkStayAwake) args.add("--stay-awake");
      if (_chkShowTouches) args.add("--show-touches");
      if (_chkPowerOffOnClose) args.add("--power-off-on-close");
    }

    if (_chkRecordScreen && _scrcpyMode != 'otg') {
      final videoDir = Directory('$_userHomeDir/Videos/Scrcpy_Recordings');
      if (!videoDir.existsSync()) videoDir.createSync(recursive: true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = _recordFormat == 'mkv' ? 'mkv' : 'mp4';
      final recordPath = "${videoDir.path}/record_$timestamp.$ext";
      args.addAll(["--record", recordPath, "--record-format", ext]);
      if (_scrcpyMode == 'camera') {
        final int captureOrientation = _cameraOrientation == 'portrait'
            ? (_cameraFacing == 'front' ? 270 : 90)
            : 0;
        args.addAll(["--record-orientation", "$captureOrientation"]);
      }
      _showToast(tr("Recording video ($ext) to Videos folder...", "Merekam video ($ext) ke folder Videos..."));
    }

    final serial = _selectedDeviceSerial;
    final dev = _connectedDevicesList.where((d) => d.serial == serial).firstOrNull;
    final winTitle = _getDeviceWindowTitle(dev, serial);

    args.addAll(["--window-title", winTitle]);
    if (serial.isNotEmpty) {
      args.addAll(["-s", serial]);
    }

    try {
      _scrcpyProcess = await Process.start(
        scrcpyExePath,
        args,
        environment: {
          'SCRCPY_ICON_PATH': scrcpyIconPath,
          'SCRCPY_ICON_DIR': File(scrcpyIconPath).parent.path,
        },
      );
      if (serial.isNotEmpty) {
        _activeScrcpyProcesses[serial] = _scrcpyProcess!;
        if (!_mirroredSerialOrder.contains(serial)) {
          _mirroredSerialOrder.add(serial);
        }
      }
      _dockMirrorWindowNextToPanel(serial, winTitle);
      if (mounted) {
        setState(() {
          _isDisplayOff = _chkScreenOff;
        });
      }
      _scrcpyProcess?.exitCode.then((code) {
        if (mounted) {
          setState(() {
            _scrcpyProcess = null;
            if (serial.isNotEmpty) {
              _activeScrcpyProcesses.remove(serial);
              _deviceHwnds.remove(serial);
              _mirroredSerialOrder.remove(serial);
            }
            if (_deviceHwnds.isNotEmpty) {
              _scrcpyHwnd = _deviceHwnds.values.first;
            } else {
              _scrcpyHwnd = 0;
            }
            _isDisplayOff = false;
            _androidOrientationMode = 0;
            _micStreamingTimer?.cancel();
            _micStreamingSeconds = 0;
            _webcamStreamingTimer?.cancel();
            _webcamStreamingSeconds = 0;
            _otgActiveTimer?.cancel();
            _otgActiveSeconds = 0;
          });
          _syncScrcpyToPanel();
        }
      });
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Gagal menjalankan scrcpy: $e");
      if (mounted) {
        _showEngineMissingDialog();
      }
    }
  }

  void _toggleMirroring() {
    if (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty) {
      _stopAllMirroring();
    } else {
      _startMirroring();
    }
  }

  void _toggleMirrorSingleDevice(String serial) async {
    if (_activeScrcpyProcesses.containsKey(serial)) {
      final proc = _activeScrcpyProcesses.remove(serial);
      final hwnd = _deviceHwnds.remove(serial);
      _mirroredSerialOrder.remove(serial);
      if (serial == _selectedDeviceSerial) {
        if (_activeScrcpyProcesses.isNotEmpty) {
          _selectedDeviceSerial = _activeScrcpyProcesses.keys.first;
          _scrcpyProcess = _activeScrcpyProcesses.values.first;
        } else {
          _scrcpyProcess = null;
        }
      }
      if (_scrcpyHwnd == hwnd) {
        _scrcpyHwnd = _deviceHwnds.values.firstOrNull ?? 0;
      }
      if (mounted) setState(() {});
      if (proc != null) {
        if (_chkRecordScreen) {
          _showToast(tr("Finalizing recording for $serial...", "Memfinalisasi rekaman $serial..."));
        } else {
          _showToast(tr("Closing mirror for $serial...", "Menutup mirror $serial..."));
        }
        await _gracefullyStopScrcpy(proc, hwnd: hwnd);
        _showToast(tr("Mirroring for $serial stopped.", "Mirroring $serial dihentikan."));
      }
      _syncScrcpyToPanel();
      return;
    }

    final dev = _connectedDevicesList.where((d) => d.serial == serial).firstOrNull;
    final winTitle = _getDeviceWindowTitle(dev, serial);

    final panelPos = await windowManager.getPosition();
    final panelSize = await windowManager.getSize();
    final offsetIndex = _activeScrcpyProcesses.length;
    final int startX;
    final int startY;
    if (_multiWindowLayout == 'grid' && offsetIndex >= 1) {
      final cols = offsetIndex < 4 ? 2 : 3;
      final c = offsetIndex % cols;
      final r = offsetIndex ~/ cols;
      startX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows + (c * 275)).toInt();
      startY = (offsetIndex < 2 ? panelPos.dy.toInt() : (panelPos.dy.toInt() + (r * 320)));
    } else {
      startX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows + (offsetIndex * 310)).toInt();
      startY = panelPos.dy.toInt();
    }

    List<String> args = [
      "-s", serial,
      "--window-title", winTitle,
      "--video-bit-rate", "${_selectedBitrate}M",
      "--max-fps", "$_selectedFps",
      "--shortcut-mod", "lalt,lctrl",
      "--window-x", startX.toString(),
      "--window-y", startY.toString(),
    ];

    if (_selectedResolution == '1080p') {
      args.addAll(["--max-size", "1080"]);
    } else if (_selectedResolution == '720p') {
      args.addAll(["--max-size", "720"]);
    } else if (_selectedResolution == '480p') {
      args.addAll(["--max-size", "480"]);
    }

    if (_selectedCodec == 'h265') args.addAll(["--video-codec", "h265"]);
    if (_chkScreenOff) args.add("--turn-screen-off");
    if (_chkAlwaysTop) args.add("--always-on-top");
    if (!_chkAudioToPC) args.add("--no-audio");
    if (_chkStayAwake) args.add("--stay-awake");

    try {
      final proc = await Process.start(
        scrcpyExePath,
        args,
        environment: {
          'SCRCPY_ICON_PATH': scrcpyIconPath,
          'SCRCPY_ICON_DIR': File(scrcpyIconPath).parent.path,
        },
      );
      _activeScrcpyProcesses[serial] = proc;
      if (!_mirroredSerialOrder.contains(serial)) {
        _mirroredSerialOrder.add(serial);
      }
      if (_selectedDeviceSerial.isEmpty || _scrcpyProcess == null) {
        _selectedDeviceSerial = serial;
        _scrcpyProcess = proc;
      } else if (serial == _selectedDeviceSerial) {
        _scrcpyProcess = proc;
      }
      _dockMirrorWindowNextToPanel(serial, winTitle);
      proc.exitCode.then((_) {
        _activeScrcpyProcesses.remove(serial);
        _deviceHwnds.remove(serial);
        _mirroredSerialOrder.remove(serial);
        if (_scrcpyProcess == proc) _scrcpyProcess = null;
        if (_scrcpyHwnd == (_deviceHwnds[serial] ?? 0)) {
          _scrcpyHwnd = _deviceHwnds.values.firstOrNull ?? 0;
        }
        if (mounted) setState(() {});
        _syncScrcpyToPanel();
      });
      if (mounted) setState(() {});
      _showToast(tr("Opening mirror for $winTitle...", "Membuka mirror untuk $winTitle..."));
    } catch (e) {
      _showToast(tr("Failed to mirror $serial: $e", "Gagal mirror $serial: $e"));
      if (mounted) {
        _showEngineMissingDialog();
      }
    }
  }

  void _startMultiMirroringAll() async {
    final onlineDevices = _connectedDevicesList.where((d) => d.state == 'device').toList();
    if (onlineDevices.isEmpty) {
      _showToast(tr('No online devices connected.', 'Tidak ada perangkat online.'));
      return;
    }

    final panelPos = await windowManager.getPosition();
    final panelSize = await windowManager.getSize();

    int idx = 0;
    for (var dev in onlineDevices) {
      if (_activeScrcpyProcesses.containsKey(dev.serial)) {
        idx++;
        continue;
      }

      final winTitle = _getDeviceWindowTitle(dev, dev.serial);
      final int startX;
      final int startY;
      if (_multiWindowLayout == 'grid') {
        final cols = onlineDevices.length <= 2 ? 2 : (onlineDevices.length <= 6 ? 3 : 4);
        final c = idx % cols;
        final r = idx ~/ cols;
        startX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows + (c * 275)).toInt();
        startY = (onlineDevices.length <= 2 ? panelPos.dy.toInt() : (panelPos.dy.toInt() + (r * 320)));
      } else {
        startX = (panelPos.dx + panelSize.width - 7 + _gapBetweenWindows + (idx * 310)).toInt();
        startY = panelPos.dy.toInt();
      }

      final bool isMultiFarm = onlineDevices.length >= 4;
      final targetH = panelSize.height.toInt().clamp(480, 720);
      final targetW = (targetH * 0.52).round();
      List<String> args = [
        "-s", dev.serial,
        "--window-title", winTitle,
        "--video-bit-rate", "${_selectedBitrate}M",
        "--max-fps", "$_selectedFps",
        "--shortcut-mod", "lalt,lctrl",
        "--window-x", startX.toString(),
        "--window-y", startY.toString(),
      ];
      if (isMultiFarm) {
        args.addAll([
          "--window-width", targetW.toString(),
          "--window-height", targetH.toString(),
        ]);
      }

      if (_selectedResolution == '1080p') {
        args.addAll(["--max-size", "1080"]);
      } else if (_selectedResolution == '720p') {
        args.addAll(["--max-size", "720"]);
      }
      if (_chkAlwaysTop) args.add("--always-on-top");
      if (_chkScreenOff) args.add("--turn-screen-off");

      try {
        final proc = await Process.start(
          scrcpyExePath,
          args,
          environment: {
            'SCRCPY_ICON_PATH': scrcpyIconPath,
            'SCRCPY_ICON_DIR': File(scrcpyIconPath).parent.path,
          },
        );
        _activeScrcpyProcesses[dev.serial] = proc;
        if (!_mirroredSerialOrder.contains(dev.serial)) {
          _mirroredSerialOrder.add(dev.serial);
        }
        if (_scrcpyProcess == null) {
          _selectedDeviceSerial = dev.serial;
          _scrcpyProcess = proc;
        }
        _dockMirrorWindowNextToPanel(dev.serial, winTitle);
        proc.exitCode.then((_) {
          _activeScrcpyProcesses.remove(dev.serial);
          _deviceHwnds.remove(dev.serial);
          _mirroredSerialOrder.remove(dev.serial);
          if (_scrcpyProcess == proc) _scrcpyProcess = null;
          if (_scrcpyHwnd == (_deviceHwnds[dev.serial] ?? 0)) {
            _scrcpyHwnd = _deviceHwnds.values.firstOrNull ?? 0;
          }
          if (mounted) setState(() {});
          _syncScrcpyToPanel();
        });
      } catch (_) {}

      idx++;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) setState(() {});
    _showToast(tr("Opening ${onlineDevices.length} mirror windows side-by-side...", "Membuka ${onlineDevices.length} jendela mirroring berdampingan..."));
  }

  Future<void> _stopAllMirroring() async {
    final procs = List<Process>.from(_activeScrcpyProcesses.values);
    if (_scrcpyProcess != null && !procs.contains(_scrcpyProcess)) {
      procs.add(_scrcpyProcess!);
    }
    _activeScrcpyProcesses.clear();
    _scrcpyProcess = null;

    final scrcpyHwnd = _getScrcpyHwnd();
    _scrcpyHwnd = 0;
    _deviceHwnds.clear();
    _mirroredSerialOrder.clear();
    _isDisplayOff = false;
    _androidOrientationMode = 0;
    _syncTimer?.cancel();
    _micStreamingTimer?.cancel();
    _micStreamingSeconds = 0;
    _webcamStreamingTimer?.cancel();
    _webcamStreamingSeconds = 0;
    _otgActiveTimer?.cancel();
    _otgActiveSeconds = 0;
    if (mounted) setState(() {});

    if (procs.isNotEmpty) {
      if (_chkRecordScreen) {
        _showToast(tr("Saving & finalizing video recording...", "Menyimpan & memfinalisasi rekaman video..."));
      }
      for (var proc in procs) {
        await _gracefullyStopScrcpy(proc, hwnd: scrcpyHwnd);
      }
      if (_chkRecordScreen) {
        _showToast(tr("Video recording saved in Videos folder.", "Rekaman video tersimpan rapi di folder Videos."));
      } else {
        _showToast(tr("All mirroring windows closed.", "Semua jendela mirroring ditutup."));
      }
    }
  }

  void _kirimPerintah(String perintah) async {
    try {
      List<String> args = [];
      if (perintah == "HOME") {
        args = ['shell', 'input', 'keyevent', '3'];
      } else if (perintah == "BACK") {
        args = ['shell', 'input', 'keyevent', '4'];
      } else if (perintah == "RECENTS") {
        args = ['shell', 'input', 'keyevent', '187'];
      } else if (perintah == "POWER") {
        args = ['shell', 'input', 'keyevent', '26'];
      } else if (perintah == "POWER_MENU") {
        args = ['shell', 'input', 'keyevent', '--longpress', '26'];
      } else if (perintah == "NOTIF") {
        await Process.run(adbExePath, _withSerial(['shell', 'cmd', 'statusbar', 'expand-notifications']));
        await Process.run(adbExePath, _withSerial(['shell', 'service', 'call', 'statusbar', '1']));
        _sendScrcpyNotifShortcut();
        _focusScrcpyWindow();
        return;
      } else if (perintah == "VOL_UP") {
        args = ['shell', 'input', 'keyevent', '24'];
      } else if (perintah == "VOL_DOWN") {
        args = ['shell', 'input', 'keyevent', '25'];
      } else if (perintah == "MUTE") {
        args = ['shell', 'input', 'keyevent', '164'];
      }

      if (args.isNotEmpty) {
        await Process.run(adbExePath, _withSerial(args));
        _focusScrcpyWindow();
      }
    } catch (e) {
      debugPrint("Gagal kirim perintah $perintah: $e");
    }
  }

  Widget _buildMiniIconButton({
    required IconData icon,
    String? tooltip,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bgColor,
    Color? hoverColor,
    bool isActive = false,
    double size = 30,
    double iconSize = 16,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(6);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        hoverColor: hoverColor ?? (_isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x0D000000)),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor ?? (isActive ? const Color(0x26388BFD) : t.bgButton),
            borderRadius: radius,
            border: Border.all(
              color: isActive ? const Color(0x66388BFD) : t.borderSecondary,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? (isActive ? const Color(0xFF388BFD) : t.textSecondary),
          ),
        ),
      ),
    );

    if (tooltip != null && !_isFolded) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 250),
        child: button,
      );
    }
    return button;
  }

  Widget _buildActionChipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? tooltip,
    Color? iconColor,
    Color? bgColor,
    Color? borderColor,
    bool isActive = false,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: _isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor ?? (isActive ? (_isDarkMode ? const Color(0x26388BFD) : const Color(0xFFEFF6FF)) : t.bgButton),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: borderColor ?? (isActive ? const Color(0xFF2F81F7) : t.borderSecondary),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13.5, color: iconColor ?? (isActive ? const Color(0xFF0969DA) : t.textSecondary)),
              const SizedBox(width: 4),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: label.length > 9 ? 9.5 : 10.0,
                    fontWeight: FontWeight.w500,
                    color: isActive ? (_isDarkMode ? Colors.white : const Color(0xFF0969DA)) : t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        textStyle: const TextStyle(fontSize: 10, color: Color(0xFFE6EDF3)),
        child: button,
      );
    }
    return button;
  }

  Widget _buildCheckboxItem(String label, String subtitle, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2F81F7),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: t.borderSubtle, width: 1.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: t.textPrimary)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSelector<T>({
    required String title,
    required List<T> options,
    required T selectedValue,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: t.bgSegmentInactive,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Row(
            children: options.map((opt) {
              final isSelected = opt == selectedValue;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2F81F7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      labelBuilder(opt),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : t.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isConnected = _connectionStatus == 'Connected';

    // ==========================================
    // 1. TAMPILAN MODE LIPAT (DOCK VERTIKAL 48px)
    // ==========================================
    if (_isFolded) {
      final isScrcpyActive = _scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty;
      return Scaffold(
        backgroundColor: t.bgDock,
        body: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: t.bgDock,
              border: Border.all(color: t.borderPrimary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                // 1. Expand Button
                DragToMoveArea(
                  child: Container(
                    height: 28,
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFoldPanel,
                        borderRadius: BorderRadius.circular(6),
                        hoverColor: const Color(0x1AFFFFFF),
                        child: Container(
                          width: 28,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF181A1F),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF282C35), width: 1),
                          ),
                          child: const Icon(Icons.chevron_right_outlined, size: 16, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Drag Handle
                DragToMoveArea(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.move,
                    child: Container(
                      height: 8,
                      alignment: Alignment.center,
                      child: Container(
                        width: 14,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF333842),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Container(width: 20, height: 1, color: const Color(0xFF262932)),
                ),

                // 3. Mini Toolstrip (Semua 11 icon muat tanpa scroll)
                Expanded(
                  child: Center(
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniIconButton(
                              icon: isScrcpyActive ? Icons.screen_share_outlined : Icons.screen_share_outlined,
                              tooltip: isScrcpyActive
                                  ? tr('Scrcpy Active (Click to Stop/Restart)', 'Scrcpy Aktif (Klik untuk Stop/Mulai Ulang)')
                                  : tr('Start Mirroring', 'Mulai Mirroring'),
                              isActive: isScrcpyActive,
                              size: 27,
                              iconSize: 15.5,
                              iconColor: isScrcpyActive ? const Color(0xFF3FB950) : null,
                              onTap: _toggleMirroring,
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: _isDisplayOff ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              tooltip: _isDisplayOff
                                  ? tr('Phone Screen Off (Click to turn on)', 'Layar HP Mati (Buka Mata)')
                                  : tr('Phone Screen On (Click to turn off)', 'Layar HP Nyala (Tutup Mata)'),
                              isActive: _isDisplayOff,
                              size: 27,
                              iconSize: 15.5,
                              onTap: _toggleScreenDisplay,
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.screen_rotation_outlined,
                              tooltip: _androidOrientationMode == 0
                                  ? tr('Phone Orientation: Auto-Rotate Sensor', 'Rotasi HP: Auto-Rotate Sensor')
                                  : (_androidOrientationMode == 2
                                      ? tr('Phone Orientation: Landscape (90°)', 'Rotasi HP: Mendatar (90°)')
                                      : tr('Phone Orientation: Portrait (0°)', 'Rotasi HP: Tegak (0°)')),
                              size: 27,
                              iconSize: 15.5,
                              isActive: _androidOrientationMode != 0,
                              onTap: _cycleAndroidOrientation,
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: _isLiveScreenRecording ? Icons.stop_circle_rounded : Icons.videocam_outlined,
                              tooltip: _isLiveScreenRecording
                                  ? tr('Stop Recording (${_formatDuration(_liveScreenRecordSeconds)})', 'Stop Rekam Video (${_formatDuration(_liveScreenRecordSeconds)})')
                                  : tr('Start Video Screen Recording (MP4)', 'Mulai Rekam Layar Video (MP4)'),
                              size: 27,
                              iconSize: 15.5,
                              isActive: _isLiveScreenRecording,
                              iconColor: _isLiveScreenRecording ? const Color(0xFFF85149) : null,
                              onTap: _isLiveScreenRecording ? _stopLiveScreenRecord : _startLiveScreenRecord,
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.camera_alt_outlined,
                              tooltip: tr('Take Screenshot to Pictures folder', 'Ambil Screenshot ke Pictures'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: _takeScreenshot,
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.volume_up_outlined,
                              tooltip: tr('Volume Up', 'Volume Naik'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("VOL_UP"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.volume_down_outlined,
                              tooltip: tr('Volume Down', 'Volume Turun'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("VOL_DOWN"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.home_outlined,
                              tooltip: tr('Home', 'Beranda (Home)'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("HOME"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.arrow_back_outlined,
                              tooltip: tr('Back', 'Kembali (Back)'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("BACK"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.grid_view_outlined,
                              tooltip: tr('Recent Apps', 'Aplikasi Terakhir (Recents)'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("RECENTS"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.notifications_none_outlined,
                              tooltip: tr('Pull Notifications', 'Tarik Notifikasi'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("NOTIF"),
                            ),
                            const SizedBox(height: 3.5),
                            _buildMiniIconButton(
                              icon: Icons.lock_outline_rounded,
                              tooltip: tr('Lock Screen / Power', 'Kunci Layar / Daya'),
                              size: 27,
                              iconSize: 15.5,
                              onTap: () => _kirimPerintah("POWER"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Container(width: 20, height: 1, color: const Color(0x4D30363D)),
                ),
                const SizedBox(height: 3.5),

                // 4. Status LED (Active Mirror = Green, Connected/Standby = Cyan/Blue, Disconnected = Amber)
                Builder(
                  builder: (context) {
                    final Color ledColor;
                    final Color ledBg;
                    final Color ledBorder;

                    if (isScrcpyActive) {
                      ledColor = const Color(0xFF3FB950);
                      ledBg = const Color(0x26238636);
                      ledBorder = const Color(0x663FB950);
                    } else if (isConnected) {
                      ledColor = const Color(0xFF58A6FF);
                      ledBg = const Color(0x26388BFD);
                      ledBorder = const Color(0x6658A6FF);
                    } else {
                      ledColor = const Color(0xFFD29922);
                      ledBg = const Color(0x26D29922);
                      ledBorder = const Color(0x66D29922);
                    }

                    return InkWell(
                      onTap: _checkAdbConnection,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 24,
                        height: 13,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ledBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: ledBorder, width: 1),
                        ),
                        child: Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ledColor,
                            boxShadow: [
                              BoxShadow(
                                color: ledColor.withValues(alpha: 0.8),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 3),

                // 5. Window Controls
                _buildMiniIconButton(
                  icon: Icons.remove_rounded,
                  tooltip: tr('Minimize', 'Minimalkan'),
                  size: 22,
                  iconSize: 12,
                  iconColor: const Color(0xFF8B949E),
                  bgColor: Colors.transparent,
                  onTap: _minimizeBothWindows,
                ),
                const SizedBox(height: 2),
                _buildMiniIconButton(
                  icon: Icons.close_rounded,
                  tooltip: tr('Close', 'Tutup'),
                  size: 22,
                  iconSize: 12,
                  iconColor: const Color(0xFF8B949E),
                  bgColor: Colors.transparent,
                  hoverColor: const Color(0x4DF85149),
                  onTap: _closeApp,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      );
    }

    // ==========================================
    // 2. TAMPILAN PANEL LENGKAP (320px)
    // ==========================================
    final isScrcpyActive = _scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty;

    return Scaffold(
      backgroundColor: t.bgMain,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: t.bgMain,
            border: Border.all(color: t.borderPrimary, width: 1),
          ),
          child: Column(
            children: [
              // 1. Frameless Custom Header Bar
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: t.bgHeader,
                child: Row(
                  children: [
                    DragToMoveArea(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icon.png',
                            height: 18,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(Icons.stay_current_portrait_outlined, size: 14, color: t.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ScrcpyDock',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Language Switcher Chip (EN / ID)
                    Tooltip(
                      message: _isIndonesian ? 'Switch to English' : 'Ganti ke Bahasa Indonesia',
                      waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: _toggleLanguage,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: t.bgButton,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.borderSubtle, width: 0.8),
                          ),
                          child: Text(
                            _isIndonesian ? 'ID' : 'EN',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: t.brandPrimary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Conditional Icon Theme Switcher (Sejajar dengan nama brand)
                    Tooltip(
                      message: _isDarkMode ? tr('Switch to Light Mode', 'Beralih ke Tema Terang') : tr('Switch to Dark Mode', 'Beralih ke Tema Gelap'),
                      waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: _toggleThemeMode,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            _isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 13.5,
                            color: _isDarkMode ? const Color(0xFFD29922) : const Color(0xFF0969DA),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DragToMoveArea(
                        child: Container(
                          height: 34,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: tr('Fold Panel', 'Lipat Panel'),
                      waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: _toggleFoldPanel,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_left_outlined, size: 18, color: t.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: tr('Minimize', 'Minimalkan'),
                      waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: _minimizeBothWindows,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.remove_outlined, size: 14, color: t.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: tr('Close', 'Tutup'),
                      waitDuration: const Duration(milliseconds: 200),
                      child: InkWell(
                        onTap: _closeApp,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.close_outlined, size: 14, color: t.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Modern Segmented Tab Switcher (Kontrol / Kualitas / TinyTask / Device / About)
              Container(
                margin: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: t.bgTabContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.borderPrimary),
                ),
                child: Row(
                  children: [
                    _buildTabItem(index: 0, icon: Icons.gamepad_outlined, label: tr('Control', 'Kontrol')),
                    _buildTabItem(index: 1, icon: Icons.tune_outlined, label: tr('Quality', 'Kualitas')),
                    _buildTabItem(index: 2, icon: Icons.smart_toy_outlined, label: tr('Macro', 'Makro')),
                    _buildTabItem(index: 3, icon: Icons.devices_outlined, label: tr('Device', 'Perangkat')),
                    _buildTabItem(index: 4, icon: Icons.info_outline_rounded, label: tr('About', 'Tentang')),
                  ],
                ),
              ),

              // 3. Tab Body Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedTab == 0) _buildTabKontrol(),
                      if (_selectedTab == 1) _buildTabKualitas(),
                      if (_selectedTab == 2) _buildTabMacro(),
                      if (_selectedTab == 3) _buildTabPerangkat(isConnected),
                      if (_selectedTab == 4) _buildTabAbout(),
                    ],
                  ),
                ),
              ),

              // Floating Toast Info (jika ada notifikasi)
              if (_toastMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.isDark ? const Color(0xFF262C36) : const Color(0xFFDDF4FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: t.isDark ? const Color(0xFF38BDF8) : const Color(0xFF54A0FF), width: 1),
                    boxShadow: [
                      BoxShadow(color: t.isDark ? const Color(0x33000000) : const Color(0x14000000), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: t.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0969DA)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _toastMessage!,
                          style: TextStyle(fontSize: 10.5, color: t.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              // 4. Pinned Bottom Bar (Status Device + Tombol Utama Mirroring)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                decoration: BoxDecoration(
                  color: t.bgCard,
                  border: Border(top: BorderSide(color: t.divider, width: 1)),
                ),
                child: Builder(
                  builder: (context) {
                    final devList = (_connectedDevicesList.isNotEmpty
                        ? _connectedDevicesList
                        : _connectedDevices.map((s) => DeviceInfo(serial: s, model: '', state: 'device', isWifi: s.contains(':'))).toList());

                    final int totalMirrorsOpen = devList.where((d) =>
                        _activeScrcpyProcesses.containsKey(d.serial) ||
                        (d.serial == _selectedDeviceSerial && _scrcpyProcess != null) ||
                        (_deviceHwnds.containsKey(d.serial) && _deviceHwnds[d.serial] != 0)).length;

                    final String bottomButtonLabel;
                    if (_activeScrcpyProcesses.length > 1) {
                      bottomButtonLabel = tr('Stop All Mirrors (${_activeScrcpyProcesses.length})', 'Stop Semua Mirroring (${_activeScrcpyProcesses.length})');
                    } else if (isScrcpyActive) {
                      bottomButtonLabel = tr('Stop / Restart Mirroring', 'Stop / Mulai Ulang Mirroring');
                    } else {
                      bottomButtonLabel = tr('Start Mirroring', 'Mulai Mirroring');
                    }

                    return Column(
                      children: [
                        // Status Badge mini
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _connectedDevices.length > 1
                                  ? DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _connectedDevices.contains(_selectedDeviceSerial)
                                            ? _selectedDeviceSerial
                                            : (_connectedDevices.isNotEmpty ? _connectedDevices.first : null),
                                        isDense: true,
                                        isExpanded: true,
                                        dropdownColor: t.bgCard,
                                        icon: Icon(Icons.arrow_drop_down, size: 16, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                                        ),
                                        selectedItemBuilder: (context) {
                                          return devList.map((d) {
                                            final isMirrorOpen = _activeScrcpyProcesses.containsKey(d.serial) ||
                                                (d.serial == _selectedDeviceSerial && _scrcpyProcess != null) ||
                                                (_deviceHwnds.containsKey(d.serial) && _deviceHwnds[d.serial] != 0);
                                            final label = d.model.isNotEmpty
                                                ? '${d.model} (${d.isWifi ? "Wi-Fi" : "USB"})'
                                                : '${d.serial} (${d.isWifi ? "Wi-Fi" : "USB"})';

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6.5,
                                                  height: 6.5,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isMirrorOpen ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                                                    boxShadow: isMirrorOpen
                                                        ? const [
                                                            BoxShadow(color: Color(0x663FB950), blurRadius: 4, spreadRadius: 1),
                                                          ]
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    label,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: isMirrorOpen ? FontWeight.w600 : FontWeight.w500,
                                                      color: isMirrorOpen ? t.textPrimary : (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                                                    ),
                                                  ),
                                                ),
                                                if (isMirrorOpen) ...[
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0x263FB950),
                                                      borderRadius: BorderRadius.circular(3),
                                                      border: Border.all(color: const Color(0x593FB950), width: 0.7),
                                                    ),
                                                    child: Text(
                                                      tr('Mirror Active', 'Mirror Aktif'),
                                                      style: const TextStyle(
                                                        fontSize: 7.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF3FB950),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            );
                                          }).toList();
                                        },
                                        items: devList.map((d) {
                                          final isMirrorOpen = _activeScrcpyProcesses.containsKey(d.serial) ||
                                              (d.serial == _selectedDeviceSerial && _scrcpyProcess != null) ||
                                              (_deviceHwnds.containsKey(d.serial) && _deviceHwnds[d.serial] != 0);
                                          final isSelected = d.serial == _selectedDeviceSerial;
                                          final label = d.model.isNotEmpty
                                              ? '${d.model} (${d.isWifi ? "Wi-Fi" : "USB"})'
                                              : '${d.serial} (${d.isWifi ? "Wi-Fi" : "USB"})';

                                          return DropdownMenuItem<String>(
                                            value: d.serial,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isMirrorOpen ? const Color(0xFF3FB950) : const Color(0xFF6E7681),
                                                    boxShadow: isMirrorOpen
                                                        ? const [
                                                            BoxShadow(color: Color(0x663FB950), blurRadius: 4, spreadRadius: 1),
                                                          ]
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    label,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                      color: isSelected
                                                          ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                                          : (isMirrorOpen ? t.textPrimary : t.textSecondary),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isMirrorOpen ? const Color(0x263FB950) : const Color(0x1F8B949E),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: isMirrorOpen ? const Color(0x593FB950) : const Color(0x338B949E),
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isMirrorOpen ? Icons.screen_share_rounded : Icons.pause_circle_outline_rounded,
                                                        size: 9.5,
                                                        color: isMirrorOpen ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        isMirrorOpen ? tr('Mirror Active', 'Mirror Aktif') : tr('Standby', 'Standby'),
                                                        style: TextStyle(
                                                          fontSize: 8.5,
                                                          fontWeight: isMirrorOpen ? FontWeight.w600 : FontWeight.normal,
                                                          color: isMirrorOpen ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedDeviceSerial = val;
                                              final dev = _connectedDevicesList.where((d) => d.serial == val).firstOrNull;
                                              _connectedDeviceName = dev != null && dev.model.isNotEmpty ? dev.model : val;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Container(
                                          width: 6.5,
                                          height: 6.5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isScrcpyActive
                                                ? const Color(0xFF3FB950)
                                                : (isConnected ? const Color(0xFF8B949E) : const Color(0xFFD29922)),
                                            boxShadow: isScrcpyActive
                                                ? const [
                                                    BoxShadow(color: Color(0x663FB950), blurRadius: 4, spreadRadius: 1),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            isConnected
                                                ? (_connectedDeviceName.isNotEmpty ? _connectedDeviceName : tr('Device Ready', 'HP Siap'))
                                                : tr('Device Disconnected', 'HP Terputus'),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: isScrcpyActive ? FontWeight.w600 : FontWeight.w500,
                                              color: isScrcpyActive
                                                  ? t.textPrimary
                                                  : (isConnected
                                                      ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                                      : const Color(0xFFD29922)),
                                            ),
                                          ),
                                        ),
                                        if (isScrcpyActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0x263FB950),
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: const Color(0x593FB950), width: 0.7),
                                            ),
                                            child: Text(
                                              tr('Mirror Active', 'Mirror Aktif'),
                                              style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700, color: Color(0xFF3FB950)),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (totalMirrorsOpen > 1) ...[
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _multiWindowLayout = _multiWindowLayout == 'grid' ? 'horizontal' : 'grid';
                                      });
                                      _syncScrcpyToPanel();
                                      _showToast(tr(_multiWindowLayout == 'grid' ? 'Adaptive Grid Mode' : 'Side-by-side Mode', _multiWindowLayout == 'grid' ? 'Mode Grid Adaptif' : 'Mode Berdampingan'));
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: t.bgModeBox,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: t.borderPrimary, width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _multiWindowLayout == 'grid' ? Icons.grid_view_rounded : Icons.view_column_rounded,
                                            size: 9.5,
                                            color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            _multiWindowLayout == 'grid' ? 'Grid' : tr('Row', 'Baris'),
                                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0x263FB950),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0x593FB950), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.screen_share_rounded, size: 9.5, color: Color(0xFF3FB950)),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$totalMirrorsOpen ${tr('Active', 'Aktif')}',
                                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF3FB950)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                InkWell(
                                  onTap: _checkAdbConnection,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      children: [
                                        Icon(Icons.refresh_rounded, size: 11, color: t.textSecondary),
                                        const SizedBox(width: 3),
                                        Text(tr('Refresh', 'Segarkan'), style: TextStyle(fontSize: 10, color: t.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Primary Mirroring Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isScrcpyActive ? const Color(0xFF238636) : const Color(0xFF2F81F7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            onPressed: _toggleMirroring,
                            icon: Icon(
                              isScrcpyActive ? Icons.stop_circle_rounded : Icons.play_arrow_rounded,
                              size: 17,
                            ),
                            label: Text(
                              bottomButtonLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGETS TABS
  // ==========================================

  Widget _buildTabItem({required int index, required IconData icon, required String label}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          if (_mainScrollController.hasClients) {
            _mainScrollController.jumpTo(0);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
          decoration: BoxDecoration(
            color: isSelected ? t.bgTabActive : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border.all(color: t.borderPrimary, width: 1) : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 11, color: isSelected ? const Color(0xFF2F81F7) : t.textSecondary),
                  const SizedBox(width: 2.5),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? t.textPrimary : t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 1: KONTROL & AKSI CEPAT
  Widget _buildTabKontrol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Layar HP & Rotasi
        Text(
          tr('SCREEN CONTROL & ROTATION', 'KONTROL LAYAR & ROTASI'),
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.visibility_off_outlined,
                label: tr('Turn Screen Off', 'Tutup Layar HP'),
                isActive: _isDisplayOff,
                onTap: () => _sendScrcpyScreenPower(turnOff: true),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.visibility_outlined,
                label: tr('Turn Screen On', 'Buka Layar HP'),
                isActive: !_isDisplayOff,
                onTap: () => _sendScrcpyScreenPower(turnOff: false),
              ),
            ),
            const SizedBox(width: 6),
            _buildMiniIconButton(
              icon: Icons.screen_rotation_outlined,
              tooltip: _androidOrientationMode == 0
                  ? tr('Phone Rotation: Auto Sensor', 'Rotasi HP: Auto-Rotate Sensor')
                  : (_androidOrientationMode == 2
                      ? tr('Phone Rotation: Landscape (90°)', 'Rotasi HP: Mendatar (90°)')
                      : tr('Phone Rotation: Portrait (0°)', 'Rotasi HP: Tegak (0°)')),
              onTap: _cycleAndroidOrientation,
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Pilihan Orientasi Layar (Dual Normal Function)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: t.bgModeBox,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Row(
            children: [
              _buildOrientationChip(0, Icons.screen_rotation_outlined, 'Auto-Rotate'),
              const SizedBox(width: 4),
              _buildOrientationChip(1, Icons.stay_current_portrait_outlined, tr('Portrait (0°)', 'Tegak (0°)')),
              const SizedBox(width: 4),
              _buildOrientationChip(2, Icons.stay_current_landscape_outlined, tr('Landscape (90°)', 'Mendatar (90°)')),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Perekam Layar Dinamis (On-Demand saat Mirror Berjalan)
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: _isLiveScreenRecording ? Icons.stop_circle_rounded : Icons.videocam_outlined,
                label: _isLiveScreenRecording
                    ? tr('Stop Recording (${_formatDuration(_liveScreenRecordSeconds)})', 'Stop Rekam (${_formatDuration(_liveScreenRecordSeconds)})')
                    : tr('Screen Record', 'Rekam Layar'),
                isActive: _isLiveScreenRecording,
                iconColor: _isLiveScreenRecording ? const Color(0xFFF85149) : null,
                onTap: _isLiveScreenRecording ? _stopLiveScreenRecord : _startLiveScreenRecord,
              ),
            ),
            const SizedBox(width: 6),
            _buildMiniIconButton(
              icon: Icons.video_library_outlined,
              tooltip: tr('Open Video Recordings Folder', 'Buka Folder Rekaman Video'),
              onTap: _openRecordingsFolder,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Mode Operasi (1-Klik): Layar, Webcam, Mic, OTG
        _buildModeOperasiSection(),
        const SizedBox(height: 10),

        // 2. Navigasi HP
        Text(
          tr('SYSTEM NAVIGATION', 'NAVIGASI SISTEM'),
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () => _kirimPerintah("HOME"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.arrow_back_outlined,
                label: 'Back',
                onTap: () => _kirimPerintah("BACK"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.grid_view_outlined,
                label: 'Apps',
                onTap: () => _kirimPerintah("RECENTS"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.lock_outline_rounded,
                label: tr('Lock Screen', 'Kunci Layar'),
                onTap: () => _kirimPerintah("POWER"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.notifications_none_outlined,
                label: tr('Notification', 'Notifikasi'),
                onTap: () => _kirimPerintah("NOTIF"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.power_settings_new_outlined,
                label: tr('Power Menu', 'Menu Daya'),
                onTap: () => _kirimPerintah("POWER_MENU"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. Audio & Alat Ekstra
        Text(
          tr('AUDIO & PC SHORTCUTS', 'AUDIO & SHORTCUT PC'),
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.volume_up_outlined,
                label: 'Vol Up',
                onTap: () => _kirimPerintah("VOL_UP"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.volume_down_outlined,
                label: 'Vol Down',
                onTap: () => _kirimPerintah("VOL_DOWN"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.volume_off_outlined,
                label: 'Mute',
                onTap: () => _kirimPerintah("MUTE"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.camera_alt_outlined,
                label: 'Screenshot',
                onTap: _takeScreenshot,
              ),
            ),
            const SizedBox(width: 6),
            _buildMiniIconButton(
              icon: Icons.folder_open_outlined,
              tooltip: tr('Open Screenshots Folder', 'Buka Folder Screenshot'),
              onTap: _openScreenshotFolder,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.content_paste_outlined,
                label: tr('Paste to Phone', 'Paste ke HP'),
                onTap: _pasteClipboardToPhone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 4. Berkas & Pasang APK (File Manager)
        Text(
          tr('FILES & APPS (FILE MANAGER)', 'BERKAS & APLIKASI (FILE MANAGER)'),
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF8B949E), letterSpacing: 0.6),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.android_outlined,
                label: tr('Install APK', 'Pasang APK'),
                onTap: _installApk,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildActionChipButton(
                icon: Icons.upload_file_outlined,
                label: tr('Send File', 'Kirim File'),
                onTap: _pushFileToDevice,
              ),
            ),
            const SizedBox(width: 6),
            _buildMiniIconButton(
              icon: Icons.folder_shared_outlined,
              tooltip: tr('Open File Manager on Phone', 'Buka File Manager di HP'),
              onTap: _openPhoneFileManager,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrientationChip(int mode, IconData icon, String label) {
    final isSel = _androidOrientationMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => _setAndroidOrientation(mode),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF2F81F7) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: isSel ? Colors.white : t.textSecondary),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    color: isSel ? Colors.white : t.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOperasiSection() {
    final bool isRunning = _scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('OPERATION MODE (1-CLICK)', 'MODE OPERASI (1-KLIK)'),
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
            ),
            if (isRunning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0x1F3FB950),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x663FB950)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FB950),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      _getModeLabel(_scrcpyMode),
                      style: const TextStyle(fontSize: 8.5, color: Color(0xFF3FB950), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.bgModeBox,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Row(
            children: [
              _buildModeChip('screen', Icons.phone_android_outlined, tr('Screen', 'Layar')),
              const SizedBox(width: 4),
              _buildModeChip('camera', Icons.videocam_outlined, 'Webcam'),
              const SizedBox(width: 4),
              _buildModeChip('audio', Icons.mic_none_outlined, 'Mic'),
              const SizedBox(width: 4),
              _buildModeChip('otg', Icons.sports_esports_outlined, 'OTG'),
            ],
          ),
        ),

        // Sub-Pengaturan Mode Aktif
        if (_scrcpyMode == 'camera') ...[
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.videocam_outlined, size: 14, color: Color(0xFF58A6FF)),
                        const SizedBox(width: 5),
                        Text(
                          tr('Phone Webcam', 'Webcam HP'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isRunning ? const Color(0x1F3FB950) : const Color(0x1F8B949E),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: isRunning ? const Color(0x663FB950) : const Color(0x338B949E)),
                      ),
                      child: Text(
                        isRunning ? 'LIVE ${_formatDuration(_webcamStreamingSeconds)}' : tr('READY', 'SIAP'),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: isRunning ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Status Lensa & Orientasi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.bgSubCard,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: t.borderSecondary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _cameraFacing == 'front' ? Icons.camera_front_outlined : Icons.camera_rear_outlined,
                            size: 13,
                            color: t.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _cameraFacing == 'front' ? tr('Front Camera', 'Kamera Depan') : tr('Rear Camera', 'Kamera Belakang'),
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: t.textPrimary),
                          ),
                        ],
                      ),
                      Text(
                        _cameraOrientation == 'portrait' ? tr('Portrait Format', 'Format Tegak') : tr('Landscape Format', 'Format Mendatar'),
                        style: TextStyle(fontSize: 9, color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),

                // Tombol Aksi Kontrol
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final nextFacing = _cameraFacing == 'front' ? 'back' : 'front';
                          setState(() => _cameraFacing = nextFacing);
                          if (_scrcpyMode == 'camera' && (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty)) {
                            _showToast(tr("Switching to ${nextFacing == 'front' ? 'Front' : 'Back'} Camera...", "Beralih ke Kamera ${nextFacing == 'front' ? 'Depan' : 'Belakang'}..."));
                            await _stopAllMirroring();
                            await Future.delayed(const Duration(milliseconds: 300));
                            _startMirroring();
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: t.bgButton,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.borderSubtle),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flip_camera_android_outlined, size: 12, color: t.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                _cameraFacing == 'front' ? tr('Switch Rear', 'Ganti Belakang') : tr('Switch Front', 'Ganti Depan'),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: t.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final nextOrientation = _cameraOrientation == 'portrait' ? 'landscape' : 'portrait';
                          setState(() => _cameraOrientation = nextOrientation);
                          if (_scrcpyMode == 'camera' && (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty)) {
                            _showToast(_isIndonesian ? 'Beralih format ${nextOrientation == 'portrait' ? 'Tegak' : 'Mendatar'}...' : 'Switching to ${nextOrientation == 'portrait' ? 'Portrait' : 'Landscape'}...');
                            await _stopAllMirroring();
                            await Future.delayed(const Duration(milliseconds: 300));
                            _startMirroring();
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: t.bgButton,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.borderSubtle),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.screen_rotation_outlined, size: 12, color: t.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                _cameraOrientation == 'portrait' ? tr('Landscape', 'Mendatar') : tr('Portrait', 'Tegak'),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: t.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => _switchScrcpyMode('screen'),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F6FEB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_android_outlined, size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              tr('To Screen', 'Ke Layar'),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else if (_scrcpyMode == 'otg') ...[
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_esports_outlined, size: 14, color: Color(0xFF58A6FF)),
                        const SizedBox(width: 5),
                        Text(
                          tr('OTG Hardware Control', 'Kontrol Hardware OTG'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isRunning ? const Color(0x1F3FB950) : const Color(0x1F8B949E),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: isRunning ? const Color(0x663FB950) : const Color(0x338B949E)),
                      ),
                      child: Text(
                        isRunning ? 'ACTIVE ${_formatDuration(_otgActiveSeconds)}' : tr('READY', 'SIAP'),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: isRunning ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Mode Mouse Selector: Bebas vs Kunci
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_otgMouseMode != 'sdk') {
                            setState(() => _otgMouseMode = 'sdk');
                            if (_scrcpyMode == 'otg' && (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty)) {
                              _showToast(_isIndonesian ? 'Beralih ke Mouse Bebas...' : 'Switching to Free Mouse...');
                              await _stopAllMirroring();
                              await Future.delayed(const Duration(milliseconds: 300));
                              _startMirroring();
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _otgMouseMode == 'sdk' ? const Color(0xFF1F6FEB) : t.bgSubCard,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _otgMouseMode == 'sdk' ? const Color(0xFF388BFD) : t.borderSecondary,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tr('Free Mouse (PC & Device)', 'Mouse Bebas (PC & HP)'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: _otgMouseMode == 'sdk' ? FontWeight.w600 : FontWeight.w400,
                              color: _otgMouseMode == 'sdk' ? Colors.white : t.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_otgMouseMode != 'uhid') {
                            setState(() => _otgMouseMode = 'uhid');
                            if (_scrcpyMode == 'otg' && (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty)) {
                              _showToast(_isIndonesian ? 'Beralih ke Mouse Kunci (Mode Game)...' : 'Switching to Locked Mouse (FPS Mode)...');
                              await _stopAllMirroring();
                              await Future.delayed(const Duration(milliseconds: 300));
                              _startMirroring();
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _otgMouseMode == 'uhid' ? const Color(0xFF1F6FEB) : t.bgSubCard,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _otgMouseMode == 'uhid' ? const Color(0xFF388BFD) : t.borderSecondary,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tr('Locked Mouse (FPS Game)', 'Mouse Kunci (Game FPS)'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: _otgMouseMode == 'uhid' ? FontWeight.w600 : FontWeight.w400,
                              color: _otgMouseMode == 'uhid' ? Colors.white : t.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),

                // Catatan ringkas & Tombol Ke Layar
                Row(
                  children: [
                    if (_otgMouseMode == 'uhid')
                      Expanded(
                        child: Text(
                          tr('Press Left Alt to release cursor', 'Tekan tombol Left Alt untuk melepas kursor'),
                          style: TextStyle(fontSize: 8.5, color: t.textSecondary),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _switchScrcpyMode('screen'),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: t.bgButton,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: t.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_android_outlined, size: 12, color: t.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              tr('To Screen', 'Ke Layar'),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: t.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else if (_scrcpyMode == 'audio') ...[
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isMicMuted ? Icons.mic_off_outlined : Icons.mic_outlined,
                          size: 14,
                          color: _isMicMuted ? const Color(0xFFF85149) : const Color(0xFF58A6FF),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tr('Phone Microphone', 'Mikrofon HP'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _isMicMuted
                            ? const Color(0x1FF85149)
                            : (isRunning ? const Color(0x1F3FB950) : const Color(0x1F8B949E)),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: _isMicMuted
                              ? const Color(0x66F85149)
                              : (isRunning ? const Color(0x663FB950) : const Color(0x338B949E)),
                        ),
                      ),
                      child: Text(
                        _isMicMuted
                            ? 'MUTED'
                            : (isRunning ? 'LIVE ${_formatDuration(_micStreamingSeconds)}' : tr('READY', 'SIAP')),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: _isMicMuted
                              ? const Color(0xFFF85149)
                              : (isRunning ? const Color(0xFF3FB950) : const Color(0xFF8B949E)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Equalizer Visualizer Waveform
                Container(
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.bgSubCard,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: t.borderSecondary),
                  ),
                  child: StudioAudioVisualizer(
                    isStreaming: isRunning,
                    isMuted: _isMicMuted,
                  ),
                ),
                const SizedBox(height: 7),

                // Action Buttons: Mute/Unmute & Kembali ke Layar
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _toggleMicMute,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _isMicMuted ? const Color(0xFFDA3633) : t.bgButton,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _isMicMuted ? const Color(0xFFF85149) : t.borderSubtle),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isMicMuted ? Icons.mic_outlined : Icons.mic_off_outlined,
                                size: 12,
                                color: _isMicMuted ? Colors.white : t.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isMicMuted
                                    ? tr('Unmute Mic', 'Buka Mic')
                                    : tr('Mute Mic', 'Bisukan Mic'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: _isMicMuted ? Colors.white : t.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _switchScrcpyMode('screen'),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F6FEB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_android_outlined, size: 12, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              tr('To Screen', 'Ke Layar'),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeChip(String mode, IconData icon, String label) {
    final bool isSelected = _scrcpyMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => _switchScrcpyMode(mode),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1F6FEB) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? const Color(0xFF58A6FF) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : t.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : t.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchScrcpyMode(String mode) async {
    if (_scrcpyMode == mode && (_scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty)) {
      _showToast(tr('${_getModeLabel(mode)} mode is currently active', 'Mode ${_getModeLabel(mode)} sedang aktif'));
      return;
    }

    setState(() {
      _scrcpyMode = mode;
    });

    final bool isRunning = _scrcpyProcess != null || _activeScrcpyProcesses.isNotEmpty;
    if (isRunning) {
      _showToast(tr('Switching to ${_getModeLabel(mode)} mode...', 'Beralih ke mode ${_getModeLabel(mode)}...'));
      await _stopAllMirroring();
      await Future.delayed(const Duration(milliseconds: 300));
      _startMirroring();
    } else {
      _showToast(tr('${_getModeLabel(mode)} mode selected. Starting...', 'Mode ${_getModeLabel(mode)} dipilih. Memulai...'));
      _startMirroring();
    }
  }

  String _getModeLabel(String mode) {
    switch (mode) {
      case 'camera':
        return 'Webcam';
      case 'audio':
        return 'Mic';
      case 'otg':
        return 'OTG';
      case 'screen':
      default:
        return tr('Screen', 'Layar');
    }
  }

  // TAB 2: PENGATURAN KUALITAS & TOGGLE
  Widget _buildTabKualitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Resolusi
        _buildSegmentSelector<String>(
          title: tr('DISPLAY RESOLUTION', 'RESOLUSI TAMPILAN'),
          options: const ['Original', '1080p', '720p', '480p'],
          selectedValue: _selectedResolution,
          onSelected: (val) => setState(() => _selectedResolution = val),
          labelBuilder: (val) => val,
        ),
        const SizedBox(height: 9),

        // FPS
        _buildSegmentSelector<int>(
          title: 'FRAME RATE (MAX FPS)',
          options: const [30, 60, 90, 120],
          selectedValue: _selectedFps,
          onSelected: (val) => setState(() => _selectedFps = val),
          labelBuilder: (val) => '${val}fps',
        ),
        const SizedBox(height: 9),

        // Bitrate Video
        _buildSegmentSelector<int>(
          title: tr('STREAMING BITRATE', 'BITRATE STREAMING'),
          options: const [4, 8, 16, 24],
          selectedValue: _selectedBitrate,
          onSelected: (val) => setState(() => _selectedBitrate = val),
          labelBuilder: (val) => '${val}Mbps',
        ),
        const SizedBox(height: 9),

        // Video Codec
        _buildSegmentSelector<String>(
          title: tr('VIDEO CODEC', 'CODEC VIDEO'),
          options: const ['h264', 'h265'],
          selectedValue: _selectedCodec,
          onSelected: (val) => setState(() => _selectedCodec = val),
          labelBuilder: (val) => val == 'h264' ? tr('H.264 (Standard)', 'H.264 (Standar)') : tr('H.265 (Fast HEVC)', 'H.265 (HEVC Cepat)'),
        ),
        const SizedBox(height: 11),

        // Toggles List
        Text(
          tr('AUTOMATIC BEHAVIOR OPTIONS', 'OPSI PERILAKU OTOMATIS'),
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Column(
            children: [
              _buildCheckboxItem('Turn screen off', '', _chkScreenOff,
                  (val) => setState(() => _chkScreenOff = val!)),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem('Always on top', '', _chkAlwaysTop,
                  (val) async {
                final isChecked = val ?? false;
                setState(() => _chkAlwaysTop = isChecked);
                if (Platform.environment['FLUTTER_TEST'] != 'true') {
                  await windowManager.setAlwaysOnTop(isChecked);
                  if (_scrcpyHwnd != 0) _syncScrcpyToPanel();
                }
              }),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem(
                  'Audio to PC', '', _chkAudioToPC, (val) => setState(() => _chkAudioToPC = val!)),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem('Stay awake', '', _chkStayAwake,
                  (val) => setState(() => _chkStayAwake = val!)),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem('Show touches', '', _chkShowTouches,
                  (val) => setState(() => _chkShowTouches = val!)),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem('Power off on close', '', _chkPowerOffOnClose,
                  (val) => setState(() => _chkPowerOffOnClose = val!)),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem(
                tr('Auto Screen Recording', 'Rekam Layar Otomatis'),
                '',
                _chkRecordScreen,
                (val) => setState(() => _chkRecordScreen = val!),
              ),
              Divider(height: 1, color: t.divider),
              _buildCheckboxItem(
                tr('Lock Aspect Ratio', 'Kunci Rasio Layar (Aspect Ratio)'),
                '',
                _chkAutoFitAspectRatio,
                (val) {
                  setState(() => _chkAutoFitAspectRatio = val ?? true);
                  if (val == true) {
                    _snapAllActiveWindowsToAspectRatio(force: true);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: MACRODOCK OTOMASI & LIVE RECORDING
  Widget _buildTabMacro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selector: Studio (Device Aktif) vs Multi-Runner
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: t.bgModeBox,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _macroViewMode = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _macroViewMode == 0 ? const Color(0xFF2F81F7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 12, color: _macroViewMode == 0 ? Colors.white : t.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          tr('Active Device', 'Device Aktif'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: _macroViewMode == 0 ? FontWeight.w600 : FontWeight.w500,
                            color: _macroViewMode == 0 ? Colors.white : t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _macroViewMode = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _macroViewMode == 1 ? const Color(0xFF2F81F7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.devices_rounded, size: 12, color: _macroViewMode == 1 ? Colors.white : t.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Multi-Runner (${_connectedDevices.length})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: _macroViewMode == 1 ? FontWeight.w600 : FontWeight.w500,
                            color: _macroViewMode == 1 ? Colors.white : t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_macroViewMode == 1)
          _buildMultiDeviceRunnerView()
        else ...[
          // 1. Control & Live Status Card
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isMacroRecording
                  ? const Color(0xFFF85149)
                  : (_isMacroRunning ? const Color(0xFF3FB950) : t.borderPrimary),
              width: (_isMacroRecording || _isMacroRunning) ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7.5,
                        height: 7.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isMacroRecording
                              ? const Color(0xFFF85149)
                              : (_isMacroRunning ? const Color(0xFF3FB950) : const Color(0xFF8B949E)),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _isMacroRecording
                            ? tr('Recording... (${_macroSteps.length} actions)', 'Merekam... (${_macroSteps.length} aksi)')
                            : (_isMacroRunning
                                ? tr('Playing - Loop $_macroCurrentLoop / ${_macroLoopCount == -1 ? "Infinite" : _macroLoopCount}', 'Memutar - Loop $_macroCurrentLoop / ${_macroLoopCount == -1 ? "Terus" : _macroLoopCount}')
                                : tr('Macro Studio Ready (${_macroSteps.length} Steps)', 'Studio Rekam Makro Siap (${_macroSteps.length} Langkah)')),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _isMacroRecording
                              ? const Color(0xFFF85149)
                              : (_isMacroRunning ? (t.isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37)) : t.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_isMacroRunning) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x263FB950),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0x663FB950)),
                          ),
                          child: Text(
                            'Step ${_macroCurrentStep + 1}/${_macroSteps.length}',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: t.isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.bgSubCard,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: t.borderSecondary),
                        ),
                        child: Text(
                          '${_deviceScreenWidth}x$_deviceScreenHeight',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: t.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tombol REC & PLAY
              Row(
                children: [
                  // Tombol Rekam (REC)
                  Expanded(
                    child: _isMacroRecording
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDA3633),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            onPressed: _stopMacroRecording,
                            icon: const Icon(Icons.stop_rounded, size: 16),
                            label: Text(tr('Stop Recording', 'Stop Rekam'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          )
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF85149),
                              side: const BorderSide(color: Color(0x66F85149)),
                              backgroundColor: const Color(0x1AF85149),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: _startMacroRecording,
                            icon: const Icon(Icons.fiber_manual_record_rounded, size: 14),
                            label: Text(tr('Record (REC)', 'Rekam (REC)'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Putar (PLAY)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMacroRunning ? const Color(0xFFDA3633) : const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: _isMacroRunning ? _stopMacro : _playMacro,
                      icon: Icon(
                        _isMacroRunning ? Icons.stop_circle_outlined : Icons.play_arrow_outlined,
                        size: 16,
                      ),
                      label: Text(
                        _isMacroRunning ? tr('Stop Playback', 'Stop Putar') : tr('Play (PLAY)', 'Putar (PLAY)'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Loop & Speed Configuration
        Row(
          children: [
            Expanded(
              child: _buildSegmentSelector<int>(
                title: tr('LOOP COUNT', 'JUMLAH LOOP'),
                options: const [1, 5, 10, -1],
                selectedValue: _macroLoopCount,
                onSelected: (val) => setState(() => _macroLoopCount = val),
                labelBuilder: (val) => val == -1 ? '∞' : '${val}x',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSegmentSelector<double>(
                title: tr('SPEED', 'KECEPATAN'),
                options: const [1.0, 1.5, 2.0],
                selectedValue: _macroSpeed,
                onSelected: (val) => setState(() => _macroSpeed = val),
                labelBuilder: (val) => '${val}x',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. Urutan Langkah (Action Queue Studio)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${tr("STEP SEQUENCE", "URUTAN LANGKAH")} (${_macroSteps.length})',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.6),
                  ),
                  if (_macroSteps.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Text(
                      '• ${(_macroSteps.fold<int>(0, (acc, s) => acc + s.delayMs) / 1000).toStringAsFixed(1)}s',
                      style: TextStyle(fontSize: 9.0, color: t.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_macroSteps.isNotEmpty) ...[
                  InkWell(
                    onTap: _showSaveMacroDialog,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF238636).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_rounded, size: 10, color: Color(0xFF3FB950)),
                          const SizedBox(width: 2.5),
                          Text(tr('Save', 'Simpan'), style: const TextStyle(fontSize: 9, color: Color(0xFF3FB950), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                InkWell(
                  onTap: _showSavedMacrosDialog,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.activeCardBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: t.borderPrimary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 10, color: t.textPrimary),
                        const SizedBox(width: 2.5),
                        Text(tr('Collection', 'Koleksi'), style: TextStyle(fontSize: 9, color: t.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                if (_macroSteps.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _macroSteps.clear();
                        _currentLoadedMacroName = null;
                      });
                      _showToast(_isIndonesian ? 'Daftar langkah dikosongkan' : 'Step list cleared');
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      child: Text('Reset', style: TextStyle(fontSize: 9, color: Color(0xFFF85149), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        // Active loaded macro banner
        if (_currentLoadedMacroName != null) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF58A6FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFF58A6FF).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, size: 12, color: Color(0xFF58A6FF)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _currentLoadedMacroName!,
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF58A6FF)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _currentLoadedMacroName = null),
                  borderRadius: BorderRadius.circular(3),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close_rounded, size: 11, color: Color(0xFF58A6FF)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),

        if (_macroSteps.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                const Icon(Icons.fiber_manual_record_rounded, size: 26, color: Color(0xFFF85149)),
                const SizedBox(height: 8),
                Text(tr('Macro Recording Studio Ready', 'Studio Rekam Makro Siap'), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  tr('Click "Record (REC)" then tap or swipe directly on the mirror window.\nEvery tap, hold, and swipe will be recorded with precision and speed can be adjusted.', 'Klik "Rekam (REC)" lalu sentuh atau geser langsung di jendela cermin HP.\nSetiap ketukan, tahanan, dan usapan akan tercatat presisi otomatis dan dapat diedit kecepatannya.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: t.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showSavedMacrosDialog,
                  icon: const Icon(Icons.folder_open_rounded, size: 14),
                  label: Text(tr('Open Saved Macro Collection', 'Buka Koleksi Makro Tersimpan'), style: const TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.textPrimary,
                    side: BorderSide(color: t.borderPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.borderPrimary),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _macroSteps.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: t.divider),
              itemBuilder: (context, index) {
                final step = _macroSteps[index];
                final isCurrent = _macroCurrentStep == index;

                IconData stepIcon;
                if (step.action == 'tap') {
                  stepIcon = Icons.touch_app_outlined;
                } else if (step.action == 'double_tap') {
                  stepIcon = Icons.favorite_border_rounded;
                } else if (step.action == 'long_press') {
                  stepIcon = Icons.hourglass_empty_outlined;
                } else if (step.action == 'rapid_tap') {
                  stepIcon = Icons.bolt_outlined;
                } else if (step.action == 'swipe') {
                  stepIcon = Icons.swipe_outlined;
                } else {
                  stepIcon = Icons.timer_outlined;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  color: isCurrent ? t.activeCardBg : Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF2F81F7) : t.bgSubCard,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isCurrent ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)) : t.borderSecondary),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? Colors.white : t.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(stepIcon, size: 14, color: isCurrent ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)) : t.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditStepDialog(index),
                          borderRadius: BorderRadius.circular(4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isCurrent ? (t.isDark ? Colors.white : t.textPrimary) : t.textPrimary,
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: t.bgModeBox,
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: t.borderPrimary),
                                    ),
                                    child: Text(
                                      '${tr("Delay", "Jeda")}: ${step.delayMs}ms',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (step.action == 'swipe' || step.action == 'long_press') ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: t.bgModeBox,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: t.borderPrimary),
                                      ),
                                      child: Text(
                                        '${tr("Duration", "Durasi")}: ${step.durationMs}ms',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          color: t.isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index > 0)
                        InkWell(
                          onTap: () {
                            setState(() {
                              final item = _macroSteps.removeAt(index);
                              _macroSteps.insert(index - 1, item);
                            });
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Icon(Icons.arrow_upward_rounded, size: 13, color: Color(0xFF8B949E)),
                          ),
                        ),
                      if (index < _macroSteps.length - 1)
                        InkWell(
                          onTap: () {
                            setState(() {
                              final item = _macroSteps.removeAt(index);
                              _macroSteps.insert(index + 1, item);
                            });
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Icon(Icons.arrow_downward_rounded, size: 13, color: Color(0xFF8B949E)),
                          ),
                        ),
                      InkWell(
                        onTap: () => _showEditStepDialog(index),
                        borderRadius: BorderRadius.circular(3),
                        child: const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(Icons.edit_outlined, size: 13, color: Color(0xFF58A6FF)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() => _macroSteps.removeAt(index));
                        },
                        borderRadius: BorderRadius.circular(3),
                        child: const Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(Icons.close_rounded, size: 13, color: Color(0xFFF85149)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _testSingleStep(MacroStep step) async {
    if (Platform.environment['FLUTTER_TEST'] == 'true') return;
    try {
      if (step.action == 'tap') {
        await Process.run(adbExePath, _withSerial(['shell', 'input', 'tap', step.x.toString(), step.y.toString()]));
      } else if (step.action == 'double_tap') {
        await Process.run(adbExePath, _withSerial(['shell', 'input', 'tap', step.x.toString(), step.y.toString()]));
        await Future.delayed(const Duration(milliseconds: 90));
        await Process.run(adbExePath, _withSerial(['shell', 'input', 'tap', step.x.toString(), step.y.toString()]));
      } else if (step.action == 'long_press') {
        await Process.run(adbExePath, _withSerial(['shell', 'input', 'swipe', step.x.toString(), step.y.toString(), step.x.toString(), step.y.toString(), step.durationMs.toString()]));
      } else if (step.action == 'swipe') {
        await Process.run(adbExePath, _withSerial(['shell', 'input', 'swipe', step.x.toString(), step.y.toString(), step.endX.toString(), step.endY.toString(), step.durationMs.toString()]));
      }
      _showToast(tr('Step test on phone completed.', 'Tes langkah di HP selesai.'));
    } catch (e) {
      _showToast(tr('Step test failed: $e', 'Gagal tes langkah: $e'));
    }
  }

  Widget _buildDialogStepBtn(String label, VoidCallback onTap, [PanelTheme? theme]) {
    final t = theme ?? PanelTheme(appThemeModeNotifier.value);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.bgModeBox,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textPrimary),
          ),
        ),
      ),
    );
  }

  void _showEditStepDialog(int index) {
    if (index < 0 || index >= _macroSteps.length) return;
    final step = _macroSteps[index];

    int editedDelay = step.delayMs;
    int editedDuration = step.durationMs;
    int editedX = step.x;
    int editedY = step.y;
    int editedEndX = step.endX;
    int editedEndY = step.endY;

    final isSwipe = step.action == 'swipe' || step.action.startsWith('swipe_');
    final isLongPress = step.action == 'long_press';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final t = PanelTheme(appThemeModeNotifier.value);
            return AlertDialog(
              backgroundColor: t.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: t.borderPrimary),
              ),
              titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F81F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Edit ${step.action.toUpperCase()} (${step.x}, ${step.y})',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    // 1. JEDA WAKTU (DELAY SEBELUM LANGKAH BERIKUTNYA)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('STEP DELAY (WAIT TIME)', 'JEDA WAKTU (DELAY)'),
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.bgModeBox,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: t.borderPrimary),
                          ),
                          child: Text(
                            '$editedDelay ms (${(editedDelay / 1000).toStringAsFixed(2)}s)',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Stepper row for Delay
                    Row(
                      children: [
                        _buildDialogStepBtn('-500ms', () {
                          setDialogState(() => editedDelay = (editedDelay - 500).clamp(50, 10000));
                        }),
                        const SizedBox(width: 4),
                        _buildDialogStepBtn('-100ms', () {
                          setDialogState(() => editedDelay = (editedDelay - 100).clamp(50, 10000));
                        }),
                        const SizedBox(width: 4),
                        _buildDialogStepBtn('+100ms', () {
                          setDialogState(() => editedDelay = (editedDelay + 100).clamp(50, 10000));
                        }),
                        const SizedBox(width: 4),
                        _buildDialogStepBtn('+500ms', () {
                          setDialogState(() => editedDelay = (editedDelay + 500).clamp(50, 10000));
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Quick presets chips for delay
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [100, 300, 500, 800, 1200, 2000, 3500].map((d) {
                        final isSel = editedDelay == d;
                        return InkWell(
                          onTap: () => setDialogState(() => editedDelay = d),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF2F81F7) : t.bgSubCard,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: isSel ? const Color(0xFF58A6FF) : t.borderSecondary),
                            ),
                            child: Text(
                              '${d}ms',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isSel ? Colors.white : t.textPrimary,
                                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (isSwipe || isLongPress) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: t.divider),
                      const SizedBox(height: 10),

                      // 2. DURASI GERAKAN / TAHAN (SWIPE & LONG PRESS)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSwipe ? tr('SWIPE SPEED / DURATION', 'KECEPATAN USAPAN (SWIPE)') : tr('LONG PRESS DURATION', 'DURASI TAHAN SENTUHAN'),
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textSecondary, letterSpacing: 0.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.bgModeBox,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: t.borderPrimary),
                            ),
                            child: Text(
                              '$editedDuration ms',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stepper for duration
                      Row(
                        children: [
                          _buildDialogStepBtn('-100ms', () {
                            setDialogState(() => editedDuration = (editedDuration - 100).clamp(80, 5000));
                          }),
                          const SizedBox(width: 4),
                          _buildDialogStepBtn('-50ms', () {
                            setDialogState(() => editedDuration = (editedDuration - 50).clamp(80, 5000));
                          }),
                          const SizedBox(width: 4),
                          _buildDialogStepBtn('+50ms', () {
                            setDialogState(() => editedDuration = (editedDuration + 50).clamp(80, 5000));
                          }),
                          const SizedBox(width: 4),
                          _buildDialogStepBtn('+100ms', () {
                            setDialogState(() => editedDuration = (editedDuration + 100).clamp(80, 5000));
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Quick chips for duration
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (isSwipe ? [120, 180, 250, 350, 500] : [500, 1000, 1500, 2000, 3000]).map((dur) {
                          final isSel = editedDuration == dur;
                          final label = isSwipe
                              ? (dur <= 180 ? '${dur}ms (${tr("Fast", "Cepat")})' : (dur <= 300 ? '${dur}ms (${tr("Standard", "Standar")})' : '${dur}ms (${tr("Smooth", "Halus")})'))
                              : '${dur}ms';
                          return InkWell(
                            onTap: () => setDialogState(() => editedDuration = dur),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF238636) : t.bgSubCard,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isSel ? const Color(0xFF3FB950) : t.borderSecondary),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isSel ? Colors.white : t.textPrimary,
                                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Divider(height: 1, color: t.divider),
                    const SizedBox(height: 8),

                    // Test single step button directly on phone!
                    OutlinedButton.icon(
                      onPressed: () async {
                        final testStep = step.copyWith(
                          delayMs: editedDelay,
                          durationMs: editedDuration,
                          x: editedX,
                          y: editedY,
                          endX: editedEndX,
                          endY: editedEndY,
                        );
                        _testSingleStep(testStep);
                      },
                      icon: const Icon(Icons.play_circle_outline_rounded, size: 14, color: Color(0xFF58A6FF)),
                      label: Text(tr('Test This Step on Phone', 'Tes Langkah Ini Langsung di HP'), style: const TextStyle(fontSize: 10.5, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x6658A6FF)),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Cancel', 'Batal'), style: TextStyle(fontSize: 11, color: t.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      String updatedDesc = step.description;
                      if (step.action == 'long_press') {
                        updatedDesc = '${tr("Hold", "Tahan")} ($editedX, $editedY) ${editedDuration}ms';
                      }
                      _macroSteps[index] = step.copyWith(
                        delayMs: editedDelay,
                        durationMs: editedDuration,
                        x: editedX,
                        y: editedY,
                        endX: editedEndX,
                        endY: editedEndY,
                        description: updatedDesc,
                      );
                    });
                    Navigator.pop(ctx);
                    _showToast(tr('Step #${index + 1} updated (Delay: ${editedDelay}ms).', 'Langkah #${index + 1} diperbarui (Jeda: ${editedDelay}ms).'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: Text(tr('Save', 'Simpan'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MACRO STORAGE & PRESET COLLECTION
  // ==========================================

  Directory get _macroDirectory {
    final dir = Directory('$_userHomeDir/Documents/Scrcpy_Macros');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  List<SavedMacro> _loadAllSavedMacros() {
    final List<SavedMacro> list = [];
    try {
      final dir = _macroDirectory;
      final files = dir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.json')).toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      for (final f in files) {
        try {
          final content = f.readAsStringSync();
          final data = jsonDecode(content) as Map<String, dynamic>;
          list.add(SavedMacro.fromJson(data, f.path));
        } catch (_) {}
      }
    } catch (_) {}
    return list;
  }

  void _loadMacro(SavedMacro macro) {
    setState(() {
      _macroSteps.clear();
      _macroSteps.addAll(macro.steps);
      _macroLoopCount = macro.loopCount;
      _macroSpeed = macro.speed;
      _currentLoadedMacroName = macro.name;
    });
    _showToast(tr("Macro '${macro.name}' loaded (${macro.steps.length} steps)", "Makro '${macro.name}' dimuat (${macro.steps.length} langkah)"));
  }

  void _showSaveMacroDialog() {
    if (_macroSteps.isEmpty) {
      _showToast(tr('No recorded steps to save', 'Belum ada langkah yang direkam untuk disimpan'));
      return;
    }

    final initialName = _currentLoadedMacroName ?? '${tr('Macro', 'Makro')}_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().hour}${DateTime.now().minute}';
    final nameCtrl = TextEditingController(text: initialName);

    showDialog(
      context: context,
      builder: (ctx) {
        final t = PanelTheme(appThemeModeNotifier.value);
        return AlertDialog(
          backgroundColor: t.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: t.borderPrimary),
          ),
          titlePadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.activeCardBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.bookmark_add_rounded, size: 15, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
              ),
              const SizedBox(width: 7),
              Text(
                tr('Save Macro', 'Simpan Makro'),
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr('Name this macro so it is saved and can be reused anytime:', 'Beri nama makro ini agar tersimpan dan dapat digunakan kembali kapan saja:'),
                style: TextStyle(fontSize: 9.5, color: t.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: t.inputFill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.borderPrimary),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: TextStyle(fontSize: 11, color: t.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    hintText: tr('Macro Name...', 'Nama Makro...'),
                    hintStyle: TextStyle(fontSize: 11, color: t.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Ringkasan info makro
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.bgModeBox,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.borderPrimary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(tr('Steps', 'Langkah'), style: TextStyle(fontSize: 8.5, color: t.textSecondary)),
                        const SizedBox(height: 1),
                        Text('${_macroSteps.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.textPrimary)),
                      ],
                    ),
                    Container(width: 1, height: 18, color: t.divider),
                    Column(
                      children: [
                        Text(tr('Estimated', 'Estimasi'), style: TextStyle(fontSize: 8.5, color: t.textSecondary)),
                        const SizedBox(height: 1),
                        Text('${(_macroSteps.fold<int>(0, (acc, s) => acc + s.delayMs) / 1000).toStringAsFixed(1)}s/loop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.textPrimary)),
                      ],
                    ),
                    Container(width: 1, height: 18, color: t.divider),
                    Column(
                      children: [
                        Text(tr('Target Resolution', 'Resolusi Target'), style: TextStyle(fontSize: 8.5, color: t.textSecondary)),
                        const SizedBox(height: 1),
                        Text('${_deviceScreenWidth}x$_deviceScreenHeight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel', 'Batal'), style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
                final saved = SavedMacro(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  createdAt: DateTime.now().toIso8601String(),
                  loopCount: _macroLoopCount,
                  speed: _macroSpeed,
                  screenWidth: _deviceScreenWidth,
                  screenHeight: _deviceScreenHeight,
                  steps: List.from(_macroSteps),
                );

                try {
                  final file = File('${_macroDirectory.path}\\$safeName.json');
                  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(saved.toJson()));
                  setState(() => _currentLoadedMacroName = name);
                  Navigator.pop(ctx);
                  _showToast(tr("Macro '$name' saved successfully!", "Makro '$name' berhasil disimpan!"));
                } catch (e) {
                  _showToast(tr('Failed to save macro: $e', 'Gagal menyimpan makro: $e'));
                }
              },
              icon: const Icon(Icons.check_rounded, size: 14),
              label: Text(tr('Save', 'Simpan'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSavedMacrosDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final t = PanelTheme(appThemeModeNotifier.value);
            final macros = _loadAllSavedMacros();

            return AlertDialog(
              backgroundColor: t.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: t.borderPrimary),
              ),
              titlePadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              title: Row(
                children: [
                  Icon(Icons.folder_special_rounded, size: 16, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                  const SizedBox(width: 6),
                  Text(
                    tr('Macro Collection', 'Koleksi Makro'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.bgSubCard,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: t.borderSecondary),
                    ),
                    child: Text(
                      '${macros.length}',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: t.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: tr('Open Folder in File Explorer', 'Buka Folder di File Explorer'),
                    child: InkWell(
                      onTap: () {
                        _openFolderInFileManager(_macroDirectory.path);
                        _showToast(tr('Opening Scrcpy_Macros folder...', 'Membuka folder Scrcpy_Macros'));
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: t.bgModeBox,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: t.borderPrimary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 11, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                            const SizedBox(width: 3),
                            Text(
                              tr('Folder', 'Folder'),
                              style: TextStyle(fontSize: 8.5, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: macros.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 32, color: t.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              tr('No Saved Macros Yet', 'Belum Ada Makro Tersimpan'),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('Record taps and swipes on the mirrored phone,\nthen click "Save" to save it here.', 'Rekam ketukan dan usapan di cermin HP,\nlalu klik "Simpan" untuk menyimpannya di sini.'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9.5, color: t.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: macros.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 5),
                          itemBuilder: (context, i) {
                            final m = macros[i];
                            final isLoaded = _currentLoadedMacroName == m.name;

                            return Container(
                              padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                              decoration: BoxDecoration(
                                color: isLoaded ? t.activeCardBg : t.bgSubCard,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isLoaded
                                      ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                      : t.borderSecondary,
                                  width: isLoaded ? 1.2 : 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isLoaded
                                          ? const Color(0xFF2F81F7)
                                          : t.headerIconBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.smart_toy_outlined,
                                      size: 12,
                                      color: isLoaded ? Colors.white : t.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                m.name,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isLoaded) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0x263FB950),
                                                  borderRadius: BorderRadius.circular(3),
                                                  border: Border.all(color: const Color(0x593FB950), width: 0.7),
                                                ),
                                                child: Text(
                                                  tr('Active', 'Aktif'),
                                                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Color(0xFF3FB950)),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          '${m.steps.length} ${tr("Steps", "Langkah")} • ${m.loopCount == -1 ? "∞" : "${m.loopCount}x"} • ${m.speed}x',
                                          style: TextStyle(fontSize: 8, color: t.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Tombol Muat
                                  ElevatedButton(
                                    onPressed: () {
                                      _loadMacro(m);
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2F81F7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      elevation: 0,
                                    ),
                                    child: Text(tr('Use', 'Pakai'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 3),
                                  // Tombol Hapus
                                  InkWell(
                                    onTap: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          backgroundColor: t.bgCard,
                                          title: Text(tr('Delete Macro?', 'Hapus Makro?'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textPrimary)),
                                          content: Text(tr('Are you sure you want to delete "${m.name}"?', 'Apakah Anda yakin ingin menghapus "${m.name}"?'), style: TextStyle(fontSize: 10.5, color: t.textSecondary)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('Cancel', 'Batal'), style: TextStyle(fontSize: 11, color: t.textSecondary))),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(c, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDA3633), foregroundColor: Colors.white),
                                              child: Text(tr('Delete', 'Hapus'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          final f = File(m.filePath);
                                          if (f.existsSync()) f.deleteSync();
                                          if (_currentLoadedMacroName == m.name) {
                                            setState(() => _currentLoadedMacroName = null);
                                          }
                                          setDialogState(() {});
                                          _showToast(tr("Macro '${m.name}' has been deleted", "Makro '${m.name}' telah dihapus"));
                                        } catch (e) {
                                          _showToast(tr('Failed to delete: $e', 'Gagal menghapus: $e'));
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(3),
                                    child: const Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFF85149)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Close', 'Tutup'), style: TextStyle(fontSize: 11, color: t.textSecondary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickMacroForDevice(String serial) {
    final macros = _loadAllSavedMacros();
    if (macros.isEmpty) {
      _showToast(tr('No saved macros found. Record and save a macro first.', 'Belum ada makro tersimpan. Rekam dan simpan makro terlebih dahulu.'));
      return;
    }

    final runner = _multiDeviceRunners.putIfAbsent(serial, () => DeviceRunnerStatus(serial: serial));

    showDialog(
      context: context,
      builder: (ctx) {
        final t = PanelTheme(appThemeModeNotifier.value);
        return AlertDialog(
          backgroundColor: t.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: t.borderPrimary),
          ),
          titlePadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          title: Row(
            children: [
              Icon(Icons.bookmark_outline, size: 16, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tr('Select Macro for $serial', 'Pilih Makro untuk $serial'),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: macros.length,
                separatorBuilder: (_, _) => const SizedBox(height: 5),
                itemBuilder: (context, i) {
                  final m = macros[i];
                  final isAssigned = runner.assignedMacroName == m.name;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        runner.assignedMacroName = m.name;
                        runner.assignedMacro = m;
                        runner.loopCount = m.loopCount;
                        runner.speed = m.speed;
                      });
                      Navigator.pop(ctx);
                      _showToast(tr("Macro '${m.name}' selected for $serial", "Makro '${m.name}' dipilih untuk $serial"));
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: isAssigned ? t.activeCardBg : t.bgSubCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAssigned
                              ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                              : t.borderSecondary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.smart_toy_outlined, size: 14, color: isAssigned ? const Color(0xFF58A6FF) : t.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isAssigned ? (t.isDark ? Colors.white : const Color(0xFF0969DA)) : t.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${m.steps.length} ${tr("Steps", "Langkah")} • ${m.loopCount == -1 ? "∞" : "${m.loopCount}x"} • ${m.speed}x',
                                  style: TextStyle(fontSize: 8, color: t.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isAssigned)
                            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF3FB950)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Close', 'Tutup'), style: TextStyle(fontSize: 11, color: t.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  void _showBatchSyncDialog(List<DeviceInfo> devices) {
    final macros = _loadAllSavedMacros();

    int syncLoop = 1;
    double syncSpeed = 1.0;
    SavedMacro? syncMacro;

    showDialog(
      context: context,
      builder: (ctx) {
        final t = PanelTheme(appThemeModeNotifier.value);
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: t.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: t.borderPrimary),
              ),
              titlePadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              title: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16, color: t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tr('Sync Settings to All Devices', 'Samakan Setting ke Semua HP'),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tr('Apply loop, speed, or macro config to ${devices.length} devices at once.', 'Terapkan konfigurasi loop, kecepatan, atau makro ke ${devices.length} perangkat sekaligus.'),
                      style: TextStyle(fontSize: 9.5, color: t.textSecondary),
                    ),
                    const SizedBox(height: 10),

                    // Loop Selector
                    Text(tr('LOOP OPTIONS', 'PILIHAN LOOP'), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: t.textSecondary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [1, 2, 5, 10, -1].map((val) {
                        final isSelected = syncLoop == val;
                        return InkWell(
                          onTap: () => setDlgState(() => syncLoop = val),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? t.activeCardBg : t.bgSubCard,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                    : t.borderSecondary,
                              ),
                            ),
                            child: Text(
                              val == -1 ? tr('Loop Forever (∞)', 'Loop Terus (∞)') : '${val}x',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? (t.isDark ? Colors.white : const Color(0xFF0969DA)) : t.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Speed Selector
                    Text(tr('PLAYBACK SPEED', 'KECEPATAN PUTAR'), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: t.textSecondary)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [0.5, 1.0, 1.5, 2.0].map((val) {
                        final isSelected = (syncSpeed - val).abs() < 0.05;
                        return InkWell(
                          onTap: () => setDlgState(() => syncSpeed = val),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? t.activeCardBg : t.bgSubCard,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD29922)
                                    : t.borderSecondary,
                              ),
                            ),
                            child: Text(
                              '${val}x',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? (t.isDark ? const Color(0xFFF2CC60) : const Color(0xFF9E6A03))
                                    : t.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Optional Macro Assignment
                    if (macros.isNotEmpty) ...[
                      Text(tr('SYNC MACRO (OPTIONAL)', 'SAMAKAN MAKRO (OPSIONAL)'), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: t.textSecondary)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.bgSubCard,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: t.borderSecondary),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SavedMacro?>(
                            isExpanded: true,
                            value: syncMacro,
                            dropdownColor: t.bgCard,
                            hint: Text(tr('Keep Individual Macros', 'Biarkan Makro Masing-Masing'), style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                            items: [
                              DropdownMenuItem<SavedMacro?>(
                                value: null,
                                child: Text(tr('Keep Individual Macros', 'Biarkan Makro Masing-Masing'), style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                              ),
                              ...macros.map(
                                (m) => DropdownMenuItem<SavedMacro?>(
                                  value: m,
                                  child: Text(
                                    '${m.name} (${m.steps.length} ${tr("steps", "lkg")})',
                                    style: TextStyle(fontSize: 9.5, color: t.textPrimary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) => setDlgState(() => syncMacro = val),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Cancel', 'Batal'), style: TextStyle(fontSize: 10, color: t.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (final dev in devices) {
                        final runner = _multiDeviceRunners.putIfAbsent(dev.serial, () => DeviceRunnerStatus(serial: dev.serial));
                        runner.loopCount = syncLoop;
                        runner.speed = syncSpeed;
                        if (syncMacro != null) {
                          runner.assignedMacro = syncMacro;
                          runner.assignedMacroName = syncMacro!.name;
                        }
                      }
                    });
                    Navigator.pop(ctx);
                    _showToast(tr("Settings synced to ${devices.length} devices.", "Pengaturan disinkronkan ke ${devices.length} HP."));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: Text(tr('Apply to All', 'Terapkan ke Semua'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiDeviceRunnerView() {
    final t = PanelTheme(appThemeModeNotifier.value);
    final devices = _connectedDevicesList.isNotEmpty
        ? _connectedDevicesList
        : _connectedDevices.map((s) => DeviceInfo(serial: s, model: '', state: 'device', isWifi: s.contains(':'))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Master Control Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: devices.any((d) => _multiDeviceRunners[d.serial]?.assignedMacro != null)
                      ? _startAllMultiRunners
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 14),
                  label: Text(tr('Play All', 'Putar Semua'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: t.bgSubCard,
                    disabledForegroundColor: t.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: devices.any((d) => _multiDeviceRunners[d.serial]?.isRunning == true)
                      ? _stopAllMultiRunners
                      : null,
                  icon: const Icon(Icons.stop_rounded, size: 14),
                  label: Text(tr('Stop All', 'Stop Semua'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF85149),
                    side: const BorderSide(color: Color(0x66F85149)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Tooltip(
                message: tr('Open Macro Collection', 'Buka Koleksi Makro'),
                child: InkWell(
                  onTap: _showSavedMacrosDialog,
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: t.bgModeBox,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: t.borderPrimary),
                    ),
                    child: Icon(Icons.folder_open_rounded, size: 14, color: t.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Tooltip(
                message: tr('Sync Settings to All Devices', 'Samakan Setting ke Semua HP'),
                child: InkWell(
                  onTap: devices.isEmpty ? null : () => _showBatchSyncDialog(devices),
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: t.bgModeBox,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: t.borderPrimary),
                    ),
                    child: Icon(Icons.tune_rounded, size: 14, color: devices.isEmpty ? t.textSecondary : t.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Device List
        if (devices.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                Icon(Icons.devices_other_rounded, size: 28, color: t.textSecondary),
                const SizedBox(height: 8),
                Text(tr('No Devices Connected', 'Belum Ada Perangkat Terhubung'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  tr('Connect 2 or more devices via USB cable or enable Wireless ADB in Device Tab.', 'Sambungkan 2 atau lebih HP via kabel USB atau aktifkan Wireless ADB di Tab Device.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: t.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _checkAdbConnection,
                  icon: const Icon(Icons.refresh_rounded, size: 13),
                  label: Text(tr('Scan Devices', 'Pindai Perangkat'), style: const TextStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.textPrimary,
                    side: BorderSide(color: t.borderPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 7),
            itemBuilder: (context, idx) {
              final dev = devices[idx];
              final runner = _multiDeviceRunners.putIfAbsent(dev.serial, () => DeviceRunnerStatus(serial: dev.serial));
              final isMirroring = _activeScrcpyProcesses.containsKey(dev.serial) || (dev.serial == _selectedDeviceSerial && _scrcpyProcess != null);
              final isRunning = runner.isRunning;
              final hasMacro = runner.assignedMacro != null;

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isRunning
                        ? const Color(0xFF3FB950)
                        : (dev.serial == _selectedDeviceSerial ? const Color(0xFF58A6FF) : t.borderPrimary),
                    width: isRunning ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row: Icon, Device Name, Mirror Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                dev.isWifi ? Icons.wifi_rounded : Icons.usb_rounded,
                                size: 13,
                                color: isRunning
                                    ? const Color(0xFF3FB950)
                                    : (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA)),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  dev.displayName,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isMirroring ? const Color(0x263FB950) : t.bgSubCard,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: isMirroring ? const Color(0x663FB950) : t.borderSecondary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4.5,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isMirroring ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isMirroring ? tr('Mirror Active', 'Mirror Aktif') : 'Background',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w600,
                                  color: isMirroring ? const Color(0xFF3FB950) : t.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Macro Selector Card
                    InkWell(
                      onTap: isRunning ? null : () => _pickMacroForDevice(dev.serial),
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: t.bgModeBox,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: t.borderPrimary),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasMacro ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 12,
                              color: hasMacro ? const Color(0xFF58A6FF) : t.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                hasMacro
                                    ? '${runner.assignedMacroName!} (${runner.assignedMacro!.steps.length} ${tr("steps", "lkg")})'
                                    : tr('Select macro for this device...', 'Pilih Makro untuk HP ini...'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: hasMacro ? FontWeight.w600 : FontWeight.w400,
                                  color: hasMacro ? t.textPrimary : t.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isRunning)
                              Icon(Icons.arrow_drop_down_rounded, size: 15, color: t.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Quick-Tune Row (Loop & Speed per device)
                    if (hasMacro) ...[
                      Row(
                        children: [
                          // Loop Cycle Chip
                          Expanded(
                            child: Tooltip(
                              message: tr('Click to change loop cycle (1x, 2x, 5x, 10x, ∞)', 'Klik untuk ganti putaran (1x, 2x, 5x, 10x, ∞)'),
                              child: InkWell(
                                onTap: isRunning
                                    ? null
                                    : () {
                                        setState(() {
                                          const loopCycle = [1, 2, 5, 10, -1];
                                          int currIdx = loopCycle.indexOf(runner.loopCount);
                                          runner.loopCount = loopCycle[(currIdx + 1) % loopCycle.length];
                                        });
                                      },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: t.bgSubCard,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: runner.loopCount == -1
                                          ? const Color(0xFF58A6FF).withValues(alpha: 0.5)
                                          : t.borderSecondary,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 11,
                                        color: runner.loopCount == -1
                                            ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                            : t.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        runner.loopCount == -1 ? 'Loop: ∞' : 'Loop: ${runner.loopCount}x',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                          color: runner.loopCount == -1
                                              ? (t.isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                                              : t.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),

                          // Speed Cycle Chip
                          Expanded(
                            child: Tooltip(
                              message: tr('Click to change speed (0.5x, 1.0x, 1.5x, 2.0x)', 'Klik untuk ganti kecepatan (0.5x, 1.0x, 1.5x, 2.0x)'),
                              child: InkWell(
                                onTap: isRunning
                                    ? null
                                    : () {
                                        setState(() {
                                          const speedCycle = [1.0, 1.5, 2.0, 0.5];
                                          int currIdx = speedCycle.indexOf(runner.speed);
                                          runner.speed = speedCycle[(currIdx + 1) % speedCycle.length];
                                        });
                                      },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: t.bgSubCard,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: runner.speed > 1.0
                                          ? const Color(0xFFD29922).withValues(alpha: 0.5)
                                          : t.borderSecondary,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 11,
                                        color: runner.speed > 1.0
                                            ? const Color(0xFFD29922)
                                            : t.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Speed: ${runner.speed}x',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                          color: runner.speed > 1.0
                                              ? (t.isDark ? const Color(0xFFF2CC60) : const Color(0xFF9E6A03))
                                              : t.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Revert to macro defaults button (if modified)
                          if (!isRunning &&
                              (runner.loopCount != runner.assignedMacro!.loopCount ||
                                  (runner.speed - runner.assignedMacro!.speed).abs() > 0.01)) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: tr('Reset to macro default (${runner.assignedMacro!.loopCount == -1 ? "∞" : "${runner.assignedMacro!.loopCount}x"}, ${runner.assignedMacro!.speed}x)', 'Kembalikan ke setting asli makro (${runner.assignedMacro!.loopCount == -1 ? "∞" : "${runner.assignedMacro!.loopCount}x"}, ${runner.assignedMacro!.speed}x)'),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    runner.loopCount = runner.assignedMacro!.loopCount;
                                    runner.speed = runner.assignedMacro!.speed;
                                  });
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: t.bgSubCard,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: t.borderSecondary),
                                  ),
                                  child: Icon(Icons.restore_rounded, size: 12, color: t.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],

                    // Running Status & Individual Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isRunning
                                ? tr('Playing • Loop ${runner.currentLoop}/${runner.loopCount == -1 ? "∞" : runner.loopCount} • Step ${runner.currentStep + 1}/${runner.assignedMacro?.steps.length}', 'Memutar • Loop ${runner.currentLoop}/${runner.loopCount == -1 ? "∞" : runner.loopCount} • Step ${runner.currentStep + 1}/${runner.assignedMacro?.steps.length}')
                                : (hasMacro ? tr('Ready to play', 'Siap diputar') : tr('Select a macro to start', 'Pilih makro untuk memulai')),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: isRunning ? FontWeight.w600 : FontWeight.w400,
                              color: isRunning
                                  ? (t.isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37))
                                  : t.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: isRunning
                              ? () => _stopMultiRunner(dev.serial)
                              : (hasMacro ? () => _startMultiRunner(dev.serial) : null),
                          icon: Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 12),
                          label: Text(isRunning ? 'Stop' : tr('Play', 'Putar'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRunning ? const Color(0xFFDA3633) : const Color(0xFF238636),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: t.bgSubCard,
                            disabledForegroundColor: t.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTabPerangkat(bool isConnected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header & Tombol Pindai
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('DEVICE LIST (${_connectedDevicesList.length})', 'DAFTAR PERANGKAT (${_connectedDevicesList.length})'),
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.textSecondary, letterSpacing: 0.5),
            ),
            InkWell(
              onTap: _checkAdbConnection,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.refresh_outlined, size: 11, color: Color(0xFF58A6FF)),
                    const SizedBox(width: 3),
                    Text(tr('Rescan', 'Pindai Ulang'), style: const TextStyle(fontSize: 10, color: Color(0xFF58A6FF), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tata Letak Multi-Device (Grid Adaptif vs Berdampingan)
        if (_connectedDevicesList.length > 1 || _activeScrcpyProcesses.length > 1) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.bgModeBox,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _multiWindowLayout = 'grid');
                      _syncScrcpyToPanel();
                      _showToast(tr('Adaptive Grid active (auto-fit on screen)', 'Mode Grid Adaptif aktif (otomatis pas di layar)'));
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _multiWindowLayout == 'grid' ? const Color(0xFF2F81F7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_view_rounded, size: 11, color: _multiWindowLayout == 'grid' ? Colors.white : t.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            tr('Adaptive Grid', 'Grid Adaptif'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: _multiWindowLayout == 'grid' ? FontWeight.bold : FontWeight.w400,
                              color: _multiWindowLayout == 'grid' ? Colors.white : t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _multiWindowLayout = 'horizontal');
                      _syncScrcpyToPanel();
                      _showToast(tr('Side by Side active', 'Mode Berdampingan aktif'));
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _multiWindowLayout == 'horizontal' ? const Color(0xFF2F81F7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_column_rounded, size: 11, color: _multiWindowLayout == 'horizontal' ? Colors.white : t.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            tr('Side by Side', 'Berdampingan'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: _multiWindowLayout == 'horizontal' ? FontWeight.bold : FontWeight.w400,
                              color: _multiWindowLayout == 'horizontal' ? Colors.white : t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    _snapAllActiveWindowsToAspectRatio(force: true);
                    _syncScrcpyToPanel();
                    _showToast(tr('Windows aligned & snapped cleanly', 'Jendela dirapikan & area hitam dipangkas pas'));
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.bgButton,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: t.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_fix_high_rounded, size: 11, color: Color(0xFF58A6FF)),
                        const SizedBox(width: 2),
                        Text(tr('Auto Align', 'Rapikan'), style: const TextStyle(fontSize: 9, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_connectedDevicesList.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.borderPrimary),
            ),
            child: Column(
              children: [
                const Icon(Icons.phonelink_erase_outlined, size: 28, color: Color(0xFF6E7681)),
                const SizedBox(height: 6),
                Text(tr('No Devices Detected', 'Tidak Ada Perangkat Terdeteksi'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 3),
                Text(tr('Connect via USB cable or Wi-Fi to list devices.', 'Colokkan kabel USB atau hubungkan via Wi-Fi untuk menampilkan daftar HP.'), textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: t.textSecondary)),
              ],
            ),
          )
        else
          ..._connectedDevicesList.map((dev) {
            final isSelected = dev.serial == _selectedDeviceSerial;
            final isOnline = dev.state == 'device';
            final isMirroringThis = _activeScrcpyProcesses.containsKey(dev.serial) || (isSelected && _scrcpyProcess != null);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? t.activeCardBg : t.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2F81F7) : t.borderPrimary,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        dev.isWifi ? Icons.wifi_outlined : Icons.usb_outlined,
                        size: 16,
                        color: isSelected ? const Color(0xFF0969DA) : t.textSecondary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.model.isNotEmpty ? dev.model : dev.serial,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? (_isDarkMode ? Colors.white : const Color(0xFF0969DA)) : t.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${dev.serial} - ${dev.isWifi ? tr("Wireless (Wi-Fi)", "Nirkabel (Wi-Fi)") : tr("USB Cable", "Kabel USB")}',
                              style: TextStyle(fontSize: 9.5, color: t.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (isMirroringThis) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x263FB950),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0x663FB950)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.screen_share_rounded, size: 9.5, color: Color(0xFF3FB950)),
                              const SizedBox(width: 3),
                              Text(
                                tr('Mirror Active', 'Mirror Aktif'),
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF3FB950)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0x26238636) : const Color(0x26DA3633),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isOnline ? const Color(0x663FB950) : const Color(0x66F85149)),
                        ),
                        child: Text(
                          isOnline ? 'Online' : dev.state,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isOnline ? const Color(0xFF3FB950) : const Color(0xFFF85149)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedDeviceSerial = dev.serial;
                              _connectedDeviceName = dev.model.isNotEmpty ? dev.model : dev.serial;
                            });
                            _showToast(tr('Navigation target changed to: ${dev.displayName}', 'Target navigasi diubah ke: ${dev.displayName}'));
                          },
                          icon: Icon(
                            isSelected ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_outlined,
                            size: 13,
                            color: isSelected ? const Color(0xFF3FB950) : const Color(0xFF8B949E),
                          ),
                          label: Text(
                            isSelected ? tr('Active Target', 'Target Aktif') : tr('Select Target', 'Pilih Target'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? const Color(0xFF3FB950) : const Color(0xFFC9D1D9),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            side: BorderSide(color: isSelected ? const Color(0xFF3FB950) : const Color(0xFF30363D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isOnline ? () => _toggleMirrorSingleDevice(dev.serial) : null,
                          icon: Icon(
                            isMirroringThis ? Icons.stop_circle_outlined : Icons.screen_share_outlined,
                            size: 13,
                            color: Colors.white,
                          ),
                          label: Text(
                            isMirroringThis ? tr('Stop Mirror', 'Stop Mirror') : tr('Mirror Device', 'Mirror HP Ini'),
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMirroringThis ? const Color(0xFFDA3633) : const Color(0xFF238636),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

        if (_connectedDevicesList.length > 1) ...[
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed: _startMultiMirroringAll,
            icon: const Icon(Icons.splitscreen_outlined, size: 15, color: Colors.white),
            label: Text(
              tr('Mirror All Devices (Multi-Window)', 'Mirror Semua HP Bersamaan (Multi-Window)'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F6FEB),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 6),
          if (_activeScrcpyProcesses.isNotEmpty)
            OutlinedButton.icon(
              onPressed: _stopAllMirroring,
              icon: const Icon(Icons.close_outlined, size: 14, color: Color(0xFFF85149)),
              label: Text(
                tr('Close All Mirror Windows', 'Tutup Semua Jendela Mirroring'),
                style: const TextStyle(fontSize: 10.5, color: Color(0xFFF85149)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x66F85149)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          const SizedBox(height: 8),
        ],

        // 2. Modul Pusat Sambungan Wi-Fi & Nirkabel
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.borderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isWifiConnected ? const Color(0x2E3FB950) : const Color(0x2E2F81F7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _isWifiConnected ? Icons.wifi_outlined : Icons.wifi_tethering_outlined,
                      size: 18,
                      color: _isWifiConnected ? const Color(0xFF3FB950) : const Color(0xFF58A6FF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWifiConnected ? tr('Wi-Fi Mode Active', 'Mode Wi-Fi Aktif') : tr('Wi-Fi Connection Hub', 'Pusat Sambungan Wi-Fi'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
                        ),
                        Text(
                          _isWifiConnected
                              ? tr('Connected to ${_deviceIp.isNotEmpty ? _deviceIp : "Phone"}:5555', 'Tersambung ke ${_deviceIp.isNotEmpty ? _deviceIp : "HP"}:5555')
                              : tr('4 Connection Methods & Network Diagnostics', '4 Metode Koneksi & Diagnosis Jaringan'),
                          style: TextStyle(
                            fontSize: 10,
                            color: _isWifiConnected ? const Color(0xFF3FB950) : t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh_outlined, size: 14, color: t.textSecondary),
                    tooltip: tr('Refresh Network Info', 'Segarkan Info Jaringan'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _detectNetworkInfo();
                      _checkAdbConnection();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Kartu Diagnostik IP PC vs HP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: t.bgSubCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.borderSecondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.computer_outlined, size: 12, color: t.textSecondary),
                        const SizedBox(width: 4),
                        Text('PC: ', style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                        Expanded(
                          child: Text(
                            _pcLocalIp.isNotEmpty ? _pcLocalIp : tr('Checking...', 'Memeriksa...'),
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: t.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.phone_android_outlined, size: 12, color: t.textSecondary),
                        const SizedBox(width: 4),
                        Text('HP: ', style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                        Expanded(
                          child: Text(
                            _deviceIp.isNotEmpty
                                ? '$_deviceIp${_deviceSsid.isNotEmpty ? " ($_deviceSsid)" : ""}'
                                : tr('Not detected yet', 'Belum terdeteksi'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: _deviceIp.isNotEmpty ? const Color(0xFF0969DA) : t.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_pcLocalIp.isNotEmpty && _deviceIp.isNotEmpty && !_isSameSubnet(_pcLocalIp, _deviceIp)) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0x1AD29922),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0x66D29922)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFE3B341)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tr(
                                  'Different Subnet: PC ($_pcLocalIp) & Phone ($_deviceIp). Connect phone to the same Wi-Fi as PC (or use Phone/PC Hotspot) to open ports.',
                                  'Beda Subnet Jaringan: PC ($_pcLocalIp) dan HP ($_deviceIp). Sambungkan HP ke Wi-Fi yang sama dengan PC (atau gunakan Hotspot HP/PC) agar port terbuka.',
                                ),
                                style: const TextStyle(fontSize: 9, color: Color(0xFFE3B341), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Pesan Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: t.bgSubCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.borderSecondary),
                ),
                child: Text(
                  _wifiStatusMsg,
                  style: TextStyle(fontSize: 9.5, color: t.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(height: 10),

              if (_isWifiConnected) ...[
                // Jika sudah terkoneksi
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF85149),
                      side: const BorderSide(color: Color(0xFFF85149)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _disconnectWifi(),
                    icon: const Icon(Icons.wifi_off_outlined, size: 15),
                    label: Text(tr('Disconnect Wi-Fi', 'Putuskan Wi-Fi'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // Pilihan Jalur Koneksi (5 Tabs)
                Row(
                  children: [
                    _buildWifiTabChip(0, tr('QR Code', 'Kode QR')),
                    const SizedBox(width: 4),
                    _buildWifiTabChip(1, 'Auto USB'),
                    const SizedBox(width: 4),
                    _buildWifiTabChip(2, 'Pair A11+'),
                    const SizedBox(width: 4),
                    _buildWifiTabChip(3, 'Manual IP'),
                    const SizedBox(width: 4),
                    _buildWifiTabChip(4, 'Scan Net'),
                  ],
                ),
                const SizedBox(height: 10),

                // Konten per Tab
                if (_wirelessMethodTab == 0) ...[
                  // TAB 0: Pasangkan Otomatis via Kode QR (Android 11+)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.bgSubCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: t.borderSecondary),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tr('On phone: Developer Options > Wireless Debugging > "Pair device with QR code", then scan this code:', 'Buka HP: Opsi Pengembang > Debugging Nirkabel > "Pasangkan perangkat dengan kode QR", lalu scan kode ini:'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9.5, color: t.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 10),

                        // QR Code Card
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: QrImageView(
                            data: _qrPairingPayload.isNotEmpty
                                ? _qrPairingPayload
                                : 'WIFI:T:ADB;S:ScrcpyDock;P:123456;;',
                            version: QrVersions.auto,
                            size: 130.0,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(2),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // PIN & Acak Ulang Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: t.bgCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: t.borderPrimary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.key_outlined, size: 13, color: Color(0xFF58A6FF)),
                              const SizedBox(width: 5),
                              Text(
                                'PIN: $_qrPairingPassword',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: t.textPrimary, letterSpacing: 0.5),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _generateQrPairingData();
                                    _startQrPairingListener();
                                  });
                                  _showToast(_isIndonesian ? 'Kode QR & PIN baru dibuat!' : 'New QR Code & PIN generated!');
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.refresh_rounded, size: 12, color: Color(0xFF58A6FF)),
                                      const SizedBox(width: 2),
                                      Text(tr('Randomize PIN', 'Acak PIN'), style: const TextStyle(fontSize: 9.5, color: Color(0xFF58A6FF), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status Pemindaian Realtime
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.bgCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _isQrPairingActive ? const Color(0x662F81F7) : t.borderPrimary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isQrPairingActive) ...[
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(strokeWidth: 1.8, color: Color(0xFF58A6FF)),
                                ),
                                const SizedBox(width: 7),
                              ],
                              Flexible(
                                child: Text(
                                  _qrPairingStatus,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: _qrPairingStatus.contains('Sukses') || _qrPairingStatus.contains('Berhasil') || _qrPairingStatus.contains('Success')
                                        ? const Color(0xFF3FB950)
                                        : t.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_wirelessMethodTab == 1) ...[
                  // TAB 1: Otomatis USB Helper
                  Text(
                    tr(
                      '1. Connect USB cable to Phone & PC.\n2. Click button below to enable port 5555.\n3. After success status, USB cable can be disconnected!',
                      '1. Colokkan kabel USB ke HP & PC.\n2. Klik tombol di bawah untuk mengaktifkan port 5555.\n3. Setelah status sukses, kabel USB bisa dicabut!',
                    ),
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF8B949E), height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F81F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: _isConnectingWifi ? null : _connectWifiWireless,
                      icon: _isConnectingWifi
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.wifi_find_outlined, size: 15),
                      label: Text(
                        _isConnectingWifi ? tr('Connecting...', 'Menyambungkan...') : tr('Enable Wi-Fi (1-Click)', 'Aktifkan Wi-Fi (1-Klik)'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ] else if (_wirelessMethodTab == 2) ...[
                  // TAB 2: Android 11+ Pairing Nirkabel (Tanpa Kabel USB)
                  Text(
                    tr(
                      'Official Android 11+ feature: On phone, open Developer Options > Wireless Debugging > "Pair device with pairing code".',
                      'Fitur resmi Android 11+: Di HP, buka Opsi Pengembang > Debugging Nirkabel > "Pasangkan perangkat dengan kode penyambungan".',
                    ),
                    style: TextStyle(fontSize: 9, color: t.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pairingHostController,
                          style: TextStyle(fontSize: 10.5, color: t.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: tr('Pairing IP:Port (e.g. 192.168.0.132:38921)', 'IP:Port Pairing (cth: 192.168.0.132:38921)'),
                            hintStyle: TextStyle(fontSize: 9, color: t.textMuted),
                            filled: true,
                            fillColor: t.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: t.borderSecondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _pairingCodeController,
                          style: TextStyle(fontSize: 10.5, color: t.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: tr('6-Digit Code', 'Kode 6-Digit'),
                            hintStyle: TextStyle(fontSize: 9, color: t.textMuted),
                            filled: true,
                            fillColor: t.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: t.borderSecondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pairingConnectPortController,
                    style: TextStyle(fontSize: 10.5, color: t.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr('Main Connect Port (optional, e.g. 41235)', 'Port Sambungan Utama (opsional, cth: 41235)'),
                      hintStyle: TextStyle(fontSize: 9, color: t.textMuted),
                      filled: true,
                      fillColor: t.inputFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: t.borderSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F6FEB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: _isConnectingWifi ? null : _pairAndConnectWireless,
                      icon: _isConnectingWifi
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.qr_code_scanner_outlined, size: 15),
                      label: Text(
                        _isConnectingWifi ? tr('Processing...', 'Memproses...') : tr('Pair & Connect', 'Pasangkan & Sambungkan'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ] else if (_wirelessMethodTab == 3) ...[
                  // TAB 3: Input Manual IP & Port
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualIpController,
                          style: TextStyle(fontSize: 10.5, color: t.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: tr('Phone IP (e.g. 192.168.0.132)', 'IP HP (cth: 192.168.0.132)'),
                            hintStyle: TextStyle(fontSize: 9.5, color: t.textMuted),
                            filled: true,
                            fillColor: t.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: t.borderSecondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 65,
                        child: TextField(
                          controller: _manualPortController,
                          style: TextStyle(fontSize: 10.5, color: t.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '5555',
                            hintStyle: TextStyle(fontSize: 9.5, color: t.textMuted),
                            filled: true,
                            fillColor: t.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: t.borderSecondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFF58A6FF)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: _isConnectingWifi ? null : _connectManualWifi,
                      icon: _isConnectingWifi
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.link_outlined, size: 15),
                      label: Text(
                        _isConnectingWifi ? tr('Connecting...', 'Menghubungkan...') : tr('Connect to this IP', 'Sambungkan ke IP Ini'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ] else if (_wirelessMethodTab == 4) ...[
                  // TAB 4: Pindai Jaringan (Scan mDNS & Port 5555)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDarkMode ? const Color(0xFF21262D) : t.bgButton,
                        foregroundColor: const Color(0xFF0969DA),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: t.borderSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      onPressed: _isScanningWifi ? null : _scanWifiNetwork,
                      icon: _isScanningWifi
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF58A6FF)),
                            )
                          : const Icon(Icons.radar_outlined, size: 15),
                      label: Text(
                        _isScanningWifi ? tr('Scanning Network...', 'Memindai Jaringan...') : tr('Scan Devices (mDNS & Port)', 'Pindai Perangkat (mDNS & Port)'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (_discoveredDevices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._discoveredDevices.map((d) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.bgSubCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: t.borderSecondary),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_outlined, size: 14, color: Color(0xFF3FB950)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['address'] ?? '',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final rawName = d['name'] ?? '';
                                      final nameStr = (rawName == 'Perangkat Port 5555' || rawName == 'Device Port 5555')
                                          ? tr('Device Port 5555', 'Perangkat Port 5555')
                                          : rawName;
                                      return Text(
                                        '$nameStr (${d['type']})',
                                        style: TextStyle(fontSize: 8.5, color: t.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                final addr = d['address'] ?? '';
                                if (addr.isNotEmpty) {
                                  final parts = addr.split(':');
                                  _manualIpController.text = parts.first;
                                  if (parts.length > 1) _manualPortController.text = parts[1];
                                  _connectManualWifi();
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF238636),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(tr('Connect', 'Hubungkan'), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      tr(
                        'Auto scan detects devices with Wireless Debugging (mDNS) enabled or open port 5555 on local network.',
                        'Pindai otomatis mendeteksi perangkat yang mengaktifkan Wireless Debugging (mDNS) atau membuka port 5555 di jaringan lokal.',
                      ),
                      style: TextStyle(fontSize: 9, color: t.textSecondary, height: 1.3),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 3. Tips Praktis Jaringan & Hotspot
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: t.bgSubCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.borderSecondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Quick Wi-Fi Troubleshooting (Different Subnet / Office / Dorm):', 'Solusi Cepat Kendala Wi-Fi (Beda Jaringan / Kos / Kantor):'),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                tr(
                  '• Use Phone Hotspot: Turn on Personal Hotspot on phone and connect PC to it (100% guaranteed same IP subnet & bypasses router AP isolation).\n• Check Wi-Fi: If PC uses LAN cable to the main router (192.168.100.x), ensure phone connects to that same router Wi-Fi, not a secondary router on a different subnet.',
                  '• Gunakan Hotspot HP: Nyalakan Hotspot di HP, lalu sambungkan PC ke Hotspot tersebut (100% dijamin satu segmen IP & anti-blokir router).\n• Periksa Wi-Fi: Jika PC tercolok kabel LAN ke Modem utama (192.168.100.x), pastikan HP terhubung ke Wi-Fi modem tersebut, bukan router tambahan yang berbeda subnet.',
                ),
                style: TextStyle(fontSize: 9.5, color: t.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWifiTabChip(int index, String label) {
    final isSel = _wirelessMethodTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _wirelessMethodTab = index;
            if (index == 0) {
              _startQrPairingListener();
            } else {
              _stopQrPairingListener();
            }
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF2F81F7) : t.bgSubCard,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isSel ? const Color(0xFF2F81F7) : t.borderSecondary),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              color: isSel ? Colors.white : t.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // TAB 5: TENTANG / ABOUT (CLEAN MINIMALIST DESIGN - ESCRCPY STYLE)
  Widget _buildTabAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),

        // App Icon (Displayed as-is without cropping)
        Center(
          child: Image.asset(
            'assets/icon.png',
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.phone_android_rounded,
              size: 40,
              color: Color(0xFF238636),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title & Version
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ScrcpyDock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: t.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: t.bgButton,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: t.borderSubtle),
              ),
              child: Text(
                'v1.0.0',
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: t.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Italic Description (Directly inspired by escrcpy)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Display and control your Android device graphically with scrcpy, powered by Flutter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Action Buttons Row (escrcpy-style)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _openRecordingsFolder,
              icon: const Icon(Icons.video_library_outlined, size: 13),
              label: Text(tr('Recordings', 'Rekaman'), style: const TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.textPrimary,
                side: BorderSide(color: t.borderSecondary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _openScreenshotFolder,
              icon: const Icon(Icons.photo_camera_outlined, size: 13),
              label: Text(tr('Screenshots', 'Foto'), style: const TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.textPrimary,
                side: BorderSide(color: t.borderSecondary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _showDonateDialog,
              icon: const Icon(Icons.favorite_rounded, size: 13),
              label: Text(tr('Donate', 'Donasi'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5534B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Secondary Link (Folder Makro)
        Center(
          child: TextButton.icon(
            onPressed: () => _openFolderInFileManager(_macroDirectory.path),
            icon: Icon(Icons.bookmark_border_rounded, size: 12, color: t.textSecondary),
            label: Text(
              tr('Open Macro Folder', 'Buka Folder Makro'),
              style: TextStyle(fontSize: 9, color: t.textSecondary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: () => _showEngineMissingDialog(),
            icon: Icon(Icons.terminal_rounded, size: 12, color: t.textSecondary),
            label: Text(
              tr('Scrcpy & ADB Engine Setup', 'Panduan Engine Scrcpy & ADB'),
              style: TextStyle(fontSize: 9, color: t.textSecondary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Subtle Minimal Footer
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text(
            'Scrcpy & Android ADB • Powered by Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: t.textMuted),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
