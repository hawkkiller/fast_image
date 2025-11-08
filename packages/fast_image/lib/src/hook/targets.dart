import 'package:code_assets/code_assets.dart';

typedef SupportedTarget = (OS os, Architecture architecture, IOSSdk? iOSSdk);

/// A list of supported target combinations of OS, architecture, and iOS SDK.
///
/// Used to determine which assets to download or build.
const supportedTargets = <SupportedTarget>[
  (OS.android, Architecture.arm, null),
  (OS.android, Architecture.arm64, null),
  (OS.android, Architecture.x64, null),
  (OS.iOS, Architecture.arm64, IOSSdk.iPhoneOS),
  (OS.iOS, Architecture.arm64, IOSSdk.iPhoneSimulator),
  (OS.iOS, Architecture.x64, IOSSdk.iPhoneSimulator),
  (OS.linux, Architecture.arm64, null),
  (OS.linux, Architecture.x64, null),
  (OS.macOS, Architecture.arm64, null),
  (OS.macOS, Architecture.x64, null),
  (OS.windows, Architecture.arm64, null),
  (OS.windows, Architecture.x64, null),
];

String getNameForTarget(OS os, Architecture architecture, IOSSdk? iOSSdk) {
  switch ((os, architecture, iOSSdk)) {
    case (OS.android, Architecture.arm, null):
      return 'android_armv7';
    case (OS.android, Architecture.arm64, null):
      return 'android_arm64';
    case (OS.android, Architecture.x64, null):
      return 'android_x86_64';
    case (OS.iOS, Architecture.arm64, IOSSdk.iPhoneOS):
      return 'ios_arm64';
    case (OS.iOS, Architecture.arm64, IOSSdk.iPhoneSimulator):
      return 'ios_sim_arm64';
    case (OS.iOS, Architecture.x64, IOSSdk.iPhoneSimulator):
      return 'ios_sim_x86_64';
    case (OS.linux, Architecture.arm64, null):
      return 'linux_aarch64';
    case (OS.linux, Architecture.x64, null):
      return 'linux_x86_64';
    case (OS.macOS, Architecture.arm64, null):
      return 'macos_arm64';
    case (OS.macOS, Architecture.x64, null):
      return 'macos_x86_64';
    case (OS.windows, Architecture.arm64, null):
      return 'windows_arm64';
    case (OS.windows, Architecture.x64, null):
      return 'windows_x86_64';
  }

  throw UnimplementedError('Unsupported target: $os $architecture $iOSSdk');
}
