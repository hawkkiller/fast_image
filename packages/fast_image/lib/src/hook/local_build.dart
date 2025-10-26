import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rs/native_toolchain_rs.dart';

Future<void> runLocalBuild(BuildInput input, BuildOutputBuilder output) async {
  final rustBuilder = RustBuilder(
    assetName: 'src/bindings/bindings.dart',
    cratePath: '../../native',
  );

  await rustBuilder.run(input: input, output: output);
}
