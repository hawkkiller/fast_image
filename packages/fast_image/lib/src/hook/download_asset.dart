import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:fast_image/src/hook/version.dart';

Uri downloadUri(String target) => Uri.parse(
  'https://github.com/hawkkiller/fast_image/releases/tag/$version/$target',
);

/// Downloads the asset for the given target OS and architecture.
Future<File> downloadAsset(
  OS targetOS,
  Architecture targetArchitecture,
  IOSSdk? iOSSdk,
  Directory outputDirectory,
) async {
  final targetName = targetOS.dylibFileName(
    createTargetName(targetOS.name, targetArchitecture.name, iOSSdk?.type),
  );

  final uri = downloadUri(targetName);
  final request = await HttpClient().getUrl(uri);
  final response = await request.close();
  if (response.statusCode != 200) {
    throw ArgumentError('The request to $uri failed.');
  }

  final library = File.fromUri(outputDirectory.uri.resolve(targetName));
  await library.create();
  await response.pipe(library.openWrite());
  return library;
}

String createTargetName(String targetOS, String targetArchitecture, String? iOSSdk) {
  return '$targetOS-$targetArchitecture';
}

/// Computes the MD5 hash of the given [assetFile].
Future<String> hashAsset(File assetFile) async {
  final fileHash = md5.convert(await assetFile.readAsBytes()).toString();
  return fileHash;
}
