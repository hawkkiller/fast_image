import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:fast_image/src/hook/download_asset.dart';
import 'package:fast_image/src/hook/hashes.dart';
import 'package:fast_image/src/hook/local_build.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // Skip for web - code config throws on web platform
    final CodeConfig? codeConfig;
    try {
      codeConfig = input.config.code;
    } catch (_) {
      return; // Web platform - no native assets needed
    }
    if (codeConfig == null) return;

    final localBuild = input.userDefines['local_build'] as bool? ?? false;

    if (localBuild) {
      return runLocalBuild(input, output);
    }

    final targetOS = codeConfig.targetOS;
    final targetArchitecture = codeConfig.targetArchitecture;
    final iOSSdk = targetOS == OS.iOS ? codeConfig.iOS.targetSdk : null;
    final outputDirectory = Directory.fromUri(input.outputDirectory);
    final file = await downloadAsset(
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
      iOSSdk: iOSSdk,
      outputDirectory: outputDirectory,
    );

    await verifyAssetHash(
      file,
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
      iOSSdk: iOSSdk,
    );

    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'src/bindings/bindings.dart',
        linkMode: DynamicLoadingBundled(),
        file: file.uri,
      ),
    );
  });
}

Future<void> verifyAssetHash(
  File asset, {
  required OS targetOS,
  required Architecture targetArchitecture,
  required IOSSdk? iOSSdk,
}) async {
  final hash = await hashAsset(asset);
  final targetName = targetOS.dylibFileName(createTargetName(targetOS, targetArchitecture, iOSSdk));
  final expectedHash = assetHashes[targetName];

  if (hash != expectedHash) {
    throw Exception('Asset hash mismatch: $hash != $expectedHash');
  }
}
