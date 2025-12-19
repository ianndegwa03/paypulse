import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

void main(List<String> arguments) {
  final logger = Logger();
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..'));

  logger.i('Generating models...');
  Process.runSync(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: projectRoot,
    runInShell: true,
  );
  
  // Generate route files
  Process.runSync(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: projectRoot,
    runInShell: true,
  );

  logger.i('Models generated successfully!');

  // Format generated files
  Process.runSync(
    'dart',
    ['format', 'lib'],
    workingDirectory: projectRoot,
    runInShell: true,
  );

  logger.i('Code formatted!');
}