import 'dart:io';

import 'package:code_assets/code_assets.dart';

CCompilerConfig getAndroidCompilerConfig(Architecture architecture) {
  // Get NDK path from environment or default location
  final ndkPath =
      Platform.environment['ANDROID_NDK_ROOT'] ?? Platform.environment['ANDROID_NDK_HOME'];

  if (ndkPath == null) {
    throw Exception('ANDROID_NDK_ROOT or ANDROID_NDK_HOME environment variable must be set');
  }

  final ndkDir = Directory(ndkPath);
  if (!ndkDir.existsSync()) {
    throw Exception('Android NDK not found at: $ndkPath');
  }

  // Determine the target triple based on architecture
  final targetTriple = switch (architecture) {
    Architecture.arm => 'armv7a-linux-androideabi',
    Architecture.arm64 => 'aarch64-linux-android',
    Architecture.x64 => 'x86_64-linux-android',
    Architecture.ia32 => 'i686-linux-android',
    _ => throw UnsupportedError('Unsupported Android architecture: $architecture'),
  };

  // API level 35 (as used in the reference code)
  const apiLevel = '35';

  // Construct paths to NDK toolchain binaries
  final toolchainPath = Uri.directory('$ndkPath/toolchains/llvm/prebuilt/');
  final hostTag = _getHostTag();
  final binPath = toolchainPath.resolve('$hostTag/bin/');

  final compilerExt = Platform.isWindows ? '.cmd' : '';
  final compiler = binPath.resolve('$targetTriple$apiLevel-clang$compilerExt');
  final archiver = binPath.resolve('llvm-ar$compilerExt');

  // Verify the binaries exist
  if (!File.fromUri(compiler).existsSync()) {
    throw Exception('Compiler not found at: $compiler');
  }
  if (!File.fromUri(archiver).existsSync()) {
    throw Exception('Archiver not found at: $archiver');
  }

  return CCompilerConfig(compiler: compiler, archiver: archiver, linker: compiler);
}

String _getHostTag() {
  if (Platform.isLinux) return 'linux-x86_64';
  if (Platform.isMacOS) return 'darwin-x86_64';
  if (Platform.isWindows) return 'windows-x86_64';
  throw UnsupportedError('Unsupported host platform: ${Platform.operatingSystem}');
}
