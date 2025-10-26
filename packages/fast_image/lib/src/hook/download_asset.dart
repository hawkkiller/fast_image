import 'dart:io';

import 'package:code_assets/code_assets.dart';

Uri downloadUri(String target) => Uri.parse(
  'https://raw.githubusercontent.com/hawkkiller/fast_image/main/packages/fast_image/assets/libs/$target',
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
