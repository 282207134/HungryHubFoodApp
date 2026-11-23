import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final captures = (data!['captures'] as Map).cast<String, String>();
    if (captures.length != 78) throw StateError('Expected 78 screenshots.');
    for (final entry in captures.entries) {
      final target = File('docs/screenshots/${entry.key}.png');
      await target.parent.create(recursive: true);
      await target.writeAsBytes(base64Decode(entry.value));
    }
    stdout.writeln('Saved ${captures.length} emulator screenshots.');
  },
);
