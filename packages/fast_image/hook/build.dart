import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:fast_image/src/hook/download_asset.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;
    final iOSSdk = targetOS == OS.iOS ? input.config.code.iOS.targetSdk : null;
    final outputDirectory = Directory.fromUri(input.outputDirectory);
    final file = await downloadAsset(targetOS, targetArchitecture, iOSSdk, outputDirectory);

    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'fast_image.dart',
        linkMode: DynamicLoadingBundled(),
        file: file.uri,
      ),
    );
  });
}
