import 'dart:io';

import 'package:code_assets/code_assets.dart';

Future<File> downloadAsset(
  OS targetOS,
  Architecture targetArchitecture,
  IOSSdk? iOSSdk,
  Directory outputDirectory,
) async {
  final targetName = targetOS.dylibFileName(
    createTargetName(targetOS.name, targetArchitecture.name, iOSSdk?.type),
  );

  final file = File.fromUri(outputDirectory.uri.resolve(targetName));
  await file.create();

  return file;
}

String createTargetName(String targetOS, String targetArchitecture, String? iOSSdk) {
  return '$targetOS-$targetArchitecture';
}
