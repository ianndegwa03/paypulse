import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..'));
  
  print('Generating models...');
  
  // Run build_runner
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
  
  print('Models generated successfully!');
  
  // Format generated files
  Process.runSync(
    'dart',
    ['format', 'lib'],
    workingDirectory: projectRoot,
    runInShell: true,
  );
  
  print('Code formatted!');
}